import CoreData
import Foundation

/// A factory for creating instances of `CoreDataManager` based on different configurations.
public enum CoreDataManagerFactory {
    /// Creates a `CoreDataManager` instance for standard CoreData setup.
    ///
    /// - Parameters:
    ///   - configuration: The configuration specifying CoreData setup details.
    /// - Throws: An error of type `CoreDataError` if the persistent container cannot be created.
    /// - Returns: An instance of `CoreDataManager` initialized with the specified configuration and persistent container.
    public static func createCoreDataManager(
        configuration: CoreDataConfiguration,
        registerTransformer: (() -> Void)? = nil
    ) throws -> CoreDataManager {
        let persistentContainer = try NSPersistentContainer.create(configuration: configuration)
        return CoreDataManagerDefault(
            configuration: configuration,
            persistentContainer: persistentContainer,
            registerTransformer: registerTransformer
        )
    }

    /// Creates a `CoreDataManager` instance for CoreData setup with CloudKit integration.
    ///
    /// - Parameters:
    ///   - configuration: The configuration specifying CoreData setup details with CloudKit.
    /// - Throws: An error of type `CoreDataError` if the persistent container with CloudKit cannot be created.
    /// - Returns: An instance of `CoreDataManager` with CloudKit integration, initialized with the specified configuration and persistent container.
    public static func createCoreDataManagerCloudKit(
        configuration: CoreDataConfiguration,
        registerTransformer: (() -> Void)? = nil
    ) throws -> CoreDataManager {
        let persistentContainer = try NSPersistentContainer.createCloudKit(configuration: configuration)
        return CoreDataManagerCloudKit(
            configuration: configuration,
            persistentContainer: persistentContainer,
            registerTransformer: registerTransformer
        )
    }
}

// MARK: - NSManagedObjectModel

extension NSManagedObjectModel {
    /// Creates an NSManagedObjectModel based on the provided configuration and bundle.
    ///
    /// - Parameters:
    ///   - configuration: The configuration specifying CoreData setup details.
    ///   - bundle: The bundle in which the CoreData model file resides. Default is `.coreDataDomain`.
    /// - Throws: An error of type `CoreDataManagerError` if the model cannot be created.
    /// - Returns: An instance of `NSManagedObjectModel` initialized with the specified configuration and bundle.
    static func createManagedObjectModel(
        configuration: CoreDataConfiguration,
        bundle: Bundle = .coreDataDomain
    ) throws -> NSManagedObjectModel {
        let packageBundle = "AppModules_StoragesCoreData.bundle"
        let modelURL = try configuration.modelURL(
            usingBundle: bundle,
            packageName: packageBundle
        )
        guard let url = NSManagedObjectModel(contentsOf: modelURL)
        else { throw CoreDataManagerError.notFoundModelURL }
        return url
    }
}

private final class BundleToken {}

// MARK: - NSPersistentContainer

extension NSPersistentContainer {
    /// Creates a local CoreData NSPersistentContainer.
    ///
    /// - Parameter configuration: The configuration specifying CoreData setup details.
    /// - Returns: An instance of a `NSPersistentContainer`.
    static func create(
        configuration: CoreDataConfiguration
    ) throws -> NSPersistentContainer {
        let container = try NSPersistentContainer(
            name: configuration.appName,
            managedObjectModel: NSManagedObjectModel.createManagedObjectModel(configuration: configuration)
        )
        useAppGroupToSaveData(
            configuration: configuration,
            persistentContainer: container
        )
        return container
    }

    /// Creates a cloudKit CoreData NSPersistentContainer.
    ///
    /// - Parameter configuration: The configuration specifying CoreData setup details.
    /// - Returns: An instance of a `NSPersistentContainer`.
    static func createCloudKit(
        configuration: CoreDataConfiguration
    ) throws -> NSPersistentCloudKitContainer {
        let container = try NSPersistentCloudKitContainer(
            name: configuration.appName,
            managedObjectModel: NSManagedObjectModel.createManagedObjectModel(configuration: configuration)
        )
        useAppGroupToSaveData(
            configuration: configuration,
            persistentContainer: container
        )
        return container
    }

    /// Change the persistentStoreDescriptions url with appGroup url to share the database
    ///
    /// Use this method if you would like to add the ability of sing shared group storage
    /// This will use the group storage only if configuration contain a non empty appGroupName string
    ///
    /// - Parameters:
    ///   - configuration: The configuration
    ///   - persistentContainer: The persistent container core data path
    ///   - fileManager: The file manager
    private static func useAppGroupToSaveData(
        configuration: CoreDataConfiguration,
        persistentContainer: NSPersistentContainer,
        fileManager: FileManager = .default
    ) {
        if !configuration.appGroupName.isEmpty {
            let appGroupURL = {
                let container = fileManager.containerURL(
                    forSecurityApplicationGroupIdentifier: configuration.appGroupName
                )!

                return container.appendingPathComponent(configuration.sqlLitePath)
            }()
            persistentContainer.persistentStoreDescriptions.first?.url = appGroupURL
        }
    }
}
