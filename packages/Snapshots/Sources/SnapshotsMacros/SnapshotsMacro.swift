import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct DetachableMacro: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        guard let classDecl = declaration.as(ClassDeclSyntax.self) else {
            throw MacroExpansionErrorMessage("'@Detachable' can only be applied to classes")
        }

        guard let inheritedTypes = classDecl.inheritanceClause?.inheritedTypes,
              inheritedTypes.contains(where: { $0.type.as(IdentifierTypeSyntax.self)?.name.text == "NSManagedObject" })
        else {
            throw MacroExpansionErrorMessage("'@Detachable' can only be applied to classes conforming to 'NSManagedObject'")
        }

        let variables: [Variable] = try classDecl.memberBlock.members.compactMap { member in
            guard let varDecl = member.decl.as(VariableDeclSyntax.self),
                  varDecl.isNotMarked(with: "Relation"),
                  varDecl.isNotMarked(with: "Raw"),
                  let binding = varDecl.bindings.first,
                  let type = binding.typeAnnotation?.type.description,
                  let name = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text
            else {
                return nil
            }

            guard varDecl.bindings.count == 1 else {
                throw MacroExpansionErrorMessage("'@Detachable' does not yet support multiple variable bindings in a single declaration")
            }

            if name.lowercased().hasSuffix("raw") {
                var newNode = varDecl
                newNode.attributes = [.attribute("\n@Raw")] + newNode.attributes

                context.diagnose(
                    .init(
                        node: member,
                        message: MacroExpansionWarningMessage("Property '\(name)' appears to be raw, but is not marked with '@Raw'"),
                        fixIt: .replace(
                            message: .insertAttributeArguments,
                            oldNode: varDecl,
                            newNode: newNode
                        )
                    )
                )
            }

            return Variable(name: name, type: type)
        }

        let properties = variables.map { "let \($0.name): \($0.type)" }.joined(separator: "\n")
        let initializers = variables.map { "self.\($0.name) = model.\($0.name)" }.joined(separator: "\n")

        return [try ExtensionDeclSyntax(
            """
            extension \(type): Snapshots.Detachable {
                public struct Snapshot: Snapshots.Snapshot {
                    \(raw: properties)
            
                    public init(model: \(type)) {
                        \(raw: initializers)
                    }
                }
            }
            """
        )]
    }
}

struct Variable {
    let name: String
    let type: String
}

extension VariableDeclSyntax {
    func isMarked(with attributeName: String) -> Bool {
        attributes.contains { $0.as(AttributeSyntax.self)?.attributeName.as(IdentifierTypeSyntax.self)?.name.text == attributeName }
    }

    func isNotMarked(with attributeName: String) -> Bool {
        !isMarked(with: attributeName)
    }
}

public struct RelationMacro: MarkerMacro { }
public struct RawMacro: MarkerMacro { }

protocol MarkerMacro: PeerMacro { }

extension MarkerMacro {
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        []
    }
}

@main
struct SnapshotsPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        DetachableMacro.self,
        RelationMacro.self,
        RawMacro.self
    ]
}
