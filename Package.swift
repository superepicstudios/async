// swift-tools-version: 6.0

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "Async",
    platforms: [

        .iOS(.v18),
        .macOS(.v15)

    ],
    products: [

        .library(
            name: "Async",
            targets: ["Async"]
        )

    ],
    dependencies: [

        .package(path: "../../private/modern/secommon-swift"),

        .package(
            url: "https://github.com/apple/swift-async-algorithms",
            from: "1.0.0"
        ),

        .package(
            url: "https://github.com/apple/swift-collections",
            from: "1.0.0"
        ),

        .package(
            url: "https://github.com/swiftlang/swift-syntax.git",
            "509.0.0"..<"601.0.0"
        )

    ],
    targets: [

        .target(
            name: "Async",
            dependencies: [

                .target(name: "AsyncMacros"),

                .product(
                    name: "SECommon",
                    package: "secommon-swift"
                ),

                .product(
                    name: "AsyncAlgorithms",
                    package: "swift-async-algorithms"
                ),

                .product(
                    name: "Collections",
                    package: "swift-collections"
                )

            ],
            path: "Sources/Async",
            resources: []
        ),

        .testTarget(
            name: "AsyncTests",
            dependencies: ["Async"],
            path: "Sources/AsyncTests"
        ),

        .macro(
            name: "AsyncMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ],
            path: "Sources/AsyncMacros",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),

        .testTarget(
            name: "AsyncMacrosTests",
            dependencies: [

                .target(name: "AsyncMacros"),

                .product(
                    name: "SwiftSyntaxMacrosTestSupport",
                    package: "swift-syntax"
                )

            ],
            path: "Sources/AsyncMacrosTests",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        )

    ],
    swiftLanguageModes: [.v6]
)
