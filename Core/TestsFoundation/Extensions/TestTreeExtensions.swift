//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

@testable import Core

extension TestTree {

    public struct NotFoundError: Error {
        let description: String
        init(_ description: String = "") {
            self.description = description
        }
    }

    // convenience search methods
    // findAll:  all matches, any descendant
    // find:     first match, any descendant
    // children: all matches, children only
    // child:    first match, children only

    public func findAll(where predicate: (TestTree) throws -> Bool) rethrows -> [TestTree] {
        try subtrees.flatMap { subtree in
            try [subtree].filter(predicate)
                + subtree.findAll(where: predicate)
        }
    }
    public func children(where predicate: (TestTree) throws -> Bool) rethrows -> [TestTree] {
        try subtrees.filter(predicate)
    }

    public func findAll(id: String) -> [TestTree] {
        findAll { $0.id == id }
    }
    public func findAll<T>(_ type: T.Type) -> [TestTree] {
        findAll { $0.type == type }
    }
    public func findAll(kind: Kind) -> [TestTree] {
        findAll { $0.kind == kind }
    }
    public func findAll(_ kind: Kind, id: String) -> [TestTree] {
        findAll { $0.kind == kind && $0.id == id }
    }

    public func find(id: String) -> TestTree? {
        findAll(id: id).first
    }
    public func find<T>(_ type: T.Type) -> TestTree? {
        findAll(type).first
    }
    public func find(kind: Kind) -> TestTree? {
        findAll(kind: kind).first
    }
    public func find(_ kind: Kind, id: String) -> TestTree? {
        findAll(kind, id: id).first
    }

    public func children(id: String) -> [TestTree] {
        children { $0.id == id }
    }
    public func children<T>(_ type: T.Type) -> [TestTree] {
        children { $0.type == type }
    }
    public func children(kind: Kind) -> [TestTree] {
        children { $0.kind == kind }
    }
    public func children(_ kind: Kind, id: String) -> [TestTree] {
        children { $0.kind == kind && $0.id == id }
    }

    public func child(id: String) -> TestTree? {
        children(id: id).first
    }
    public func child<T>(_ type: T.Type) -> TestTree? {
        children(type).first
    }
    public func child(kind: Kind) -> TestTree? {
        children(kind: kind).first
    }
    public func child(_ kind: Kind, id: String) -> TestTree? {
        children(kind, id: id).first
    }

    public subscript(_ index: Int) -> TestTree? {
        index < subtrees.count ? subtrees[index] : nil
    }
}
