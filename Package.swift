// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SettingStorageKit",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "SettingStorageKit",
            type: .static,
            targets: ["SettingStorageKit"])
    ],
    dependencies: [
        .package(url: "git@gitee.com:TokenTeam/MMKV.git", from: "2.0.2"),
        .package(url: "git@gitee.com:TokenTeam/MMKVCore.git", from: "2.0.2"),
    ],
    targets: [
        .target(name: "SettingStorageKit", dependencies: ["MMKV", "MMKVCore"])
    ]
)
