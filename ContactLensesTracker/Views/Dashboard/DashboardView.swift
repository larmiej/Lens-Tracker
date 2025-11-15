//
//  DashboardView.swift
//  ContactLensesTracker
//
//  Main dashboard view showing lens replacement progress and status
//  Displays current cycle, days remaining, and primary actions
//

import SwiftUI

/// The main dashboard view for the ContactLensesTracker app
///
/// This view serves as the primary interface showing:
/// - Circular progress ring with current day and lens type
/// - Dynamic status message based on wear progress
/// - Primary action button to log today's wear
/// - Metadata section with last worn and start dates
/// - Secondary navigation to calendar history
/// - Settings access via toolbar
///
/// The view handles both active cycle and empty states, providing
/// appropriate UI for users who haven't started tracking yet.
struct DashboardView: View {
    // MARK: - Environment

    /// View model managing lens tracking state and business logic
    @Environment(LensTrackerViewModel.self) private var viewModel

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.hasActiveCycle {
                    activeCycleView
                } else {
                    emptyStateView
                }
            }
            .navigationTitle("Lens Tracker")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.showingSettings = true
                    }) {
                        Image(systemName: "gear")
                            .font(.system(size: 18))
                    }
                }
            }
            .sheet(isPresented: Bindable(viewModel).showingSettings) {
                SettingsSheet()
                    .environment(viewModel)
            }
            .overlay {
                if viewModel.isLoading {
                    loadingOverlay
                }
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
        }
    }

    // MARK: - Active Cycle View

    /// Main view displayed when an active lens cycle exists
    @ViewBuilder
    private var activeCycleView: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Top padding
                Spacer()
                    .frame(height: 32)

                // Progress ring
                ProgressRingView(
                    currentDay: viewModel.currentDay,
                    maxDays: viewModel.maxDays,
                    lensTypeLabel: viewModel.currentCycle?.lensType.displayName ?? ""
                )

                // Ring to status spacing
                Spacer()
                    .frame(height: 24)

                // Status text
                StatusTextView(
                    currentDay: viewModel.currentDay,
                    maxDays: viewModel.maxDays,
                    statusText: viewModel.statusText
                )

                // Status to button spacing
                Spacer()
                    .frame(height: 40)

                // Primary action button
                PrimaryButton(
                    title: viewModel.hasWornToday ? "Logged for Today" : "Log Today's Wear",
                    isLogged: viewModel.hasWornToday,
                    action: {
                        Task {
                            await viewModel.logTodayWear()
                        }
                    }
                )

                // Button to metadata spacing
                Spacer()
                    .frame(height: 32)

                // Metadata section
                metadataSection

                // Metadata to secondary button spacing
                Spacer()
                    .frame(height: 24)

                // Secondary button - Calendar History
                Button(action: {
                    viewModel.showingHistory = true
                }) {
                    Text("View Calendar History")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.blue)
                }
                .padding(.horizontal, 20)

                Spacer()
                    .frame(height: 32)
            }
        }
        .navigationDestination(isPresented: Bindable(viewModel).showingHistory) {
            CalendarHistoryView()
                .environment(viewModel)
        }
    }

    // MARK: - Empty State View

    /// View displayed when no active lens cycle exists
    @ViewBuilder
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()

            // Empty state icon
            Image(systemName: "eye.circle")
                .font(.system(size: 80))
                .foregroundStyle(.blue.opacity(0.6))

            // Empty state message
            VStack(spacing: 12) {
                Text("No Active Lens Cycle")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Start tracking your contact lenses by creating a new cycle in Settings")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            // Call to action button
            Button(action: {
                viewModel.showingSettings = true
            }) {
                Text("Open Settings")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.blue)
                    .cornerRadius(16)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)

            Spacer()
        }
    }

    // MARK: - Metadata Section

    /// Displays cycle metadata (last worn date, start date)
    @ViewBuilder
    private var metadataSection: some View {
        if let cycle = viewModel.currentCycle {
            VStack(spacing: 12) {
                // Last worn date
                if let lastWornDate = cycle.wearDates.last {
                    metadataRow(
                        label: "Last Worn",
                        value: formatDate(lastWornDate)
                    )
                }

                // Divider
                Divider()
                    .padding(.horizontal, 20)

                // Start date
                metadataRow(
                    label: "Started",
                    value: formatDate(cycle.startDate)
                )
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
            .padding(.horizontal, 20)
        }
    }

    /// Helper to create a metadata row
    @ViewBuilder
    private func metadataRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.primary)
        }
    }

    // MARK: - Loading Overlay

    /// Semi-transparent loading overlay
    @ViewBuilder
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.2)
                .ignoresSafeArea()

            ProgressView()
                .scaleEffect(1.5)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                        .shadow(radius: 8)
                )
        }
    }

    // MARK: - Helper Methods

    /// Formats a date for display in metadata section
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

// MARK: - Preview Provider

#Preview("Active Cycle - Healthy") {
    DashboardView()
        .environment(LensTrackerViewModel.previewBiweekly)
}

#Preview("Active Cycle - Overdue") {
    DashboardView()
        .environment(LensTrackerViewModel.previewOverdue)
}

#Preview("Empty State") {
    DashboardView()
        .environment(LensTrackerViewModel.previewEmpty)
}

#Preview("Loading State") {
    let viewModel = LensTrackerViewModel.previewBiweekly
    viewModel.isLoading = true

    return DashboardView()
        .environment(viewModel)
}

#Preview("Error State") {
    let viewModel = LensTrackerViewModel.previewBiweekly
    viewModel.errorMessage = "Failed to save lens cycle data"

    return DashboardView()
        .environment(viewModel)
}

#Preview("Daily Lens") {
    DashboardView()
        .environment(LensTrackerViewModel.previewDaily)
}

#Preview("Dark Mode") {
    DashboardView()
        .environment(LensTrackerViewModel.previewBiweekly)
        .preferredColorScheme(.dark)
}
