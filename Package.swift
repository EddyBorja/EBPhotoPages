// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "EBPhotoPagesController",
    products: [
        .library(
            name: "EBPhotoPagesController",
            targets: ["EBPhotoPagesController"])
    ],
    targets: [
        .target(
            name: "EBPhotoPagesController",
            path: "EBPhotoPagesController"
        )
    ]
)
