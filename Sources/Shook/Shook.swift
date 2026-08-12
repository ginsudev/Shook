//
//  Shook.swift
//  Shook
//
//  Created by Noah Little on 9/8/2026.
//

import Foundation

/// Defines a class as a hook container.
@attached(member, names: arbitrary)
public macro ClassHook(_ className: String, type: Any.Type) = #externalMacro(
    module: "ShookMacros",
    type: "ClassHookMacro"
)

/// Marks a function as a method hook.
@attached(peer)
public macro Hook(_ selector: String) = #externalMacro(
    module: "ShookMacros",
    type: "HookMacro"
)

/// Adds a new method to the instance hooked with ClassHook.
@attached(peer)
public macro New(_ selector: String) = #externalMacro(
    module: "ShookMacros",
    type: "NewMacro"
)

/** Adds a property to the instance hooked with ClassHook.
 
 - Warning: A Warning on .OBJC_ASSOCIATION_ASSIGN: Just like in pure Objective-C, using ASSIGN creates a dangling pointer if the stored object is deallocated. It does not act like a Swift weak variable (which safely becomes nil). If you ever need true weak behavior for associated objects, you should store a wrapper object that holds a weak reference, and retain the wrapper with .OBJC_ASSOCIATION_RETAIN_NONATOMIC.
 */
@attached(peer, names: suffixed(Key))
@attached(accessor)
public macro Property(_ policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN) = #externalMacro(
    module: "ShookMacros",
    type: "PropertyMacro"
)

/// Groups multiple @ClassHook types and generates a single activate()
/// entry point that calls each hook class's activate() in order.
@attached(member, names: arbitrary)
public macro HookGroup() = #externalMacro(
    module: "ShookMacros",
    type: "HookGroupMacro"
)
