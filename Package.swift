// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UniStorage",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "UniStorage",
            type: .static,
            targets: ["UniStorage"]),
    ],
    dependencies: [
        .package(url: "git@gitee.com:TokenTeam/MMKV.git", from: "2.0.2"),
        .package(url: "git@gitee.com:TokenTeam/MMKVCore.git", from: "2.0.2"),
    ],
    targets: [
        .target(name: "UniStorage", dependencies:["MMKV", "MMKVCore"]),
    ]
)

