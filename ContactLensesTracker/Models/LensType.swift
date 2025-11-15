//
//  LensType.swift
//  ContactLensesTracker
//
//  Enumeration of contact lens types and their replacement schedules
//  Defines standard replacement intervals for different lens types
//

import Foundation

/// Represents the type of contact lens and its replacement schedule
///
/// Contact lenses come in different types with varying replacement schedules:
/// - Daily lenses must be replaced every day (1 day)
/// - Biweekly lenses should be replaced every 14 days
/// - Monthly lenses should be replaced every 30 days
enum LensType: String, CaseIterable, Codable, Sendable {
    /// Single-use daily disposable lenses (1 day)
    case daily

    /// Biweekly replacement lenses (14 days)
    case biweekly

    /// Monthly replacement lenses (30 days)
    case monthly

    // MARK: - Computed Properties

    /// Maximum number of days the lens type can be worn before replacement
    ///
    /// - Returns: Number of days: 1 for daily, 14 for biweekly, 30 for monthly
    var maxDays: Int {
        switch self {
        case .daily:
            return 1
        case .biweekly:
            return 14
        case .monthly:
            return 30
        }
    }

    /// User-friendly display name for the lens type
    ///
    /// - Returns: Localized string suitable for UI display
    var displayName: String {
        switch self {
        case .daily:
            return "Daily"
        case .biweekly:
            return "Biweekly"
        case .monthly:
            return "Monthly"
        }
    }

    /// Detailed description of the replacement schedule
    ///
    /// - Returns: Human-readable description of when to replace lenses
    var scheduleDescription: String {
        switch self {
        case .daily:
            return "Replace every day"
        case .biweekly:
            return "Replace every 14 days"
        case .monthly:
            return "Replace every 30 days"
        }
    }
}

// MARK: - Identifiable Conformance

extension LensType: Identifiable {
    /// Unique identifier for the lens type
    var id: String { rawValue }
}
