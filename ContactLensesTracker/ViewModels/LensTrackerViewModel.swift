//
//  LensTrackerViewModel.swift
//  ContactLensesTracker
//
//  Main view model managing lens tracking state and business logic
//  Coordinates between views, models, and data persistence
//

import Foundation
import SwiftUI

/// Main view model for the lens tracker application
///
/// This view model serves as the single source of truth for UI state and coordinates
/// all business logic for lens tracking. It manages the current lens cycle, handles
/// user interactions, and provides computed properties for UI presentation.
///
/// The view model uses Swift 6 concurrency features with @MainActor isolation to ensure
/// all UI updates happen on the main thread, and coordinates with the DataManager actor
/// for thread-safe data persistence.
@MainActor
@Observable
final class LensTrackerViewModel {
    // MARK: - Published Properties

    /// Current active lens cycle being tracked
    ///
    /// When nil, the user hasn't started tracking lenses yet (onboarding state)
    var currentCycle: LensCycle?

    /// Loading state for async operations
    ///
    /// Used to show loading indicators during data operations
    var isLoading: Bool = false

    /// User-facing error message
    ///
    /// When set, the UI should display this error to the user
    var errorMessage: String?

    /// Controls presentation of the settings sheet
    var showingSettings: Bool = false

    /// Controls navigation to the history view
    var showingHistory: Bool = false

    // MARK: - Dependencies

    /// Data manager actor for thread-safe persistence operations
    private let dataManager: DataManager

    // MARK: - Computed Properties

    /// Whether an active lens cycle exists
    var hasActiveCycle: Bool {
        currentCycle != nil
    }

    /// Current day number in the wear cycle
    ///
    /// Returns the count of days worn, not calendar days since start
    var currentDay: Int {
        currentCycle?.currentDay ?? 0
    }

    /// Maximum days for the current lens type
    var maxDays: Int {
        currentCycle?.lensType.maxDays ?? 14
    }

    /// Number of days remaining before replacement
    ///
    /// Can be negative if overdue
    var daysRemaining: Int {
        currentCycle?.daysRemaining ?? 0
    }

    /// Progress percentage for visual indicators
    ///
    /// Returns value between 0.0 and 1.0, capped at 1.0 for overdue lenses
    var progressPercentage: Double {
        currentCycle?.progressPercentage ?? 0.0
    }

    /// Whether lenses have been worn today
    var hasWornToday: Bool {
        currentCycle?.hasWornToday ?? false
    }

    /// Contextual status message based on cycle progress
    ///
    /// Returns different messages based on the current day and max days:
    /// - Days 1-10: Positive message about remaining time
    /// - Days 11-12: Reminder about upcoming replacement
    /// - Days 13-14: Warning about approaching replacement
    /// - Day == maxDays: Urgent replacement message
    /// - Day > maxDays: Overdue warning with count
    var statusText: String {
        guard let cycle = currentCycle else {
            return "No active lens cycle"
        }

        let day = cycle.currentDay
        let maxDays = cycle.lensType.maxDays
        let remaining = cycle.daysRemaining

        // Handle special case for daily lenses
        if maxDays == 1 {
            return day == 0 ? "Ready to wear" : "Replace with fresh lenses"
        }

        // Handle overdue lenses
        if day > maxDays {
            let overdue = abs(remaining)
            return "\(overdue) \(overdue == 1 ? "day" : "days") overdue - replace immediately"
        }

        // Handle replacement day
        if day == maxDays {
            return "Replace today"
        }

        // Calculate percentage for status thresholds
        let percentage = Double(day) / Double(maxDays)

        switch percentage {
        case 0..<0.71: // Days 1-10 for biweekly
            return "Looking good! \(remaining) \(remaining == 1 ? "day" : "days") until replacement"
        case 0.71..<0.86: // Days 11-12 for biweekly
            return "Replace in \(remaining) \(remaining == 1 ? "day" : "days")"
        default: // Days 13-14 for biweekly
            return "Replace soon - \(remaining) \(remaining == 1 ? "day" : "days") remaining"
        }
    }

    /// Color for status indication
    ///
    /// Uses the design spec color progression:
    /// - Green: Early cycle (healthy)
    /// - Yellow: Mid cycle (caution)
    /// - Orange: Late cycle (warning)
    /// - Red: Overdue (critical)
    var statusColor: Color {
        guard let cycle = currentCycle else {
            return .gray
        }

        return Color.colorForCycle(cycle)
    }

    // MARK: - Initialization

    /// Creates a new view model instance
    ///
    /// - Parameter dataManager: The data manager actor for persistence (defaults to shared instance)
    init(dataManager: DataManager = .shared) {
        self.dataManager = dataManager

        // Load initial data
        Task {
            await loadData()
        }
    }

    // MARK: - Data Loading

    /// Loads the current lens cycle from persistent storage
    ///
    /// This method fetches the active cycle from the DataManager actor and updates
    /// the UI state accordingly. It handles loading states and errors gracefully.
    func loadData() async {
        isLoading = true
        errorMessage = nil

        do {
            currentCycle = await dataManager.loadCycle()
        } catch {
            handleError(error)
        }

        isLoading = false
    }

    // MARK: - Wear Tracking

