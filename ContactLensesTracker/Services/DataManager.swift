//
//  DataManager.swift
//  ContactLensesTracker
//
//  Service managing data persistence and retrieval
//  Thread-safe @MainActor class for managing lens cycle data using UserDefaults
//  FIXED: Changed from actor to @MainActor class - UserDefaults is already thread-safe
//  FIXED: Now stores CycleHistory to prevent loss of historical data
//

import Foundation

/// Errors that can occur during data management operations
enum DataManagerError: LocalizedError {
    case encodingFailed
    case decodingFailed
    case saveFailed
    case noCycleFound

    var errorDescription: String? {
        switch self {
        case .encodingFailed:
            return "Failed to encode lens cycle data"
        case .decodingFailed:
            return "Failed to decode lens cycle data"
        case .saveFailed:
            return "Failed to save lens cycle to storage"
        case .noCycleFound:
            return "No lens cycle found in storage"
        }
    }
}

/// MainActor class providing thread-safe data persistence for lens tracking
///
/// This class manages all data operations for the ContactLensesTracker app,
/// ensuring main-thread access to persistent storage. It uses UserDefaults
/// for simple key-value storage with JSON encoding.
///
/// IMPORTANT: All methods are synchronous now since UserDefaults is already thread-safe
/// and @MainActor ensures consistent main-thread access.
@MainActor
final class DataManager {
    // MARK: - Properties

    /// Shared singleton instance for app-wide data access
    static let shared = DataManager()

    /// UserDefaults instance for persistence
    private let userDefaults: UserDefaults

    /// JSON encoder for serializing data
    private let encoder: JSONEncoder

    /// JSON decoder for deserializing data
    private let decoder: JSONDecoder

    // MARK: - Initialization

    /// Creates a new DataManager instance
    ///
    /// - Parameter userDefaults: UserDefaults instance to use (defaults to .standard)
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults

        // Configure encoder
        self.encoder = JSONEncoder()
        self.encoder.dateEncodingStrategy = .iso8601

