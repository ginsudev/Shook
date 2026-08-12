//
//  HookGroupMacro.swift
//  Shook
//
//  Created by Noah Little on 12/8/2026.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxMacros

public struct HookGroupMacro: MemberMacro {

    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        var registerCalls: [String] = []

        for member in declaration.memberBlock.members {
            let name: String?
            let attributes: AttributeListSyntax

            if let classDecl = member.decl.as(ClassDeclSyntax.self) {
                name = classDecl.name.text
                attributes = classDecl.attributes
            } else if let structDecl = member.decl.as(StructDeclSyntax.self) {
                name = structDecl.name.text
                attributes = structDecl.attributes
            } else if let enumDecl = member.decl.as(EnumDeclSyntax.self) {
                name = enumDecl.name.text
                attributes = enumDecl.attributes
            } else {
                continue
            }

            let hasClassHook = attributes.contains { attr in
                attr.as(AttributeSyntax.self)?.attributeName.as(IdentifierTypeSyntax.self)?.name.text == "ClassHook"
            }

            if hasClassHook, let name {
                registerCalls.append("\(name).activate()")
            }
        }

        let registerMethod = """
        public static func activate() {
            \(registerCalls.joined(separator: "\n\n"))
        }
        """

        return [DeclSyntax(stringLiteral: registerMethod)]
    }
}
