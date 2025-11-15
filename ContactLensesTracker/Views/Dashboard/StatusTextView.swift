//
//  StatusTextView.swift
//  ContactLensesTracker
//
//  Displays current lens cycle status and contextual messaging
//  Shows dynamic status messages with color-coded text based on wear progress
//

import SwiftUI

/// A text view that displays contextual status messages for the lens cycle
///
/// This view shows dynamic status messages that change based on wear progress:
/// - Healthy status: Positive messages about remaining time
/// - Caution status: Reminder about upcoming replacement
/// - Warning status: Urgent messages about approaching replacement
/// - Critical status: Overdue warnings
///
/// The text color automatically adjusts to match the progress status.
struct StatusTextView: View {
    // MARK: - Properties

    /// Current day number in the wear cycle
    let currentDay: Int

    /// Maximum days for the lens type
    let maxDays: Int

    /// Status message to display
    let statusText: String

    // MARK: - Computed Properties

    /// Color for the status text based on current wear progress
    private var textColor: Color {
        Color.colorForDay(currentDay, maxDays: maxDays)
    }

    // MARK: - Body

    var body: some View {
        Text(statusText)
            .font(.system(size: 20, weight: .medium))
            .foregroundStyle(textColor)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 20)
            .accessibilityLabel(statusText)
    }
}

// MARK: - Preview Provider

#Preview("Healthy Status") {
    StatusTextView(
        currentDay: 3,
        maxDays: 14,
        statusText: "Looking good! 11 days until replacement"
    )
    .padding()
}

#Preview("Caution Status") {
    StatusTextView(
        currentDay: 10,
        maxDays: 14,
        statusText: "Replace in 4 days"
    )
    .padding()
}

#Preview("Warning Status") {
    StatusTextView(
        currentDay: 13,
        maxDays: 14,
        statusText: "Replace soon - 1 day remaining"
    )
    .padding()
}

#Preview("Critical Status - At Max") {
    StatusTextView(
        currentDay: 14,
        maxDays: 14,
        statusText: "Replace today"
    )
    .padding()
}

#Preview("Critical Status - Overdue") {
    StatusTextView(
        currentDay: 16,
        maxDays: 14,
        statusText: "2 days overdue - replace immediately"
    )
    .padding()
}

#Preview("Daily Lens") {
    StatusTextView(
        currentDay: 1,
        maxDays: 1,
        statusText: "Replace with fresh lenses"
    )
    .padding()
}

#Preview("Long Message") {
    StatusTextView(
        currentDay: 5,
        maxDays: 14,
        statusText: "Looking good! You have plenty of time remaining before your next lens replacement"
    )
    .padding()
}
