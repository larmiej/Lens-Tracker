//
//  DataManager.swift
//  ContactLensesTracker
//
//  Service managing data persistence and retrieval
//  Thread-safe actor for managing lens cycle data using UserDefaults
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

/// Actor providing thread-safe data persistence for lens tracking
///
/// This actor manages all data operations for the ContactLensesTracker app,
/// ensuring thread-safe access to persistent storage. It uses UserDefaults
/// for simple key-value storage with JSON encoding.
///
/// All methods are async to maintain actor isolation and prevent data races.
actor DataManager {
    // MARK: - Properties

    /// Shared singleton instance for app-wide data access
    static let shared = DataManager()

    /// Current active lens cycle
    private var currentCycle: LensCycle?

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

        // Note: currentCycle is loaded lazily on first access
        // This avoids actor isolation issues in the initializer
    }

    // MARK: - Public Methods

    /// Loads the current lens cycle from storage
    ///
    /// This method retrieves the most recently saved cycle from UserDefaults.
    /// It returns nil if no cycle has been saved yet.
    ///
    /// - Returns: The current lens cycle, or nil if none exists
    func loadCycle() async -> LensCycle? {
        // Return cached cycle if available
        if let cycle = currentCycle {
            return cycle
        }

        // Otherwise load from storage
        currentCycle = await loadCycleFromStorage()
        return currentCycle
    }

    /// Saves a lens cycle to persistent storage
    ///
    /// This method encodes the cycle to JSON and saves it to UserDefaults.
    /// It also updates the in-memory cache for faster access.
    ///
    /// - Parameter cycle: The lens cycle to save
    /// - Throws: `DataManagerError.encodingFailed` if encoding fails
    /// - Throws: `DataManagerError.saveFailed` if save operation fails
    func saveCycle(_ cycle: LensCycle) async throws {
        do {
            // Encode cycle to JSON data
            let data = try encoder.encode(cycle)

            // Save to UserDefaults
            userDefaults.set(data, forKey: StorageKeys.currentCycle)

            // Synchronize to ensure write completes
            guard userDefaults.synchronize() else {
                throw DataManagerError.saveFailed
            }

            // Update in-memory cache
            currentCycle = cycle

        } catch is EncodingError {
            throw DataManagerError.encodingFailed
        } catch {
            throw DataManagerError.saveFailed
        }
    }

    /// Creates a new lens cycle and saves it
    ///
    /// This method creates a fresh lens cycle with the specified parameters
    /// and immediately persists it to storage.
    ///
    /// - Parameters:
    ///   - type: The type of contact lens
    ///   - startDate: The date the cycle begins (defaults to today)
    /// - Returns: The newly created lens cycle
    /// - Throws: `DataManagerError.saveFailed` if save operation fails
    func createNewCycle(
        type: LensType,
        startDate: Date = Date()
    ) async throws -> LensCycle {
        let cycle = LensCycle(
            startDate: startDate,
            lensType: type,
            wearDates: []
        )

        try await saveCycle(cycle)
        return cycle
    }

    /// Updates an existing lens cycle
    ///
    /// This method replaces the current cycle with the provided updated cycle.
    /// It's typically used after adding or removing wear dates.
    ///
    /// - Parameter cycle: The updated lens cycle to save
    /// - Throws: `DataManagerError.saveFailed` if save operation fails
    func updateCycle(_ cycle: LensCycle) async throws {
        try await saveCycle(cycle)
    }

    /// Deletes the current lens cycle
    ///
    /// This method removes the cycle from both memory and persistent storage.
    func deleteCycle() async {
        currentCycle = nil
        userDefaults.removeObject(forKey: StorageKeys.currentCycle)
        userDefaults.synchronize()
    }

    /// Checks if a lens cycle currently exists
    ///
    /// - Returns: `true` if a cycle exists in storage, `false` otherwise
    func hasCycle() async -> Bool {
        if currentCycle != nil {
            return true
        }

        return await loadCycleFromStorage() != nil
    }

    // MARK: - Private Methods

    /// Loads cycle data from UserDefaults
    ///
    /// - Returns: Decoded lens cycle, or nil if not found or decoding fails
    private func loadCycleFromStorage() async -> LensCycle? {
        // Retrieve data from UserDefaults
        guard let data = userDefaults.data(forKey: StorageKeys.currentCycle) else {
            return nil
        }

        // Attempt to decode
        do {
            let cycle = try decoder.decode(LensCycle.self, from: data)
            return cycle
        } catch {
            // Log decoding error in debug builds
            #if DEBUG
            print("Failed to decode lens cycle: \(error)")
            #endif
            return nil
        }
    }
}

// MARK: - Storage Keys

private extension DataManager {
    /// Keys used for UserDefaults storage
    enum StorageKeys {
        /// Key for storing the current lens cycle
        static let currentCycle = "currentLensCycle"
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
    func resetAllData() async {
        currentCycle = nil
        userDefaults.removeObject(forKey: StorageKeys.currentCycle)
        userDefaults.synchronize()
    }
}
#endif
