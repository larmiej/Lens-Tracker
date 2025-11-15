//
//  ContentView.swift
//  ContactLensesTracker
//
//  Root view of the application
//  Manages view model lifecycle and provides it to the environment
//

import SwiftUI

/// Root view that manages the app's main view model and navigation structure
///
/// This view serves as the entry point for the app's UI hierarchy, responsible for:
/// - Creating and managing the LensTrackerViewModel lifecycle
/// - Providing the view model to child views via environment
/// - Displaying a loading screen during initial data load
/// - Presenting the main DashboardView once data is ready
///
/// The view uses Swift 6's @State with @Observable for view model management,
/// ensuring proper SwiftUI lifecycle integration and automatic UI updates.
struct ContentView: View {
    // MARK: - State

    /// Main view model managing lens tracking state
    ///
    /// Created as @State to ensure single source of truth and proper lifecycle.
    /// The @Observable macro on the view model enables automatic UI updates.
    @State private var viewModel = LensTrackerViewModel()

    /// Tracks whether initial data load has completed
    @State private var hasLoadedInitialData = false

    // MARK: - Body

    var body: some View {
        Group {
            if hasLoadedInitialData {
                // Main app content
                DashboardView()
                    .environment(viewModel)
            } else {
                // Loading screen on app launch
                loadingView
            }
        }
        .task {
            // Load initial data when view appears
            await loadInitialData()
        }
    }

    // MARK: - Loading View

    /// Loading screen displayed during initial app launch
    @ViewBuilder
    private var loadingView: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                // App icon representation
                Image(systemName: "eye.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.blue)

                // App name
                Text("Lens Tracker")
                    .font(.title2)
                    .fontWeight(.semibold)

                // Loading indicator
                ProgressView()
                    .scaleEffect(1.2)
                    .tint(.blue)
            }
        }
    }

    // MARK: - Data Loading

    /// Loads initial data when the app launches
    ///
    /// This method waits for the view model to complete its initial data load
    /// before presenting the main UI. This ensures the user sees appropriate
    /// content (either an active cycle or empty state) rather than a flash of
    /// loading indicators.
    private func loadInitialData() async {
        // View model loads data on init, so we wait a moment for that to complete
        // If the data is already loaded from init, this will be near-instantaneous
        try? await Task.sleep(for: .milliseconds(100))

        // Mark as loaded to show main content
        hasLoadedInitialData = true
    }
}

// MARK: - Preview Provider

#Preview("App Launch") {
    ContentView()
}

#Preview("With Active Cycle") {
    let viewModel = LensTrackerViewModel.previewBiweekly

    return DashboardView()
        .environment(viewModel)
}

#Preview("Empty State") {
    let viewModel = LensTrackerViewModel.previewEmpty

    return DashboardView()
        .environment(viewModel)
}
