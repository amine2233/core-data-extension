import CoreData
import Foundation

/// A protocol defining methods for managing CoreData operations.
public protocol CoreDataManager {
    /// The configuration used by the Core Data manager.
    var configuration: CoreDataConfiguration { get }

    /// The main managed object context for CoreData operations.
    var mainContext: NSManagedObjectContext { get }

    /// The writer managed object context for CoreData operations to create, update and delete.
    var writerContext: NSManagedObjectContext { get }

    /// Load the main managed object context.
    func load()

    /// Asynchronously loads the main managed object context.
    ///
    /// Once the persistent container has been initialized, you need to execute loadPersistentStores(completionHandler:)
    /// to instruct the container to load the persistent stores and complete the creation of the Core Data stack.
    /// Once the completion handler has fired, the stack is fully initialized and is ready for use.
    /// The completion handler will be called once for each persistent store that is created.
    /// If there is an error in the loading of the persistent stores, the NSError value will be populated.
    ///
    /// - Parameter completion: Once the loading of the persistent stores has completed, this block will be executed on the calling thread.
    func loadContext(completion: @escaping (Result<Void, CoreDataManagerError>) -> Void)

    /// Asynchronously saves changes in the main managed object context.
    ///
    /// - Parameter completion: A closure called after the context has been saved or if an error occurs.
    func saveContext(completion: @escaping (Result<Void, CoreDataManagerError>) -> Void)

    /// Asynchronously saves changes in the provided managed object context.
    ///
    /// - Parameters:
    ///   - context: The managed object context to save.
    ///   - completion: A closure called after the context has been saved or if an error occurs.
    func saveContext(_ context: NSManagedObjectContext, completion: @escaping (Result<Void, CoreDataManagerError>) -> Void)

    /// Creates and returns a new derived managed object context.
    ///
    /// - Returns: A new derived managed object context.
    func newDerivedContext() -> NSManagedObjectContext

    /// Clears all data from CoreData associated with the current configuration.
    func clearCoreData()

    /// Save changes
    func save() throws
}

extension CoreDataManager {
    // MARK: Load context

    func load() {
        loadContext(completion: { _ in })
    }

    // MARK: Load context async

    func loadContext() async throws {
        try await withUnsafeThrowingContinuation { continuation in
            loadContext { result in
                continuation.resume(with: result)
            }
        }
    }

    // MARK: Save context

    func saveContext(
        completion: @escaping (Result<Void, CoreDataManagerError>) -> Void
    ) {
        saveContext(writerContext, completion: completion)
    }

    func saveContext(
        _ context: NSManagedObjectContext,
        completion: @escaping (Result<Void, CoreDataManagerError>) -> Void
    ) {
        context.perform {
            do {
                try context.save()
                completion(.success(()))
            } catch let error as NSError {
                print("Unresolved error \(error), \(error.userInfo)")
                completion(.failure(.saveContext(message: error.localizedDescription)))
            }
        }
    }

    func save() throws {
        try writerContext.save()
    }
    
    // MARK: Save context async

    func saveContext() async throws {
        try await withUnsafeThrowingContinuation { continuation in
            saveContext { result in
                continuation.resume(with: result)
            }
        }
    }

    func saveContext(_ context: NSManagedObjectContext) async throws {
        try await withUnsafeThrowingContinuation { continuation in
            saveContext(context) { result in
                continuation.resume(with: result)
            }
        }
    }
}
