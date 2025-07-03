//
//  MutexMacro.swift
//  Async
//
//  Created by Mitch Treece on 6/15/25.
//  Copyright © 2025 Super Epic Studios, LLC.
//

import Foundation
import SwiftCompilerPlugin
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

fileprivate let macroName: String = "Mutex"
fileprivate let privateVariableTypeName: String = "Mutex"

public struct MutexMacro: PeerMacro, AccessorMacro {
    
    public enum Error: LocalizedError {
        
        case nonVariable
        case missingType
        case missingInitializer
        case internalError

        public var errorDescription: String? {
            
            return switch self {
            case .nonVariable: "@\(macroName) can only be applied to variables"
            case .missingType: "@\(macroName) requires an explicit type declaration"
            case .missingInitializer: "@\(macroName) requires an initial value"
            case .internalError: "@\(macroName) encountered an internal error"
            }
            
        }
        
    }
    
    ///////////////////////////////////////////////
    // MARK: Public Variable
    ///////////////////////////////////////////////
    // @Mutex var value: Int = 0 {
    //     get { ... }
    //     set { ... }
    // }
    ///////////////////////////////////////////////
    
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        
        guard let variable = declaration.as(VariableDeclSyntax.self) else {
            
            // We can only be applied to variables.
            // Throw if we're not a variable declaration.
            
            try error(
                ctx: context,
                node: declaration,
                Error.nonVariable
            )
                        
        }
        
        guard let binding = variable.bindings.first, variable.bindings.count == 1 else {
            
            try error(
                ctx: context,
                node: variable,
                Error.internalError
            )
            
        }
        
        guard let pattern = binding.pattern.as(IdentifierPatternSyntax.self) else {
            
            // We can only be applied to single identifier
            // variables. Throw if we're anything more complex.
            // i.e. tuples, etc.
            
            try error(
                ctx: context,
                node: binding,
                Error.internalError
            )
                        
        }
        
        let privateVariableName = "_\(pattern.identifier.text)"
        var output: [AccessorDeclSyntax] = ["get { \(raw: privateVariableName).withLock { $0 } }"]

        if variable.bindingSpecifier.trimmed.text == "var" {
            output.append("set { \(raw: privateVariableName).withLock { $0 = newValue } }")
        }
        
