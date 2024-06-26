// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "core-data-extension",
    platforms: [.iOS(.v13), .macOS(.v10_15), .watchOS(.v6), .tvOS(.v13), .visionOS(.v1)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "CoreDataExtension",
            targets: ["CoreDataExtension"]),
        .library(
            name: "CoreDataExtensionCombine",
            targets: ["CoreDataExtensionCombine"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "CoreDataExtension",
            dependencies: []),
        .target(
            name: "CoreDataExtensionCombine",
            dependencies: ["CoreDataExtension"]),
        .testTarget(
            name: "CoreDataExtensionTests",
            dependencies: ["CoreDataExtension"]),
        .testTarget(
            name: "CoreDataExtensionCombineTests",
            dependencies: ["CoreDataExtensionCombine"]),
    ]
)
