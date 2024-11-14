import Foundation

extension Bundle {
    /// Get `Entities` bundle
    public static let coreDataDomain: Bundle = Bundle(for: BundleToken.self)
}

private final class BundleToken {}
