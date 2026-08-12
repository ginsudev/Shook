//
//  ClassHookMacro.swift
//  Shook
//
//  Created by Noah Little on 9/8/2026.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

// MARK: - Processing Result

private struct HookProcessingResult {
    var generatedMembers: [DeclSyntax] = []
    var origStructMethods: [String] = []
    var registerCalls: [String] = []
}

// MARK: - ClassHook Macro

public struct ClassHookMacro: MemberMacro {

    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // Ensure it's attached to a class
        guard let classDecl = declaration.as(ClassDeclSyntax.self) else {
            return []
        }

        // Extract arguments from @ClassHook("Target", type: Target.self)
        guard case let .argumentList(arguments) = node.arguments,
              let classNameArg = arguments.first,
              let typeArg = arguments.dropFirst().first else {
            return []
        }

        let targetClassName = classNameArg.expression.description.replacingOccurrences(of: "\"", with: "")
        let targetType = typeArg.expression.description.replacingOccurrences(of: ".self", with: "")

        var generatedMembers: [DeclSyntax] = []

        // Base properties
        generatedMembers.append(DeclSyntax("public let target: \(raw: targetType)"))
        generatedMembers.append(DeclSyntax("public var orig: Orig { Orig(target: target) }"))
        generatedMembers.append(DeclSyntax("public required init(target: \(raw: targetType)) { self.target = target }"))

        // Process @Hook functions
        let hookResult = processHookFunctions(from: classDecl, targetType: targetType)
        generatedMembers.append(contentsOf: hookResult.generatedMembers)

        // Process @New functions
        let newResult = processNewFunctions(from: classDecl, targetType: targetType)
        generatedMembers.append(contentsOf: newResult.generatedMembers)

        // Assemble the Orig struct (only @Hook methods have originals)
        let origStruct = """
        public struct Orig {
            let target: \(targetType)
            \(hookResult.origStructMethods.joined(separator: "\n\n"))
        }
        """
        generatedMembers.append(DeclSyntax(stringLiteral: origStruct))

        // Assemble the static activate() method
        let allRegisterCalls = hookResult.registerCalls + newResult.registerCalls
        let registerMethod = """
        public static func activate() {
            guard let cls = NSClassFromString("\(targetClassName)") else {
                NSLog("Failed to find class \(targetClassName)")
                return
            }
            \(allRegisterCalls.joined(separator: "\n\n"))
        }
        """
        generatedMembers.append(DeclSyntax(stringLiteral: registerMethod))

