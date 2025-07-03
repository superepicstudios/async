//
//  Plugin.swift
//  AsyncMacros
//
//  Created by Mitch Treece on 7/1/25.
//  Copyright © 2025 Super Epic Studios, LLC.
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct AsyncMacrosPlugin: CompilerPlugin {

    var providingMacros: [any Macro.Type] = [
        MutexMacro.self
    ]

}
