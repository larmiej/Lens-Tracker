//
//  LensCycle.swift
//  ContactLensesTracker
//
//  Model representing a contact lens usage cycle
//  Tracks start date, lens type, and individual wear dates for accurate tracking
//

import Foundation

/// Container for current and historical lens cycles
///
/// This struct prevents history loss when starting new cycles or resetting.
/// All previous cycles are preserved in the `previousCycles` array.
struct CycleHistory: Codable, Sendable {
    /// Currently active lens cycle
    var currentCycle: LensCycle?

    /// Array of completed/archived cycles
    var previousCycles: [LensCycle]

    init(currentCycle: LensCycle? = nil, previousCycles: [LensCycle] = []) {
        self.currentCycle = currentCycle
        self.previousCycles = previousCycles
    }

    /// Archives the current cycle and sets a new one
    /// - Parameter newCycle: The new cycle to set as current
    mutating func archiveAndStartNew(_ newCycle: LensCycle) {
        if let current = currentCycle {
            previousCycles.append(current)
        }
        currentCycle = newCycle
    }
}

/// Represents a single contact lens usage cycle with wear date tracking
///
/// This model tracks when lenses were started, the type of lenses being worn,
/// and records each individual wear date. This approach allows accurate tracking
/// even when lenses aren't worn every day.
///
/// The struct is designed to be immutable, following value semantics.
/// Updates return new instances rather than modifying the existing instance.
struct LensCycle: Identifiable, Codable, Sendable, Equatable {
    // MARK: - Properties

    /// Unique identifier for the cycle
    let id: UUID

    /// Date when the lens cycle started
    let startDate: Date

    /// Type of contact lens being tracked
    let lensType: LensType

    /// Array of dates when the lenses were actually worn
    ///
    /// This allows accurate tracking when lenses aren't worn every day.
    /// Each date is normalized to midnight for consistent comparison.
    let wearDates: [Date]

    // MARK: - Initialization

    /// Creates a new lens cycle
    ///
    /// - Parameters:
    ///   - id: Unique identifier (defaults to new UUID)
    ///   - startDate: Date the cycle started (defaults to today at midnight)
    ///   - lensType: Type of lens being tracked
    ///   - wearDates: Array of dates when lenses were worn (defaults to empty)
    init(
        id: UUID = UUID(),
        startDate: Date = Calendar.current.startOfDay(for: Date()),
        lensType: LensType,
        wearDates: [Date] = []
    ) {
        self.id = id
        self.startDate = Calendar.current.startOfDay(for: startDate)
        self.lensType = lensType
        // Normalize all wear dates to start of day for consistent comparison
        self.wearDates = wearDates.map { Calendar.current.startOfDay(for: $0) }
    }

    // MARK: - Computed Properties

    /// Current number of days the lenses have been worn
    ///
    /// - Returns: Count of wear dates (not calendar days since start)
    var currentDay: Int {
        wearDates.count
    }

    /// Number of days remaining before lens replacement is due
    ///
    /// - Returns: Positive number for days remaining, 0 or negative if overdue
    var daysRemaining: Int {
        lensType.maxDays - currentDay
    }

    /// Whether the lenses are overdue for replacement
    ///
    /// - Returns: `true` if currentDay exceeds maxDays, `false` otherwise
    var isOverdue: Bool {
        currentDay > lensType.maxDays
    }

    /// Whether the lenses have been worn today
    ///
    /// - Returns: `true` if today's date is in wearDates, `false` otherwise
    var hasWornToday: Bool {
        let today = Calendar.current.startOfDay(for: Date())
        return wearDates.contains(today)
    }

    /// Progress percentage for visual progress indicators
    ///
    /// - Returns: Value between 0.0 and 1.0 representing wear progress
    ///            Returns 1.0 (100%) if at or over maxDays
    var progressPercentage: Double {
        let percentage = Double(currentDay) / Double(lensType.maxDays)
        return min(percentage, 1.0)
    }

    // MARK: - Methods

