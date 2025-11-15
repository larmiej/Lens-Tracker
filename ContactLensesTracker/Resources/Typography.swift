//
//  Typography.swift
//  ContactLensesTracker
//
//  Typography definitions and text styling for the application
//  Provides consistent font usage and text styles following iOS design guidelines
//

import SwiftUI

extension Font {
    // MARK: - Display Fonts

    /// Hero display font for the main day counter (48pt, semibold)
    ///
    /// Used for the large day number on the dashboard
    static let hero = Font.system(size: 48, weight: .semibold, design: .rounded)

    // MARK: - Title Fonts

    /// Primary title font for screen headers and section titles (28pt, bold)
    ///
    /// Used for main headings and primary navigation titles
    static let title1 = Font.system(size: 28, weight: .bold, design: .default)

    /// Secondary title font for subsection headers (20pt, semibold)
    ///
    /// Used for card titles, subsection headers, and emphasized content
    static let title2 = Font.system(size: 20, weight: .semibold, design: .default)

    // MARK: - Body Fonts

    /// Standard body text font (17pt, regular)
    ///
    /// Default font for most text content throughout the app
    static let body = Font.system(size: 17, weight: .regular, design: .default)

    /// Emphasized body text font (17pt, semibold)
    ///
    /// Used for labels, emphasized text, and important body content
    static let bodyBold = Font.system(size: 17, weight: .semibold, design: .default)

    // MARK: - Supporting Fonts

    /// Subheadline font for supporting information (15pt, regular)
    ///
    /// Used for secondary information and supporting text
    static let subheadline = Font.system(size: 15, weight: .regular, design: .default)

    /// Caption font for small supplementary text (13pt, regular)
    ///
    /// Used for timestamps, footnotes, and tertiary information
    static let caption = Font.system(size: 13, weight: .regular, design: .default)
}

// MARK: - Text Style Modifiers

extension Text {
    /// Applies hero styling for the main day counter
    ///
    /// Large, bold, rounded numbers with primary color
    ///
    /// - Returns: Styled text view
    func heroStyle() -> Text {
        self.font(.hero)
    }

    /// Applies primary title styling
    ///
    /// Bold, prominent text for main headings
    ///
    /// - Returns: Styled text view
    func title1Style() -> Text {
        self.font(.title1)
    }

    /// Applies secondary title styling
    ///
    /// Semibold text for subsection headers
    ///
    /// - Returns: Styled text view
    func title2Style() -> Text {
        self.font(.title2)
    }

    /// Applies standard body text styling
    ///
    /// Regular weight for most content
    ///
    /// - Returns: Styled text view
    func bodyStyle() -> Text {
        self.font(.body)
    }

    /// Applies emphasized body text styling
    ///
    /// Semibold weight for labels and important content
    ///
    /// - Returns: Styled text view
    func bodyBoldStyle() -> Text {
        self.font(.bodyBold)
    }

    /// Applies subheadline text styling
    ///
    /// Smaller text for secondary information
    ///
    /// - Returns: Styled text view
    func subheadlineStyle() -> Text {
        self.font(.subheadline)
    }

    /// Applies caption text styling
    ///
    /// Small text for supplementary information
    ///
    /// - Returns: Styled text view
    func captionStyle() -> Text {
        self.font(.caption)
    }
}

// MARK: - Preview Helpers

#if DEBUG
extension Font {
    /// Sample fonts for preview and testing purposes
    static let previewFonts: [(name: String, font: Font)] = [
        ("Hero", .hero),
        ("Title 1", .title1),
        ("Title 2", .title2),
        ("Body", .body),
        ("Body Bold", .bodyBold),
        ("Subheadline", .subheadline),
        ("Caption", .caption)
    ]
}
#endif
