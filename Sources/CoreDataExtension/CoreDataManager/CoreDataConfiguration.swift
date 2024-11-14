import CoreData
import Foundation

enum CoreDataConfigurationError: Error, Equatable {
    case notFoundModelURL(path: String)
}

public enum CoreDataStoreType {
    case persisted
    case inMemory
}

/// Represents configuration parameters required for setting up CoreData stack.
public struct CoreDataConfiguration {
    /// The name of the application.
    public let appName: String
    /// The name of the CoreData model.
    public let modelName: String
    /// Identifier for the CloudKit container associated with CoreData, if any.
    public let cloudIdentifier: String
    /// The configuration name for the CoreData stack.
    public let configuration: String
    /// The name of the app group used for shared containers, if applicable.
    public let appGroupName: String
    /// The file path to the SQLite database used by CoreData.
    public var sqlLitePath: String {
#if os(OSX)
        return "\(appName)/\(appName).sqlite"
#else
        return "\(appName).sqlite"
#endif
    }

    public let storeType: CoreDataStoreType

    /// Initializes a new `CoreDataConfiguration` instance with the provided parameters.
    ///
    /// - Parameters:
    ///   - appName: The name of the application.
    ///   - modelName: The name of the CoreData model.
    ///   - cloudIdentifier: Identifier for the CloudKit container associated with CoreData.
    ///   - configuration: The configuration name for the CoreData stack.
    ///   - appGroupName: The name of the app group used for shared containers.
    ///   - storeType: The store type if store in database or inside the memory
    public init(
        appName: String,
        modelName: String,
        cloudIdentifier: String,
        configuration: String,
        appGroupName: String,
        storeType: CoreDataStoreType = .persisted
    ) {
        self.appName = appName
        self.modelName = modelName
        self.cloudIdentifier = cloudIdentifier
        self.configuration = configuration
        self.appGroupName = appGroupName
        self.storeType = storeType
    }

    /// The URL to the CoreData model file.
    /// - Parameters:
    ///   - bundle: The bundle
    ///   - packageName: The package name where we can find CoreData model
    /// - Returns: The new URL
    public func modelURL(usingBundle bundle: Bundle, packageName: String) throws -> URL {
        let modelExtension = "momd"
#if os(OSX)
        let path = "/Contents/Resources/\(packageName)/Contents/Resources/\(modelName).\(modelExtension)"
        return bundle.bundleURL.appending(path: path)
#else
        guard let url = bundle.url(
            forResource: modelName,
            withExtension: modelExtension,
            subdirectory: packageName
        ) else {
            let path = bundle.bundleURL.appendingPathComponent(packageName).path()
            throw CoreDataConfigurationError.notFoundModelURL(path: path)
        }
        return url
#endif
    }
}
