// swift-tools-version: 6.3

import CompilerPluginSupport
@preconcurrency import PackageDescription

let package = Package(
    name: "Async",
    platforms: [
        .iOS(.v18),
        .macOS(.v10_15)
    ],
    products: [
        .library(for: .async),
        .library(for: .asyncExperiments)
    ],
    dependencies: [
        .asyncAlgorithms,
        .combineExt,
        .espresso,
        .swiftCollections,
        .swiftSyntax
    ],
    targets: [
        .async, .unitTests(for: .async),
        .asyncExperiments, .unitTests(for: .asyncExperiments),
        .asyncMacros, .unitTests(for: .asyncMacros)
    ],
    swiftLanguageModes: [.v6]
)

// MARK: Packages

extension Package.Dependency {

    static let asyncAlgorithms: Package.Dependency = .package(
        url: "https://github.com/apple/swift-async-algorithms",
        from: "1.0.0"
    )

    static let combineExt: Package.Dependency = .package(
        url: "https://github.com/CombineCommunity/CombineExt",
        from: "1.0.0"
    )

    static let espresso: Package.Dependency = .package(
        url: "https://github.com/superepicstudios/espresso",
        branch: "dev"
    )

    static let swiftCollections: Package.Dependency = .package(
        url: "https://github.com/apple/swift-collections",
        from: "1.0.0"
    )

    static let swiftSyntax: Package.Dependency = .package(
        url: "https://github.com/swiftlang/swift-syntax.git",
        from: "600.0.0"
    )
}

// MARK: Targets

extension Target {

    static let `async`: Target = .target(
        name: "Async",
        dependencies: [
            .asyncAlgorithms,
            "AsyncMacros",
            .combineExt,
            .espresso,
            .swiftCollections
        ],
        swiftSettings: .default
    )

    static let asyncExperiments: Target = .target(
        name: "AsyncExperiments",
        dependencies: [
            "Async",
            .asyncAlgorithms,
            .combineExt,
            .espresso,
            .swiftCollections
        ],
        swiftSettings: .default
    )

    static let asyncMacros: Target = .macro(
        name: "AsyncMacros",
        dependencies: [
            .swiftSyntax,
            .swiftSyntaxMacros,
            .swiftCompilerPlugin
        ],
        swiftSettings: .default
    )

    static func unitTests(
        for target: Target,
        additionalDependencies: [Target.Dependency] = [],
        resources: [Resource] = []
    ) -> Target {
        .testTarget(
            name: "\(target.name)Tests",
            dependencies: [.target(name: target.name)] + additionalDependencies,
            resources: resources
        )
    }
}

extension Target.Dependency {

    static let asyncAlgorithms: Target.Dependency = .product(
        name: "AsyncAlgorithms",
        package: "swift-async-algorithms"
    )

    static let combineExt: Target.Dependency = .product(
        name: "CombineExt",
        package: "CombineExt"
    )

    static let espresso: Target.Dependency = .product(
        name: "Espresso",
        package: "espresso"
    )

    static let swiftCollections: Target.Dependency = .product(
        name: "Collections",
        package: "swift-collections"
    )

    static let swiftCompilerPlugin: Target.Dependency = .product(
        name: "SwiftCompilerPlugin",
        package: "swift-syntax"
    )

    static let swiftSyntax: Target.Dependency = .product(
        name: "SwiftSyntax",
        package: "swift-syntax"
    )

    static let swiftSyntaxMacros: Target.Dependency = .product(
        name: "SwiftSyntaxMacros",
        package: "swift-syntax"
    )
}

// MARK: Product

extension Product {
    static func library(
        for target: Target,
        type: Library.LibraryType? = nil
    ) -> Product {
        .library(
            name: target.name,
            type: type,
            targets: [target.name]
        )
    }
}

// MARK: Settings

extension SwiftSetting {

    /// Force the use of the `any` keyword for existential types.
    /// See [#0335](https://github.com/apple/swift-evolution/blob/main/proposals/0335-existential-any.md) for more details.
    static let existentialAny: SwiftSetting = .enableUpcomingFeature("ExistentialAny")

    /// Import declarations scoped to `internal` by default.
    /// See [#0409](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0409-access-level-on-imports.md) for more details.
    static let internalImports: SwiftSetting = .enableUpcomingFeature("InternalImportsByDefault")
}

extension [SwiftSetting] {
    static let `default`: [SwiftSetting] = [
        .existentialAny,
        .internalImports
    ]
}
