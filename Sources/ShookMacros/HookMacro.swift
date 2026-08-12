//
//  HookMacro.swift
//  Shook
//
//  Created by Noah Little on 10/8/2026.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxMacros

public struct HookMacro: PeerMacro {
    
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        []
    }
}
