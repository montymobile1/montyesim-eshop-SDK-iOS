// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EsimKit",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "EsimKit",
            targets: ["EsimKit"]
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "EsimKit",
            dependencies: ["ESIMSDK"],
            path: "./Sources/EsimKit"
        ),
        // .binaryTarget(
        //     name: "ESIMSDK",
        //     path: "./Sources/Frameworks/ESIMSDK.xcframework"
        // ),
       .binaryTarget(
           name: "ESIMSDK",
           url: "https://github.com/montymobile1/montyesim-eshop-SDK-iOS/releases/download/1.0.4/ESIMSDK.xcframework.zip",
           checksum: "268ffd5242501d7c2c80a59bb653d7c8ac3c00633d63e3d7b68e04164a6a2f49"
       )
    ]
)
