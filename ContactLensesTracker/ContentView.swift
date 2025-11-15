//
//  ContentView.swift
//  ContactLensesTracker
//
//  Root view of the application
//  Manages view model lifecycle and provides it to the environment
//  FIXED: Removed arbitrary sleep and loading screen - DashboardView handles loading state
//

import SwiftUI

/// Root view that manages the app's main view model and navigation structure
///
/// This view serves as the entry point for the app's UI hierarchy, responsible for:
/// - Creating and managing the LensTrackerViewModel lifecycle
/// - Providing the view model to child views via environment
/// - Triggering initial data load using .task modifier
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

    // MARK: - Body

    var body: some View {
        DashboardView()
            .environment(viewModel)
            .task {
                // Load data when view appears
                // FIXED: Removed detached Task from ViewModel init and arbitrary sleep
                // Now properly triggered by view lifecycle
                viewModel.loadData()
            }
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
