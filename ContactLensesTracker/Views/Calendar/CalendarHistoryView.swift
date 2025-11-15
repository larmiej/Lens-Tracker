//
//  CalendarHistoryView.swift
//  ContactLensesTracker
//
//  Calendar view showing wear history with date selection
//  Displays visual indicators for worn days and allows entry management
//

import SwiftUI

/// Calendar view displaying lens wear history
///
/// This view provides a visual calendar interface showing which days lenses
/// were worn, allows selecting specific dates to view details, and provides
/// entry management capabilities. It integrates with the LensTrackerViewModel
/// to display and modify wear history.
struct CalendarHistoryView: View {
    // MARK: - Environment

    /// Main view model for lens tracking
    @Environment(LensTrackerViewModel.self) private var viewModel

    // MARK: - State

    /// Currently selected date in the calendar
    @State private var selectedDate: Date?

    /// Current month being displayed
    @State private var displayedMonth: Date = Date()

    // MARK: - Computed Properties

    /// Dates in the current month
    private var daysInMonth: [Date] {
        guard let range = Calendar.current.range(
            of: .day,
            in: .month,
            for: displayedMonth
        ) else { return [] }

        let firstDayOfMonth = Calendar.current.date(
            from: Calendar.current.dateComponents([.year, .month], from: displayedMonth)
        )!

        return range.compactMap { day in
            Calendar.current.date(byAdding: .day, value: day - 1, to: firstDayOfMonth)
        }
    }

    /// Weekday headers
    private var weekdaySymbols: [String] {
        Calendar.current.shortWeekdaySymbols
    }

    /// First weekday of the month (0 = Sunday, 1 = Monday, etc.)
    private var firstWeekday: Int {
        let firstDay = daysInMonth.first ?? Date()
        return Calendar.current.component(.weekday, from: firstDay) - 1
    }

    /// Set of dates when lenses were worn
    private var wornDates: Set<Date> {
        guard let cycle = viewModel.currentCycle else { return [] }
        return Set(cycle.wearDates.map { Calendar.current.startOfDay(for: $0) })
    }

    /// Recent wear entries sorted by date (most recent first)
    private var recentEntries: [Date] {
        guard let cycle = viewModel.currentCycle else { return [] }
        return cycle.wearDates.sorted(by: >).prefix(10).map { $0 }
    }

    /// Whether the selected date has a wear entry
    private var selectedDateIsWorn: Bool {
        guard let date = selectedDate else { return false }
        let normalizedDate = Calendar.current.startOfDay(for: date)
        return wornDates.contains(normalizedDate)
    }

    /// Cycle day for the selected date if worn
    private var selectedDateCycleDay: Int? {
        guard let date = selectedDate,
              let cycle = viewModel.currentCycle,
              selectedDateIsWorn else { return nil }

        let normalizedDate = Calendar.current.startOfDay(for: date)
        let sortedDates = cycle.wearDates.sorted()

        if let index = sortedDates.firstIndex(of: normalizedDate) {
            return index + 1
        }

        return nil
    }

