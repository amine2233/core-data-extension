import CoreData
import Foundation

final class CoreDataManagerCloudKit: CoreDataManager {
    func clearCoreData() {}

    var mainContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    var writerContext: NSManagedObjectContext {
        persistentContainer.newBackgroundContext()
    }

    var configuration: CoreDataConfiguration
    var persistentContainer: NSPersistentCloudKitContainer

    init(
        configuration: CoreDataConfiguration,
        persistentContainer: NSPersistentCloudKitContainer,
        registerTransformer: (() -> Void)? = nil
    ) {
        self.configuration = configuration
        self.persistentContainer = persistentContainer
        registerTransformer?()
    }

    func newDerivedContext() -> NSManagedObjectContext {
        let context = persistentContainer.newBackgroundContext()
        return context
    }

    func loadContext(completion: @escaping (Result<Void, CoreDataManagerError>) -> Void) {
        if configuration.storeType == .inMemory {
            persistentContainer.persistentStoreDescriptions.first?.url = URL(filePath: "/dev/null")
        }
        persistentContainer.loadPersistentStores { _, error in
            guard let nsError = error as? NSError else { return completion(.success(())) }
            print("Unresolved error \(nsError), \(nsError.userInfo)")
            completion(.failure(.loadPersistentStores(message: nsError.localizedDescription)))
        }
    }
}
