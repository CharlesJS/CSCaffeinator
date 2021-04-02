// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "CSCaffeinator",
    platforms: [
        .macOS(.v10_10)
    ],
    products: [
        .library(
            name: "CSCaffeinator",
            targets: ["CSCaffeinator"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "CSCaffeinator",
            dependencies: []
        )
    ]
)
