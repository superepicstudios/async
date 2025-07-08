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

        .package(
            url: "https://github.com/superepicstudios/espresso",
            branch: "dev"
        ),

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
                    name: "Espresso",
                    package: "espresso"
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
            resources: [],
            swiftSettings: .modern
        ),

        .testTarget(
            name: "AsyncTests",
            dependencies: ["Async"],
            path: "Sources/AsyncTests",
            swiftSettings: .modern
        ),

        .macro(
            name: "AsyncMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ],
            path: "Sources/AsyncMacros",
            swiftSettings: .modern
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
            swiftSettings: .modern
        )

    ],
    swiftLanguageModes: [.v6]
)

extension [SwiftSetting] {

    static let modern: [SwiftSetting] = [

        .enableUpcomingFeature("ApproachableConcurrency"),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("StrictConcurrency")

    ]

}
