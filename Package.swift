// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FoodLabelCamera",
    platforms: [
        .iOS(.v16),
        .macOS(.v10_15)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "FoodLabelCamera",
            targets: ["FoodLabelCamera"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pxlshpr/FoodLabelScanner", from: "0.0.82"),
        .package(url: "https://github.com/pxlshpr/SwiftUICamera", from: "0.0.40"),
        .package(url: "https://github.com/pxlshpr/FoodLabel", from: "0.0.30"),
        .package(url: "https://github.com/pxlshpr/VisionSugar", from: "0.0.75"),
        .package(url: "https://github.com/exyte/ActivityIndicatorView", from: "1.1.0"),
        .package(url: "https://github.com/yeahdongcn/RSBarcodes_Swift", from: "5.1.1"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "FoodLabelCamera",
            dependencies: [
                .product(name: "FoodLabelScanner", package: "foodlabelscanner"),
                .product(name: "ActivityIndicatorView", package: "activityindicatorview"),
                .product(name: "VisionSugar", package: "visionsugar"),
                .product(name: "FoodLabel", package: "foodlabel"),
                .product(name: "Camera", package: "swiftuicamera"),
                .product(name: "RSBarcodes_Swift", package: "rsbarcodes_swift"),
            ]),
        .testTarget(
            name: "FoodLabelCameraTests",
            dependencies: ["FoodLabelCamera"]),
    ]
)
