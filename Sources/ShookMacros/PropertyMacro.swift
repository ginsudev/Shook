//
//  PropertyMacro.swift
//  Shook
//
//  Created by Noah Little on 10/8/2026.
//

import SwiftSyntax
import SwiftDiagnostics
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct PropertyMacro: PeerMacro, AccessorMacro {
    
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        
        guard let varDecl = declaration.as(VariableDeclSyntax.self),
              let binding = varDecl.bindings.first,
              let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text else {
            return []
        }
        
        return [DeclSyntax("private static var \(raw: identifier)Key: UInt8 = 0")]
    }
    
    // MARK: - 2. Generate the Get/Set (AccessorMacro)
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        guard let varDecl = declaration.as(VariableDeclSyntax.self),
              let binding = varDecl.bindings.first,
              let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text else {
            return []
        }
        
        guard let type = binding.typeAnnotation?.type.description else {
            context.diagnose(.init(node: node, message: PropertyMacroError.missingType))
            return []
        }
        
        let policy: String
        if case let .argumentList(arguments) = node.arguments, let first = arguments.first {
            policy = first.expression.description
        } else {
            // Although we have default value so user doesn't need to type it, but SwiftSyntax
            // cannot see default values, so fallback here.
            policy = ".OBJC_ASSOCIATION_RETAIN_NONATOMIC"
        }

        let getAccessor: String
        
        if let initValue = binding.initializer?.value.description {
            getAccessor = """
            get {
                return (objc_getAssociatedObject(target, &Self.\(identifier)Key) as? \(type)) ?? \(initValue)
            }
            """
        } else {
            getAccessor = """
            get {
                return objc_getAssociatedObject(target, &Self.\(identifier)Key) as! \(type)
            }
            """
        }
        
        let setAccessor = """
        set {
            objc_setAssociatedObject(target, &Self.\(identifier)Key, newValue, \(policy))
        }
        """
        
        return [
            AccessorDeclSyntax(stringLiteral: getAccessor),
            AccessorDeclSyntax(stringLiteral: setAccessor)
        ]
    }
}

private enum PropertyMacroError: Error, DiagnosticMessage {
    case missingType

    var message: String {
        switch self {
        case .missingType: "Please specify the type of this property."
        }
    }

    var diagnosticID: MessageID {
        switch self {
        case .missingType:
            MessageID(domain: "ShookMacros", id: "property_missing_type")
        }
    }

    var severity: DiagnosticSeverity {
        .error
    }
}
