//
//  NewMacro.swift
//  Shook
//
//  Created by Noah Little on 12/8/2026.
//

import Foundation
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

public struct NewMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let declaration = declaration.as(FunctionDeclSyntax.self) else {
            context.diagnose(Diagnostic(node: node, message: NewMacroError.canOnlyBeAttachedToFunction))
            return []
        }
        
        let isObjcFunc = declaration.attributes.contains { attr in
            attr.as(AttributeSyntax.self)?.attributeName.as(IdentifierTypeSyntax.self)?.name.text == "objc"
        }
        
        guard isObjcFunc else {
            context.diagnose(Diagnostic(node: node, message: NewMacroError.notObjc))
            return []
        }
        
        return []
    }
}

private enum NewMacroError: Error, DiagnosticMessage {
    case notObjc
    case canOnlyBeAttachedToFunction

    var message: String {
        switch self {
        case .notObjc: "@New must be attached to an @objc function"
        case .canOnlyBeAttachedToFunction: "@New can only be attached to a function"
        }
    }

    var diagnosticID: MessageID {
        switch self {
        case .notObjc:
            MessageID(domain: "ShookMacros", id: "new_not_objc")
        case .canOnlyBeAttachedToFunction:
            MessageID(domain: "ShookMacros", id: "new_invalid_decl")
        }
    }

    var severity: DiagnosticSeverity {
        .error
    }
}
