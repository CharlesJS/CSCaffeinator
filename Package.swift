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
    dependencies: [
        .package(url: "https://github.com/CharlesJS/CSErrors", from: "0.3.0")
    ],
    targets: [
        .target(
            name: "CSCaffeinator",
            dependencies: [
                "CSErrors"
            ]
        )
    ]
)
