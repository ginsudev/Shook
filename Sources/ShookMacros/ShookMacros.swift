//
//  ShookMacros.swift
//  Shook
//
//  Created by Noah Little on 10/8/2026.
//

import Foundation
import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct HookMacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        ClassHookMacro.self,
        HookGroupMacro.self,
        HookMacro.self,
        NewMacro.self,
        PropertyMacro.self
    ]
}
