import Foundation

/// Errors that can occur within the `CoreDataManager` operations.
public enum CoreDataManagerError: Error, Equatable {
    /// Indicates that the model URL for CoreData could not be found.
    case notFoundModelURL

    /// Indicates an error while loading persistent stores in CoreData.
    ///
    /// - Parameters:
    ///   - message: A descriptive message explaining the load error.
    case loadPersistentStores(message: String)

    /// Indicates an error while saving the main context in CoreData.
    ///
    /// - Parameters:
    ///   - message: A descriptive message explaining the save context error.
    case saveContext(message: String)

    /// Indicates an error related to the manager's object model in CoreData.
    case managerObjectModel

    /// Indicates that the migration URL for CoreData could not be found.
    case migrationUrlNotFound

    /// Indicates a general migration error in CoreData.
    case migration
}