        return output
        
    }
        
    ///////////////////////////////////////////////
    // MARK: Private Variable
    ///////////////////////////////////////////////
    // private let _value: Mutex<Int> = .init(0)
    // private let _value: Mutex<Int?> = .init(nil)
    ///////////////////////////////////////////////
        
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        
        guard var variables = declaration.as(VariableDeclSyntax.self) else {
            
            // We can only be applied to variables.
            // Throw if we're not a variable declaration.
            
            try error(
                ctx: context,
                node: declaration,
                Error.nonVariable
            )
                        
        }
        
        variables.bindings = try PatternBindingListSyntax(variables.bindings.children(viewMode: .all).map { binding in
                        
            guard var binding = binding.as(PatternBindingSyntax.self) else {
                
                // If we get here we should be inside a `VariableDeclSyntax`,
                // and can cast our bindings to `PatternBindingSyntax`.
                // If we can't, something went wrong.
                                
                try error(
                    ctx: context,
                    node: binding,
                    Error.internalError
                )
                
            }
            
            guard var pattern = binding.pattern.as(IdentifierPatternSyntax.self) else {
                
                // We can only be applied to single identifier
                // variables. Throw if we're anything more complex.
                // i.e. tuples, etc.
                
                try error(
                    ctx: context,
                    node: binding.pattern,
                    Error.internalError
                )
                
            }
                        
            // Add underscore ( _ ) prefix to the private variable's name.
            
            pattern.identifier = "_\(raw: pattern.identifier.text)"
            binding.pattern = PatternSyntax(pattern)
                 
            // Set the private variable's type.
            
            guard var typeAnnotation = binding.typeAnnotation else {
                
                // No explicit variable type provided.
                // We can't infer typings at this point, so it must be provided. i.e.
                // `@Mutex var value = 0` → `@Mutex var value: Int = 0`
                
                try error(
                    ctx: context,
                    node: binding,
                    Error.missingType
                )
                
            }
            
            var type: TypeSyntax!
            var isOptionalType: Bool = false
            
            if let unwrapped = typeAnnotation.type.as(ImplicitlyUnwrappedOptionalTypeSyntax.self) {
                
                // We're working with an implicitly unwrapped optional.
                // We need to back-cast to an actual optional.
                
                type = .init(OptionalTypeSyntax(wrappedType: unwrapped))
                isOptionalType = true
                
            }
            else {
                
                type = typeAnnotation.type
                
                if let _ = typeAnnotation.type.as(OptionalTypeSyntax.self) {
                    isOptionalType = true
                }
                
            }
            
            typeAnnotation.type = "\(raw: privateVariableTypeName)<\(type.trimmed)>"
            binding.typeAnnotation = typeAnnotation
            
            // Set the private variable's initializer.
            
            if var initializer = binding.initializer {
                
                // We have an initial value, i.e.
                // `@Mutex var value: Int = 0`
                
                initializer.value = ".init(\(initializer.value))"
                binding.initializer = initializer
                
            }
            else if isOptionalType {
                
                // We don't have an initial value,
                // but we're an optional. Infer an
                // initial value of `nil`. i.e.
                //
                // `@Mutex var value: Int?`
                
                binding.initializer = .init(value: ".init(nil)" as ExprSyntax)
                
            }
            else {
                
                // We don't have an initial value and we're not an optional, i.e.
                // `@Mutex var value: Int`
                //
                // As of Swift 6.0, there's nothing else we can
                // do here to infer a default value. Once Swift
                // gets support for semantic macros (on the roadmap),
                // we could try to check for protocol conformance to
                // something like `DefaultValueProviding`, i.e.
                //
                // `private let _value: Mutex<String> = .init(.defaultValue)`
                //
                // Using whatever macro api allows for conformance checking.
                // This will probably end up being something similar to:
                //
                // `if context.conforms(typeAnnotation.type, to: "DefaultValueProviding") { ... }`
                //
                // For now, we can't support this use case. Just throw an error.
                
                try error(
                    ctx: context,
                    node: binding,
                    Error.missingInitializer
                )
                
            }
            
            return binding
            
        })
        
        // Remove the @Mutex annotation from the private variable.

        variables.attributes = variables.attributes.filter { attribute in
            
            let annotation = attribute
                .as(AttributeSyntax.self)?
                .attributeName
                .as(IdentifierTypeSyntax.self)?
                .name
                .text
            
            return annotation != privateVariableTypeName
            
        }
                
        // Make the private variable a `let` constant
        
        variables.bindingSpecifier = "let"
        
        // Sanitize the private variable's modifiers.
        
        variables.modifiers = variables.modifiers.filter { modifier in
            
            let name = modifier.trimmed.name.text
            let removedModifiers: Set<String> = ["public", "internal", "fileprivate", "private"]
            let knownModifiers: Set<String> = removedModifiers.union(["nonisolated", "static"])
            
            if !knownModifiers.contains(name) {
                
                warning(
                    ctx: context,
                    node: modifier,
                    "@\(macroName) doesn't support the \"\(name)\" modifier. Ignoring."
                )
                
            }
            
            return !removedModifiers.contains(name)
            
        }
        
        // Make the private variable `private`.
        
        variables.modifiers.insert(
            .init(name: "private"),
            at: variables.modifiers.startIndex
        )
        
        // Done
        
        return [DeclSyntax(variables)]
        
    }
    
    // MARK: Private
    
    private static func error(
        ctx: some MacroExpansionContext,
        node: any SyntaxProtocol,
        _ error: any LocalizedError
    ) throws -> Never {
        
        ctx.diagnose(.init(
            node: node,
            message: MacroExpansionErrorMessage(error.localizedDescription)
        ))
        
        throw error
        
    }
    
    private static func warning(
        ctx: some MacroExpansionContext,
        node: any SyntaxProtocol,
        _ message: String
    ) {
        ctx.diagnose(.init(
            node: node,
            message: MacroExpansionErrorMessage(message)
        ))
    }
    
}
