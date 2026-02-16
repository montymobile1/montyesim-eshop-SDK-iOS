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
           url: "https://github.com/montymobile1/montyesim-eshop-SDK-iOS/releases/download/1.0.2/ESIMSDK.xcframework.zip",
           checksum: "955ad59eacf9a968bbd34cb2eb5cd13ea81c4727e20c3703484ac5e8cf662add"
       )
    ]
)
