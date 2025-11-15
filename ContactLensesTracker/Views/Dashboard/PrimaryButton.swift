//
//  PrimaryButton.swift
//  ContactLensesTracker
//
//  Reusable primary action button component
//  Full-width button with consistent styling and interaction feedback
//

import SwiftUI

/// A primary action button with consistent styling and interactions
///
/// This button provides:
/// - Full-width layout with horizontal margins
/// - Two visual states: default (blue) and logged (green with checkmark)
/// - Disabled state when already logged
/// - Scale animation on press for haptic feedback
/// - Proper accessibility labels
///
/// The button follows the design system with 88pt height and 16pt corner radius.
struct PrimaryButton: View {
    // MARK: - Properties

    /// Title text to display on the button
    let title: String

    /// Whether the action has been logged/completed
    let isLogged: Bool

    /// Action to perform when the button is tapped
    let action: () -> Void

    // MARK: - State

    /// Tracks whether button is currently being pressed
    @State private var isPressed = false

    // MARK: - Constants

    /// Height of the button
    private let buttonHeight: CGFloat = 88

    /// Corner radius of the button
    private let cornerRadius: CGFloat = 16

    /// Horizontal padding from screen edges
    private let horizontalPadding: CGFloat = 20

    /// Scale when button is pressed
    private let pressedScale: CGFloat = 0.96

    // MARK: - Computed Properties

    /// Background color based on logged state
    private var backgroundColor: Color {
        if isLogged {
            return .green
        } else {
            return .blue
        }
    }

    /// Icon to display in the button
    private var icon: String? {
        isLogged ? "checkmark" : nil
    }

    /// Whether the button should be disabled
    private var isDisabled: Bool {
        isLogged
    }

    // MARK: - Body

    var body: some View {
        Button(action: {
            // Provide haptic feedback
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()

            // Perform the action
            action()
        }) {
            HStack(spacing: 8) {
                // Icon (if present)
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                }

                // Button title
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: buttonHeight)
            .background(
                backgroundColor.opacity(isDisabled ? 0.6 : 1.0)
            )
            .cornerRadius(cornerRadius)
        }
        .disabled(isDisabled)
        .padding(.horizontal, horizontalPadding)
        .scaleEffect(isPressed ? pressedScale : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressed {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
        .accessibilityLabel(title)
        .accessibilityHint(isLogged ? "Already logged today" : "Double tap to log wear")
        .accessibilityAddTraits(isDisabled ? [.isButton, .isStaticText] : .isButton)
    }
}

// MARK: - Preview Provider

#Preview("Default State") {
    VStack(spacing: 20) {
        PrimaryButton(
            title: "Log Today's Wear",
            isLogged: false,
            action: { print("Button tapped") }
        )
    }
    .padding()
}

#Preview("Logged State") {
    VStack(spacing: 20) {
        PrimaryButton(
            title: "Logged for Today",
            isLogged: true,
            action: { print("Button tapped") }
        )
    }
    .padding()
}

#Preview("Multiple Buttons") {
    VStack(spacing: 20) {
        PrimaryButton(
            title: "Log Today's Wear",
            isLogged: false,
            action: { print("Log tapped") }
        )

        PrimaryButton(
            title: "Logged for Today",
            isLogged: true,
            action: { print("Already logged") }
        )

        PrimaryButton(
            title: "Start New Cycle",
            isLogged: false,
            action: { print("New cycle tapped") }
        )
    }
    .padding()
}

#Preview("Dark Mode") {
    VStack(spacing: 20) {
        PrimaryButton(
            title: "Log Today's Wear",
            isLogged: false,
            action: { print("Button tapped") }
        )

        PrimaryButton(
            title: "Logged for Today",
            isLogged: true,
            action: { print("Button tapped") }
        )
    }
    .padding()
    .preferredColorScheme(.dark)
}