    /// Adds a wear entry for a specific date
    ///
    /// This method returns a new `LensCycle` instance with the wear date added.
    /// If the date already exists in wearDates, the original cycle is returned unchanged.
    ///
    /// - Parameter date: The date to add as a wear date
    /// - Returns: New `LensCycle` with the wear date added
    func addWearEntry(for date: Date = Date()) -> LensCycle {
        let normalizedDate = Calendar.current.startOfDay(for: date)

        // Don't add duplicate dates
        guard !wearDates.contains(normalizedDate) else {
            return self
        }

        let updatedWearDates = (wearDates + [normalizedDate])
            .sorted() // Keep dates sorted chronologically

        return LensCycle(
            id: id,
            startDate: startDate,
            lensType: lensType,
            wearDates: updatedWearDates
        )
    }

    /// Removes a wear entry for a specific date
    ///
    /// This method returns a new `LensCycle` instance with the wear date removed.
    /// If the date doesn't exist in wearDates, the original cycle is returned unchanged.
    ///
    /// - Parameter date: The date to remove from wear dates
    /// - Returns: New `LensCycle` with the wear date removed
    func removeWearEntry(for date: Date) -> LensCycle {
        let normalizedDate = Calendar.current.startOfDay(for: date)

        let updatedWearDates = wearDates.filter { $0 != normalizedDate }

        // If nothing changed, return self
        guard updatedWearDates.count != wearDates.count else {
            return self
        }

        return LensCycle(
            id: id,
            startDate: startDate,
            lensType: lensType,
            wearDates: updatedWearDates
        )
    }

    /// Creates a new lens cycle starting today
    ///
    /// This method resets the cycle with a new ID, today's date as start date,
    /// the same lens type, and an empty wear dates array.
    ///
    /// - Returns: New `LensCycle` starting today with empty wear history
    func reset() -> LensCycle {
        LensCycle(
            id: UUID(),
            startDate: Date(),
            lensType: lensType,
            wearDates: []
        )
    }

    /// Updates the start date of the current cycle
    ///
    /// This method returns a new `LensCycle` instance with an updated start date
    /// while preserving the same id, lens type, and wear history. Use this when
    /// the user needs to correct the start date without creating a new cycle.
    ///
    /// - Parameter newDate: The new start date for the cycle
    /// - Returns: New `LensCycle` with updated start date but same id and wear history
    func updateStartDate(to newDate: Date) -> LensCycle {
        LensCycle(
            id: id,
            startDate: newDate,
            lensType: lensType,
            wearDates: wearDates
        )
    }
}

// MARK: - Preview Helpers

#if DEBUG
extension LensCycle {
    /// Sample daily lens cycle for previews
    static let sampleDaily = LensCycle(
        startDate: Date(),
        lensType: .daily,
        wearDates: [Date()]
    )

    /// Sample biweekly lens cycle with partial wear history
    static let sampleBiweekly: LensCycle = {
        let calendar = Calendar.current
        let today = Date()
        let wearDates = (0..<7).compactMap { daysAgo in
            calendar.date(byAdding: .day, value: -daysAgo, to: today)
        }

        return LensCycle(
            startDate: calendar.date(byAdding: .day, value: -10, to: today)!,
            lensType: .biweekly,
            wearDates: wearDates
        )
    }()

    /// Sample monthly lens cycle near the end of its lifecycle
    static let sampleMonthly: LensCycle = {
        let calendar = Calendar.current
        let today = Date()
        let wearDates = (0..<28).compactMap { daysAgo in
            calendar.date(byAdding: .day, value: -daysAgo, to: today)
        }

        return LensCycle(
            startDate: calendar.date(byAdding: .day, value: -30, to: today)!,
            lensType: .monthly,
            wearDates: wearDates
        )
    }()

    /// Sample overdue lens cycle
    static let sampleOverdue: LensCycle = {
        let calendar = Calendar.current
        let today = Date()
        let wearDates = (0..<16).compactMap { daysAgo in
            calendar.date(byAdding: .day, value: -daysAgo, to: today)
        }

        return LensCycle(
            startDate: calendar.date(byAdding: .day, value: -20, to: today)!,
            lensType: .biweekly,
            wearDates: wearDates
        )
    }()
}
#endif
