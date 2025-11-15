//
//  ContactLensesTrackerApp.swift
//  ContactLensesTracker
//
//  Main application entry point for ContactLensesTracker
//  iOS 16.0+ SwiftUI application
//

import SwiftUI

/// Main application structure conforming to the App protocol
///
/// This is the entry point for the ContactLensesTracker application.
/// It defines the app's scene hierarchy and initial configuration.
///
/// The app uses a simple WindowGroup scene with ContentView as the root,
/// which handles view model creation, data loading, and navigation setup.
@main
struct ContactLensesTrackerApp: App {
    // MARK: - Scene Configuration

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
