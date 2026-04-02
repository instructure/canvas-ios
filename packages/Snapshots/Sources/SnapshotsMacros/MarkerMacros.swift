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
import SwiftSyntaxMacros

public struct RelationMacro: MarkerMacro {
    let syntax = "Relation"
}
public struct RawMacro: MarkerMacro {
    let syntax = "Raw"
}

protocol MarkerMacro: PeerMacro {
    var syntax: String { get }
}

extension MarkerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        []
    }
}

extension MarkerMacro where Self == RelationMacro {
    static var relation: Self { RelationMacro() }
}

extension MarkerMacro where Self == RawMacro {
    static var raw: Self { RawMacro() }
}

extension VariableDeclSyntax {
    func isMarked(as markerMacro: MarkerMacro) -> Bool {
        attributes.contains { attribute in
            let attributeName = attribute.as(AttributeSyntax.self)?.attributeName.as(IdentifierTypeSyntax.self)?.name.text

            return attributeName == markerMacro.syntax
        }
    }

    func isNotMarked(as markerMacro: MarkerMacro) -> Bool {
        !isMarked(as: markerMacro)
    }
}
