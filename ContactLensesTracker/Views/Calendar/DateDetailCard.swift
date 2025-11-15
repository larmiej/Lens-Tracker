//
//  DateDetailCard.swift
//  ContactLensesTracker
//
//  Card component displaying details for a selected date
//  Shows wear status and allows adding/removing wear entries
//

import SwiftUI

/// Card displaying detailed information for a selected date
///
/// This component shows whether lenses were worn on a specific date,
/// the cycle day if applicable, and provides actions to add or remove
/// wear entries. It includes confirmation dialogs for destructive actions.
struct DateDetailCard: View {
    // MARK: - Properties

    /// The date being displayed
    let date: Date

    /// Whether lenses were worn on this date
    let isWorn: Bool

    /// The cycle day number if worn (optional)
    let cycleDay: Int?

    /// Action to perform when removing a wear entry
    let onRemove: () -> Void

    /// Action to perform when adding a wear entry
    let onAdd: () -> Void

    // MARK: - State

    /// Controls the presentation of the removal confirmation alert
    @State private var showingRemovalConfirmation = false

    // MARK: - Computed Properties

    /// Formatted date string for display
    /// Uses cached formatter for better performance
    private var formattedDate: String {
        return CachedDateFormatters.full.string(from: date)
    }

    /// Status text indicating if lenses were worn
    private var statusText: String {
        isWorn ? "Worn today" : "Not worn"
    }

    /// Cycle day text if applicable
    private var cycleDayText: String? {
        guard let day = cycleDay, isWorn else { return nil }
        return "Day \(day) of current cycle"
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Date header
            Text(formattedDate)
                .font(.bodyBold)
                .foregroundStyle(.primary)

            // Status information
            VStack(alignment: .leading, spacing: 8) {
                Text(statusText)
                    .font(.body)
                    .foregroundStyle(.secondary)

                if let cycleDayText {
                    Text(cycleDayText)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            // Action button
            if isWorn {
                Button(role: .destructive) {
                    showingRemovalConfirmation = true
                } label: {
                    Label("Remove Entry", systemImage: "trash")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.regular)
            } else {
                Button {
                    onAdd()
                } label: {
                    Label("Add Entry", systemImage: "plus.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.regular)
            }
        }
        .padding(16)
        .background(Color(.systemGroupedBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
        .alert("Remove Wear Entry", isPresented: $showingRemovalConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Remove", role: .destructive) {
                onRemove()
            }
        } message: {
            Text("Are you sure you want to remove the wear entry for this date?")
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Date details for \(formattedDate)")
    }
}

// MARK: - Preview Provider

#Preview("Worn Today") {
    DateDetailCard(
        date: Date(),
        isWorn: true,
        cycleDay: 7,
        onRemove: {},
        onAdd: {}
    )
    .padding()
}

#Preview("Not Worn") {
    DateDetailCard(
        date: Date(),
        isWorn: false,
        cycleDay: nil,
        onRemove: {},
        onAdd: {}
    )
    .padding()
}

#Preview("Past Date Worn") {
    DateDetailCard(
        date: Calendar.current.date(byAdding: .day, value: -5, to: Date())!,
        isWorn: true,
        cycleDay: 2,
        onRemove: {},
        onAdd: {}
    )
    .padding()
}
