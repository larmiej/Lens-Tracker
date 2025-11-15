//
//  ProgressRingView.swift
//  ContactLensesTracker
//
//  Circular progress ring showing days remaining in current lens cycle
//  Displays current day, max days, and lens type with color-coded progress
//

import SwiftUI

/// A circular progress ring that visualizes lens wear progress
///
/// This view displays a circular progress indicator with:
/// - Gray background ring showing total capacity
/// - Colored foreground ring showing current progress
/// - Center text displaying "DAY X/Y" format
/// - Lens type label below the day counter
///
/// The ring color automatically adjusts based on wear progress using
/// the Color.colorForDay() helper to indicate lens health status.
struct ProgressRingView: View {
    // MARK: - Properties

    /// Current day number in the wear cycle
    let currentDay: Int

    /// Maximum days for the lens type
    let maxDays: Int

    /// Lens type display name for the label
    let lensTypeLabel: String

    // MARK: - Constants

    /// Diameter of the progress ring
    private let ringDiameter: CGFloat = 200

    /// Width of the ring stroke
    private let lineWidth: CGFloat = 16

    /// Opacity of the background ring
    private let backgroundRingOpacity: Double = 0.2

    // MARK: - Computed Properties

    /// Progress value between 0.0 and 1.0
    private var progress: Double {
        guard maxDays > 0 else { return 0.0 }
        let percentage = Double(currentDay) / Double(maxDays)
        return min(percentage, 1.0)
    }

    /// Color for the progress ring based on current wear status
    private var ringColor: Color {
        Color.colorForDay(currentDay, maxDays: maxDays)
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            // Background ring (gray, showing total capacity)
            Circle()
                .stroke(
                    Color.gray.opacity(backgroundRingOpacity),
                    lineWidth: lineWidth
                )

            // Progress ring (colored, showing current progress)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    ringColor,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90)) // Start at top
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progress)

            // Center content
            VStack(spacing: 4) {
                // Main day counter
                Text("DAY \(currentDay)/\(maxDays)")
                    .font(.hero)
                    .foregroundStyle(ringColor)

                // Lens type label
                Text(lensTypeLabel)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: ringDiameter, height: ringDiameter)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Day \(currentDay) of \(maxDays)")
        .accessibilityValue("\(lensTypeLabel) lenses")
    }
}

// MARK: - Preview Provider

#Preview("Healthy Status") {
    ProgressRingView(
        currentDay: 3,
        maxDays: 14,
        lensTypeLabel: "Biweekly"
    )
    .padding()
}

#Preview("Caution Status") {
    ProgressRingView(
        currentDay: 10,
        maxDays: 14,
        lensTypeLabel: "Biweekly"
    )
    .padding()
}

#Preview("Warning Status") {
    ProgressRingView(
        currentDay: 12,
        maxDays: 14,
        lensTypeLabel: "Biweekly"
    )
    .padding()
}

#Preview("Critical Status") {
    ProgressRingView(
        currentDay: 15,
        maxDays: 14,
        lensTypeLabel: "Biweekly"
    )
    .padding()
}

#Preview("Monthly Lens") {
    ProgressRingView(
        currentDay: 20,
        maxDays: 30,
        lensTypeLabel: "Monthly"
    )
    .padding()
}

#Preview("Daily Lens") {
    ProgressRingView(
        currentDay: 1,
        maxDays: 1,
        lensTypeLabel: "Daily"
    )
    .padding()
}