    /// Formatted month/year string
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: displayedMonth)
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Month navigation
                    monthNavigationHeader

                    // Calendar grid
                    calendarGrid
                        .padding(.horizontal)

                    // Selected date detail card
                    if let date = selectedDate {
                        DateDetailCard(
                            date: date,
                            isWorn: selectedDateIsWorn,
                            cycleDay: selectedDateCycleDay,
                            onRemove: {
                                Task {
                                    await viewModel.removeWearEntry(for: date)
                                }
                            },
                            onAdd: {
                                Task {
                                    await addWearEntry(for: date)
                                }
                            }
                        )
                        .padding(.horizontal)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    // Recent entries list
                    recentEntriesSection
                }
                .padding(.vertical)
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.large)
            .animation(.easeInOut, value: selectedDate)
        }
    }

    // MARK: - Subviews

    /// Month navigation header with previous/next buttons
    private var monthNavigationHeader: some View {
        HStack {
            Button {
                changeMonth(by: -1)
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundStyle(.primary)
            }
            .accessibilityLabel("Previous month")

            Spacer()

            Text(monthYearString)
                .font(.title2)
                .fontWeight(.semibold)

            Spacer()

            Button {
                changeMonth(by: 1)
            } label: {
                Image(systemName: "chevron.right")
                    .font(.title2)
                    .foregroundStyle(.primary)
            }
            .accessibilityLabel("Next month")
        }
        .padding(.horizontal)
    }

    /// Calendar grid showing days of the month
    private var calendarGrid: some View {
        VStack(spacing: 8) {
            // Weekday headers
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible()), count: 7),
                spacing: 8
            ) {
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }

            // Calendar days
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible()), count: 7),
                spacing: 8
            ) {
                // Leading spacers for first week
                ForEach(0..<firstWeekday, id: \.self) { _ in
                    Color.clear
                        .frame(height: 44)
                }

                // Days in month
                ForEach(daysInMonth, id: \.self) { date in
                    dayCell(for: date)
                }
            }
        }
    }

    /// Individual day cell in the calendar
    private func dayCell(for date: Date) -> some View {
        let normalizedDate = Calendar.current.startOfDay(for: date)
        let isWorn = wornDates.contains(normalizedDate)
        let isSelected = selectedDate.map { Calendar.current.isDate($0, inSameDayAs: date) } ?? false
        let isToday = Calendar.current.isDateInToday(date)
        let dayNumber = Calendar.current.component(.day, from: date)

        return Button {
            withAnimation {
                if selectedDate != nil && Calendar.current.isDate(selectedDate!, inSameDayAs: date) {
                    selectedDate = nil
                } else {
                    selectedDate = date
                }
            }
        } label: {
            ZStack {
                // Selection background
                if isSelected {
                    Circle()
                        .fill(Color.lensPrimary)
                } else if isToday {
                    Circle()
                        .stroke(Color.lensPrimary, lineWidth: 2)
                }

                // Day number
                Text("\(dayNumber)")
                    .font(.body)
                    .fontWeight(isToday ? .semibold : .regular)
                    .foregroundStyle(isSelected ? .white : .primary)

                // Wear indicator dot
                if isWorn && !isSelected {
                    Circle()
                        .fill(Color.lensHealthy)
                        .frame(width: 6, height: 6)
                        .offset(y: 14)
                }
            }
            .frame(height: 44)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(dayNumber), \(isWorn ? "worn" : "not worn")")
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }

    /// Recent entries section
    private var recentEntriesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Entries")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.horizontal)

            if recentEntries.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)

                    Text("No wear entries yet")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(Array(recentEntries.enumerated()), id: \.element) { index, date in
                        recentEntryRow(for: date, day: cycleDay(for: date))
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.top, 8)
    }

    /// Individual row in recent entries list
    private func recentEntryRow(for date: Date, day: Int) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(formatDate(date))
                    .font(.body)
                    .fontWeight(.medium)

                Text("Day \(day) of cycle")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Color.lensHealthy)
                .font(.title3)
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .cornerRadius(12)
        .onTapGesture {
            withAnimation {
                selectedDate = date
                scrollToMonth(containing: date)
            }
        }
    }

    // MARK: - Helper Methods

    /// Changes the displayed month
    private func changeMonth(by months: Int) {
        if let newMonth = Calendar.current.date(
            byAdding: .month,
            value: months,
            to: displayedMonth
        ) {
            withAnimation {
                displayedMonth = newMonth
                selectedDate = nil
            }
        }
    }

    /// Scrolls to the month containing the given date
    private func scrollToMonth(containing date: Date) {
        withAnimation {
            displayedMonth = date
        }
    }

    /// Adds a wear entry for the specified date
    private func addWearEntry(for date: Date) async {
        guard let cycle = viewModel.currentCycle else { return }

        let updatedCycle = cycle.addWearEntry(for: date)
        do {
            try await DataManager.shared.updateCycle(updatedCycle)
            await viewModel.loadData()
        } catch {
            viewModel.handleError(error)
        }
    }

    /// Formats a date for display in the recent entries list
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    /// Returns the cycle day number for a given date
    private func cycleDay(for date: Date) -> Int {
        guard let cycle = viewModel.currentCycle else { return 0 }

        let normalizedDate = Calendar.current.startOfDay(for: date)
        let sortedDates = cycle.wearDates.sorted()

        if let index = sortedDates.firstIndex(of: normalizedDate) {
            return index + 1
        }

        return 0
    }
}

// MARK: - Preview Provider

#Preview("With Active Cycle") {
    CalendarHistoryView()
        .environment(LensTrackerViewModel.previewBiweekly)
}

#Preview("No Active Cycle") {
    CalendarHistoryView()
        .environment(LensTrackerViewModel.previewEmpty)
}

#Preview("Overdue Cycle") {
    CalendarHistoryView()
        .environment(LensTrackerViewModel.previewOverdue)
}