    /// Logs a wear entry for today
    ///
    /// This method adds today's date to the wear history, preventing duplicates.
    /// If the user has already logged today, this method is a no-op.
    func logTodayWear() async {
        guard let cycle = currentCycle else {
            errorMessage = "No active lens cycle. Please start a new cycle first."
            return
        }

        // Don't log if already worn today
        guard !cycle.hasWornToday else {
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let updatedCycle = cycle.addWearEntry()
            try await dataManager.updateCycle(updatedCycle)
            currentCycle = updatedCycle
        } catch {
            handleError(error)
        }

        isLoading = false
    }

    /// Removes a wear entry for a specific date
    ///
    /// This method allows users to correct mistakes by removing a wear date
    /// from the history. If the date isn't in the history, this is a no-op.
    ///
    /// - Parameter date: The date to remove from wear history
    func removeWearEntry(for date: Date) async {
        guard let cycle = currentCycle else {
            errorMessage = "No active lens cycle found"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let updatedCycle = cycle.removeWearEntry(for: date)
            try await dataManager.updateCycle(updatedCycle)
            currentCycle = updatedCycle
        } catch {
            handleError(error)
        }

        isLoading = false
    }

    // MARK: - Cycle Management

    /// Starts a new lens cycle with the specified type and start date
    ///
    /// This method creates a fresh lens cycle, replacing any existing cycle.
    /// Use this when the user opens a new pair of lenses.
    ///
    /// - Parameters:
    ///   - type: The type of contact lens being tracked
    ///   - startDate: The date the cycle begins (defaults to today)
    func startNewCycle(type: LensType, startDate: Date = Date()) async {
        isLoading = true
        errorMessage = nil

        do {
            let newCycle = try await dataManager.createNewCycle(
                type: type,
                startDate: startDate
            )
            currentCycle = newCycle
        } catch {
            handleError(error)
        }

        isLoading = false
    }

    /// Resets the current lens cycle to start fresh
    ///
    /// This method creates a new cycle with the same lens type but clears
    /// all wear history and sets the start date to today.
    func resetCycle() async {
        guard let cycle = currentCycle else {
            errorMessage = "No active lens cycle to reset"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let resetCycle = cycle.reset()
            try await dataManager.updateCycle(resetCycle)
            currentCycle = resetCycle
        } catch {
            handleError(error)
        }

        isLoading = false
    }

    /// Changes the lens type for the current cycle
    ///
    /// This method updates the lens type and resets the cycle since changing
    /// lens types requires starting fresh tracking.
    ///
    /// - Parameter type: The new lens type to track
    func changeLensType(to type: LensType) async {
        isLoading = true
        errorMessage = nil

        do {
            let newCycle = try await dataManager.createNewCycle(
                type: type,
                startDate: Date()
            )
            currentCycle = newCycle
        } catch {
            handleError(error)
        }

        isLoading = false
    }

    // MARK: - Error Handling

    /// Handles errors and converts them to user-friendly messages
    ///
    /// This method processes errors from data operations and sets appropriate
    /// error messages for display to the user.
    ///
    /// - Parameter error: The error to handle
    func handleError(_ error: Error) {
        if let dataError = error as? DataManagerError {
            errorMessage = dataError.localizedDescription
        } else {
            errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
        }

        #if DEBUG
        print("LensTrackerViewModel Error: \(error)")
        #endif
    }
}

// MARK: - Preview Helpers

#if DEBUG
extension LensTrackerViewModel {
    /// Creates a view model with a mock data manager for previews
    ///
    /// This convenience initializer sets up an isolated test instance with
    /// sample data for SwiftUI previews and testing.
    ///
    /// - Parameter withCycle: Whether to include a sample cycle (defaults to true)
    /// - Returns: Configured view model for preview use
    static func makePreview(withCycle: Bool = true) -> LensTrackerViewModel {
        let testManager = DataManager.makeTestInstance()
        let viewModel = LensTrackerViewModel(dataManager: testManager)

        if withCycle {
            Task {
                try? await testManager.saveCycle(.sampleBiweekly)
                await viewModel.loadData()
            }
        }

        return viewModel
    }

    /// Preview view model with no active cycle
    static let previewEmpty: LensTrackerViewModel = {
        let testManager = DataManager.makeTestInstance()
        return LensTrackerViewModel(dataManager: testManager)
    }()

    /// Preview view model with a healthy biweekly cycle
    static let previewBiweekly: LensTrackerViewModel = {
        let testManager = DataManager.makeTestInstance()
        let viewModel = LensTrackerViewModel(dataManager: testManager)

        Task {
            try? await testManager.saveCycle(.sampleBiweekly)
            await viewModel.loadData()
        }

        return viewModel
    }()

    /// Preview view model with an overdue cycle
    static let previewOverdue: LensTrackerViewModel = {
        let testManager = DataManager.makeTestInstance()
        let viewModel = LensTrackerViewModel(dataManager: testManager)

        Task {
            try? await testManager.saveCycle(.sampleOverdue)
            await viewModel.loadData()
        }

        return viewModel
    }()

    /// Preview view model with a daily lens cycle
    static let previewDaily: LensTrackerViewModel = {
        let testManager = DataManager.makeTestInstance()
        let viewModel = LensTrackerViewModel(dataManager: testManager)

        Task {
            try? await testManager.saveCycle(.sampleDaily)
            await viewModel.loadData()
        }

        return viewModel
    }()
}
#endif
