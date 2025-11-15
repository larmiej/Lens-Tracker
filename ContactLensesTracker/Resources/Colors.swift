//
//  Colors.swift
//  ContactLensesTracker
//
//  Color definitions and theme configuration for the application
//  Provides consistent color palette throughout the app
//

import SwiftUI

extension Color {
    // MARK: - Lens Status Colors

    /// Healthy status color (green) - used for early cycle days (1-10)
    ///
    /// Indicates lenses are in good condition with plenty of wear time remaining
    static let lensHealthy = Color.green

    /// Caution status color (yellow) - used for middle cycle days (11-12)
    ///
    /// Indicates lenses are getting older but still within acceptable range
    static let lensCaution = Color.yellow

    /// Warning status color (orange) - used for late cycle days (13-14)
    ///
    /// Indicates lenses are approaching replacement time
    static let lensWarning = Color.orange

    /// Critical status color (red) - used for day 15+
    ///
    /// Indicates lenses are overdue for replacement and should be changed immediately
    static let lensCritical = Color.red

    /// Primary accent color for the app
    ///
    /// Used for primary actions, selected states, and interactive elements
    static let lensPrimary = Color.blue

    // MARK: - Helper Methods

    /// Returns the appropriate status color based on current wear day and lens type
    ///
    /// Color coding helps users quickly understand lens health:
    /// - Healthy (green): 0-66% of max days
    /// - Caution (yellow): 67-80% of max days
    /// - Warning (orange): 81-99% of max days
    /// - Critical (red): 100%+ of max days (overdue)
    ///
    /// - Parameters:
    ///   - day: Current day number in the wear cycle
    ///   - maxDays: Maximum days for the lens type
    /// - Returns: Color appropriate for the current status
    static func colorForDay(_ day: Int, maxDays: Int) -> Color {
        // Calculate percentage of cycle completed
        let percentage = Double(day) / Double(maxDays)

        switch percentage {
        case 0..<0.67:
            return .lensHealthy
        case 0.67..<0.81:
            return .lensCaution
        case 0.81..<1.0:
            return .lensWarning
        default:
            return .lensCritical
        }
    }

    /// Returns the appropriate status color for a lens cycle
    ///
    /// Convenience method that works directly with a `LensCycle` instance
    ///
    /// - Parameter cycle: The lens cycle to evaluate
    /// - Returns: Color appropriate for the cycle's current status
    static func colorForCycle(_ cycle: LensCycle) -> Color {
        colorForDay(cycle.currentDay, maxDays: cycle.lensType.maxDays)
    }
}

// MARK: - Preview Helpers

#if DEBUG
extension Color {
    /// Sample colors for preview and testing purposes
    static let previewColors: [(name: String, color: Color)] = [
        ("Healthy", .lensHealthy),
        ("Caution", .lensCaution),
        ("Warning", .lensWarning),
        ("Critical", .lensCritical),
        ("Primary", .lensPrimary)
    ]
}
#endif