        // Configure decoder
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
    }

    // MARK: - Public Methods

    /// Loads the cycle history from storage
    ///
    /// This method retrieves the complete history including current and previous cycles.
    /// It returns nil if no history has been saved yet.
    ///
    /// - Returns: The cycle history, or nil if none exists
    func loadHistory() -> CycleHistory? {
        return loadHistoryFromStorage()
    }

    /// Loads the current lens cycle from storage
    ///
    /// This method retrieves the most recently saved cycle from UserDefaults.
    /// It returns nil if no cycle has been saved yet.
    ///
    /// - Returns: The current lens cycle, or nil if none exists
    func loadCycle() -> LensCycle? {
        return loadHistory()?.currentCycle
    }

    /// Saves a lens cycle to persistent storage
    ///
    /// This method encodes the cycle to JSON and saves it to UserDefaults.
    /// When saving, it preserves all previous cycles in history.
    ///
    /// - Parameter cycle: The lens cycle to save
    /// - Throws: `DataManagerError.encodingFailed` if encoding fails
    /// - Throws: `DataManagerError.saveFailed` if save operation fails
    func saveCycle(_ cycle: LensCycle) throws {
        var history = loadHistory() ?? CycleHistory()
        history.currentCycle = cycle
        try saveHistory(history)
    }

    /// Creates a new lens cycle and saves it
    ///
    /// This method creates a fresh lens cycle with the specified parameters
    /// and immediately persists it to storage. The old cycle is archived to history.
    ///
    /// - Parameters:
    ///   - type: The type of contact lens
    ///   - startDate: The date the cycle begins (defaults to today)
    /// - Returns: The newly created lens cycle
    /// - Throws: `DataManagerError.saveFailed` if save operation fails
    func createNewCycle(
        type: LensType,
        startDate: Date = Date()
    ) throws -> LensCycle {
        let cycle = LensCycle(
            startDate: startDate,
            lensType: type,
            wearDates: []
        )

        // Archive old cycle and save new one
        var history = loadHistory() ?? CycleHistory()
        history.archiveAndStartNew(cycle)
        try saveHistory(history)

        return cycle
    }

    /// Updates an existing lens cycle
    ///
    /// This method replaces the current cycle with the provided updated cycle.
    /// It's typically used after adding or removing wear dates.
    ///
    /// - Parameter cycle: The updated lens cycle to save
    /// - Throws: `DataManagerError.saveFailed` if save operation fails
    func updateCycle(_ cycle: LensCycle) throws {
        try saveCycle(cycle)
    }

    /// Deletes the current lens cycle (preserves history)
    ///
    /// This method removes the current cycle but keeps all archived cycles.
    func deleteCycle() {
        var history = loadHistory() ?? CycleHistory()
        if let current = history.currentCycle {
            history.previousCycles.append(current)
            history.currentCycle = nil
            try? saveHistory(history)
        }
    }

    /// Checks if a lens cycle currently exists
    ///
    /// - Returns: `true` if a cycle exists in storage, `false` otherwise
    func hasCycle() -> Bool {
        return loadCycle() != nil
    }

    // MARK: - Private Methods

    /// Saves the complete cycle history to UserDefaults
    ///
    /// Made public for future use cases that need direct history manipulation.
    ///
    /// - Parameter history: The cycle history to save
    /// - Throws: `DataManagerError.encodingFailed` or `DataManagerError.saveFailed`
    func saveHistory(_ history: CycleHistory) throws {
        do {
            let data = try encoder.encode(history)
            userDefaults.set(data, forKey: StorageKeys.cycleHistory)
        } catch is EncodingError {
            throw DataManagerError.encodingFailed
        } catch {
            throw DataManagerError.saveFailed
        }
    }

    /// Loads cycle history from UserDefaults
    ///
    /// - Returns: Decoded cycle history, or nil if not found or decoding fails
    private func loadHistoryFromStorage() -> CycleHistory? {
        // Retrieve data from UserDefaults
        guard let data = userDefaults.data(forKey: StorageKeys.cycleHistory) else {
            // Try migrating from old single-cycle storage
            return migrateLegacyData()
        }

        // Attempt to decode
        do {
            let history = try decoder.decode(CycleHistory.self, from: data)
            return history
        } catch {
            // Log decoding error in debug builds
            #if DEBUG
            print("Failed to decode cycle history: \(error)")
            #endif
            return migrateLegacyData()
        }
    }

    /// Migrates data from old single-cycle storage format
    ///
    /// - Returns: CycleHistory with migrated data, or nil if no legacy data exists
    private func migrateLegacyData() -> CycleHistory? {
        guard let data = userDefaults.data(forKey: StorageKeys.legacyCurrentCycle) else {
            return nil
        }

        do {
            let cycle = try decoder.decode(LensCycle.self, from: data)
            let history = CycleHistory(currentCycle: cycle, previousCycles: [])

            // Save in new format and remove old key
            try? saveHistory(history)
            userDefaults.removeObject(forKey: StorageKeys.legacyCurrentCycle)

            #if DEBUG
            print("Successfully migrated legacy cycle data to new history format")
            #endif

            return history
        } catch {
            #if DEBUG
            print("Failed to migrate legacy data: \(error)")
            #endif
            return nil
        }
    }
}

// MARK: - Storage Keys

private extension DataManager {
    /// Keys used for UserDefaults storage
    enum StorageKeys {
        /// Key for storing the cycle history (new format)
        static let cycleHistory = "cycleHistory"

        /// Legacy key for single cycle storage (for migration)
        static let legacyCurrentCycle = "currentLensCycle"
    }
}

// MARK: - Testing Support

#if DEBUG
extension DataManager {
    /// Creates a DataManager instance with a test UserDefaults suite
    ///
    /// This convenience initializer creates an isolated UserDefaults instance
    /// for testing purposes, preventing test data from polluting real user data.
    ///
    /// - Parameter suiteName: Name for the test suite (defaults to a unique name)
    /// - Returns: DataManager configured for testing
    static func makeTestInstance(suiteName: String = "TestSuite") -> DataManager {
        let testDefaults = UserDefaults(suiteName: suiteName)!
        // Clear any existing data
        testDefaults.removePersistentDomain(forName: suiteName)
        return DataManager(userDefaults: testDefaults)
    }

    /// Resets all stored data (for testing only)
    func resetAllData() {
        userDefaults.removeObject(forKey: StorageKeys.cycleHistory)
        userDefaults.removeObject(forKey: StorageKeys.legacyCurrentCycle)
    }
}
#endif
