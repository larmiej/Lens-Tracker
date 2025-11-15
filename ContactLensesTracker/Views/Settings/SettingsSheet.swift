//
//  SettingsSheet.swift
//  ContactLensesTracker
//
//  Settings sheet for configuring lens type, replacement schedule,
//  notifications, and app preferences
//

import SwiftUI

struct SettingsSheet: View {
    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss
    @Environment(LensTrackerViewModel.self) private var viewModel

    // MARK: - State

    @State private var selectedLensType: LensType = .biweekly
    @State private var newStartDate: Date = Date()
    @State private var showingLensTypeConfirmation = false
    @State private var showingResetConfirmation = false
    @State private var pendingLensType: LensType?

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                Form {
                    if viewModel.hasActiveCycle {
                        activeCycleSections
                    } else {
                        getStartedSection
                    }
                }
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
                .disabled(viewModel.isLoading)

                // Loading overlay
                if viewModel.isLoading {
                    Color.black.opacity(0.2)
                        .ignoresSafeArea()

                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.lensPrimary)
                }
            }
            .alert("Change Lens Type?", isPresented: $showingLensTypeConfirmation) {
                Button("Cancel", role: .cancel) {
                    // Reset to current lens type
                    if let currentType = viewModel.currentCycle?.lensType {
                        selectedLensType = currentType
                    }
                    pendingLensType = nil
                }
                Button("Change & Reset", role: .destructive) {
                    if let newType = pendingLensType {
                        viewModel.changeLensType(to: newType)
                        pendingLensType = nil
                    }
                }
            } message: {
                Text("Changing lens type will reset your current cycle and start tracking from today. Your history will be preserved.")
            }
            .alert("Reset Cycle?", isPresented: $showingResetConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Reset Cycle", role: .destructive) {
                    viewModel.resetCycle()
                }
            } message: {
                Text("This will clear your current cycle and start fresh. Your history will be preserved.")
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
        .onAppear {
            // Initialize selected lens type from current cycle
            if let currentType = viewModel.currentCycle?.lensType {
                selectedLensType = currentType
            }
        }
    }

    // MARK: - Active Cycle Sections

    @ViewBuilder
    private var activeCycleSections: some View {
        lensTypeSection
        currentCycleInfoSection
        actionsSection
    }

    // MARK: - Lens Type Section

    private var lensTypeSection: some View {
        Section {
            Picker("Lens Type", selection: $selectedLensType) {
                ForEach(LensType.allCases) { type in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(type.displayName)
                            .font(.body)
                        Text(type.scheduleDescription)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .tag(type)
                }
            }
            .pickerStyle(.inline)
            .onChange(of: selectedLensType) { oldValue, newValue in
                // Only show confirmation if there's an active cycle and type actually changed
                if let currentType = viewModel.currentCycle?.lensType,
                   newValue != currentType {
                    pendingLensType = newValue
                    showingLensTypeConfirmation = true
                }
            }
        } header: {
            Text("Lens Type")
        } footer: {
            Text("Changing lens type will reset your current cycle.")
        }
    }

    // MARK: - Current Cycle Info Section

    private var currentCycleInfoSection: some View {
        Section("Current Cycle") {
            if let cycle = viewModel.currentCycle {
                LabeledContent("Start Date") {
                    Text(cycle.startDate, style: .date)
                        .foregroundStyle(.secondary)
                }

                LabeledContent("Days Worn") {
                    HStack(spacing: 4) {
                        Text("\(cycle.currentDay)")
                            .fontWeight(.semibold)
                        Text("of \(cycle.lensType.maxDays)")
                            .foregroundStyle(.secondary)
                    }
                }

                LabeledContent("Days Remaining") {
                    Text("\(cycle.daysRemaining)")
                        .fontWeight(.semibold)
                        .foregroundStyle(cycle.isOverdue ? .lensCritical : viewModel.statusColor)
                }

                LabeledContent("Status") {
                    Text(viewModel.statusText)
                        .font(.caption)
                        .foregroundStyle(viewModel.statusColor)
                        .multilineTextAlignment(.trailing)
                }
            }
        }
    }

    // MARK: - Actions Section

    private var actionsSection: some View {
        Section {
            Button(role: .destructive) {
                showingResetConfirmation = true
            } label: {
                HStack {
                    Image(systemName: "arrow.counterclockwise")
                    Text("Reset Cycle")
                }
            }
        } header: {
            Text("Actions")
        } footer: {
            Text("Reset your cycle when starting a new pair of lenses. This clears the current cycle but preserves your history.")
        }
    }

    // MARK: - Get Started Section

    private var getStartedSection: some View {
        Section {
            Picker("Lens Type", selection: $selectedLensType) {
                ForEach(LensType.allCases) { type in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(type.displayName)
                            .font(.body)
                        Text(type.scheduleDescription)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .tag(type)
                }
            }
            .pickerStyle(.inline)

            DatePicker(
                "Start Date",
                selection: $newStartDate,
                in: ...Date(),
                displayedComponents: .date
            )

            Button {
                viewModel.startNewCycle(
                    type: selectedLensType,
                    startDate: newStartDate
                )
            } label: {
                HStack {
                    Spacer()
                    Text("Start Tracking")
                        .fontWeight(.semibold)
                    Spacer()
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(.lensPrimary)
            .listRowBackground(Color.clear)
        } header: {
            Text("Get Started")
        } footer: {
            Text("Select your lens type and start date to begin tracking your contact lens wear cycle.")
        }
    }
}

// MARK: - Previews

#Preview("With Active Cycle") {
    @Previewable @State var viewModel = LensTrackerViewModel.previewBiweekly

    SettingsSheet()
        .environment(viewModel)
}

#Preview("Without Active Cycle") {
    @Previewable @State var viewModel = LensTrackerViewModel.previewEmpty

    SettingsSheet()
        .environment(viewModel)
}

#Preview("Overdue Cycle") {
    @Previewable @State var viewModel = LensTrackerViewModel.previewOverdue

    SettingsSheet()
        .environment(viewModel)
}

#Preview("Daily Lenses") {
    @Previewable @State var viewModel = LensTrackerViewModel.previewDaily

    SettingsSheet()
        .environment(viewModel)
}
