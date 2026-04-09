//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct DetachableMacro: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        guard let classDecl = declaration.as(ClassDeclSyntax.self) else {
            throw MacroExpansionErrorMessage("@Detachable can only be applied to classes")
        }

        guard let inheritedTypes = classDecl.inheritanceClause?.inheritedTypes,
              inheritedTypes.contains(where: { $0.type.as(IdentifierTypeSyntax.self)?.name.text == "NSManagedObject" })
        else {
            throw MacroExpansionErrorMessage("@Detachable can only be applied to subclasses of NSManagedObject")
        }

        let varDecls: [VariableDeclSyntax] = classDecl.memberBlock.members.compactMap { member in
            guard let varDecl = member.decl.as(VariableDeclSyntax.self),
                  varDecl.isNotMarked(as: .relation),
                  varDecl.isNotMarked(as: .raw)
            else {
                return nil
            }

            guard varDecl.bindings.count == 1 else {
                let message = MacroExpansionErrorMessage("@​Detachable does not yet support multiple bindings in a single variable declaration")
                context.diagnose(Diagnostic(node: varDecl, message: message))

                return nil
            }

            return varDecl
        }

        let snapshotVarDecls: [VariableDeclSyntax] = varDecls.compactMap { varDecl in
            guard let binding = varDecl.bindings.first,
                  let name = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text
            else {
                let message = MacroExpansionErrorMessage("Failed to extract variable name from declaration")
                context.diagnose(Diagnostic(node: varDecl, message: message))

                return nil
            }

            if name.lowercased().hasSuffix("raw") {
                var newNode = varDecl
                newNode.attributes = [.attribute("\n@Raw")] + newNode.attributes
                
                let message = MacroExpansionWarningMessage("Property '\(name)' appears to be raw, but is not marked with @Raw")
                let fixIt = FixIt.replace(message: MarkWithRaw(), oldNode: varDecl, newNode: newNode)

                context.diagnose(.init(node: varDecl, message: message, fixIt: fixIt))
            }

            return VariableDeclSyntax(
                .let,
                name: binding.pattern.indented(by: .space, indentFirstLine: true),
                type: binding.typeAnnotation
            )
        }

        let snapshotInits: [CodeBlockItemSyntax] = varDecls.compactMap { varDecl in
            guard let binding = varDecl.bindings.first,
                  let name = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text
            else {
                let message = MacroExpansionErrorMessage("Failed to extract variable name from declaration")
                context.diagnose(Diagnostic(node: varDecl, message: message))

                return nil
            }
            return CodeBlockItemSyntax("self.\(raw: name) = model.\(raw: name)")
        }

        return [
            try ExtensionDeclSyntax("extension \(type): Detachable") {
                try StructDeclSyntax("public struct Snapshot: Snapshots.Snapshot") {
                    snapshotVarDecls

                    try InitializerDeclSyntax("public init(model: \(type))") {
                        snapshotInits
                    }
                    .with(\.leadingTrivia, .newlines(2))
                }
            }
        ]
    }

    private struct MarkWithRaw: FixItMessage {
        let message = "Mark with @Raw"
        let fixItID: MessageID = .init(domain: "Snapshots", id: "InsertRawAttribute")
    }
}
