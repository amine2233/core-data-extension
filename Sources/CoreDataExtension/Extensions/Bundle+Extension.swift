import Foundation

extension Bundle {
    /// Get `Entities` bundle
    public static var coreDataDomain: Bundle {
        Bundle(for: BundleToken.self)
    }
}

private final class BundleToken {}