        return generatedMembers
    }

    // MARK: - @Hook Processing

    private static func processHookFunctions(
        from classDecl: ClassDeclSyntax,
        targetType: String
    ) -> HookProcessingResult {
        var result = HookProcessingResult()
        let functions = classDecl.memberBlock.members.compactMap { $0.decl.as(FunctionDeclSyntax.self) }

        for funcDecl in functions {
            guard let hookAttribute = funcDecl.attributes.first(where: {
                $0.as(AttributeSyntax.self)?.attributeName.description == "Hook"
            })?.as(AttributeSyntax.self),
            case let .argumentList(hookArgs) = hookAttribute.arguments,
            let selectorArg = hookArgs.first else {
                continue
            }

            let selectorString = selectorArg.expression.description.replacingOccurrences(of: "\"", with: "")
            let funcName = funcDecl.name.text
            let impVarName = "orig_\(funcName)_IMP"

            result.generatedMembers.append(DeclSyntax("nonisolated(unsafe) static var \(raw: impVarName): IMP?"))

            let params = funcDecl.signature.parameterClause.parameters
            let paramNames = params.map { $0.secondName?.text ?? $0.firstName.text }
            let paramListForOrig = params.map { "\($0.firstName.text) \($0.secondName?.text ?? $0.firstName.text): \($0.type.description)" }.joined(separator: ", ")
            let cParamTypes = (["\(targetType)", "Selector"] + params.map { $0.type.description }).joined(separator: ", ")

            let returnType = funcDecl.signature.returnClause?.type.description ?? "Void"

            let origMethodCallArgs = (["target", "NSSelectorFromString(\"\(selectorString)\")"] + paramNames).joined(separator: ", ")
            let origMethod = """
            func \(funcName)(\(paramListForOrig)) -> \(returnType) {
                typealias Fn = @convention(c) (\(cParamTypes)) -> \(returnType)
                let imp = \(classDecl.name.text).\(impVarName)!
                let fn = unsafeBitCast(imp, to: Fn.self)
                return fn(\(origMethodCallArgs))
            }
            """
            result.origStructMethods.append(origMethod)

            let blockParams = (["_ slf: \(targetType)"] + params.enumerated().map { index, param in
                "_ arg\(index): \(param.type.description)"
            }).joined(separator: ", ")

            let instanceCallArgs = params.enumerated().map { index, param in
                if param.firstName.text == "_" {
                    return "arg\(index)"
                } else {
                    return "\(param.firstName.text): arg\(index)"
                }
            }.joined(separator: ", ")

            let closureArgs = params.enumerated().map { "arg\($0.0)" }.joined(separator: ", ")
            let closureIn = closureArgs.isEmpty ? "slf in" : "slf, \(closureArgs) in"

            let registerCall = """
            let sel_\(funcName) = NSSelectorFromString("\(selectorString)")
            let block_\(funcName): @convention(block) (\(blockParams)) -> \(returnType) = { \(closureIn)
                let hookInstance = \(classDecl.name.text)(target: slf)
                return hookInstance.\(funcName)(\(instanceCallArgs))
            }
            let new_\(funcName)_IMP = imp_implementationWithBlock(block_\(funcName))
            MSHookMessageEx(cls, sel_\(funcName), new_\(funcName)_IMP, &\(impVarName))
            """
            result.registerCalls.append(registerCall)
        }

        return result
    }

    // MARK: - @New Processing

    private static func processNewFunctions(
        from classDecl: ClassDeclSyntax,
        targetType: String
    ) -> HookProcessingResult {
        var result = HookProcessingResult()
        let functions = classDecl.memberBlock.members.compactMap { $0.decl.as(FunctionDeclSyntax.self) }

        for funcDecl in functions {
            guard let newAttribute = funcDecl.attributes.first(where: {
                $0.as(AttributeSyntax.self)?.attributeName.description == "New"
            })?.as(AttributeSyntax.self),
            case let .argumentList(newArgs) = newAttribute.arguments,
            let selectorArg = newArgs.first else {
                continue
            }

            let selectorString = selectorArg.expression.description.replacingOccurrences(of: "\"", with: "")
            let funcName = funcDecl.name.text
            let params = funcDecl.signature.parameterClause.parameters
            let returnType = funcDecl.signature.returnClause?.type.description ?? "Void"

            // Build block parameter signature
            let blockParams = (["_ slf: \(targetType)"] + params.enumerated().map { index, param in
                "_ arg\(index): \(param.type.description)"
            }).joined(separator: ", ")

            // Build instance call args
            let instanceCallArgs = params.enumerated().map { index, param in
                if param.firstName.text == "_" {
                    return "arg\(index)"
                } else {
                    return "\(param.firstName.text): arg\(index)"
                }
            }.joined(separator: ", ")

            let closureArgs = params.enumerated().map { "arg\($0.0)" }.joined(separator: ", ")
            let closureIn = closureArgs.isEmpty ? "slf in" : "slf, \(closureArgs) in"

            let registerCall = """
            let sel_\(funcName) = NSSelectorFromString("\(selectorString)")
            let block_\(funcName): @convention(block) (\(blockParams)) -> \(returnType) = { \(closureIn)
                let hookInstance = \(classDecl.name.text)(target: slf)
                return hookInstance.\(funcName)(\(instanceCallArgs))
            }
            let imp_\(funcName) = imp_implementationWithBlock(block_\(funcName))
            if let m = class_getInstanceMethod(\(classDecl.name.text).self, sel_\(funcName)) {
                class_addMethod(cls, sel_\(funcName), imp_\(funcName), method_getTypeEncoding(m))
            }
            """
            result.registerCalls.append(registerCall)
        }

        return result
    }
}
