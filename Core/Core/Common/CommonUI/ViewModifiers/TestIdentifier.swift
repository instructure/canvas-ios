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

import SwiftUI

public struct TestTree {
    public let kind: Kind?
    public let id: String?
    public let type: Any.Type
    public let wrappedInfo: AnyEquatable?
    public let subtrees: [TestTree]

    public var info: Any? { wrappedInfo?.value }
    public func info<E: Equatable>(_ key: String) -> E? {
        (info as? [String: Any])?[key] as? E
    }

    public init<Info: Equatable>(kind: Kind?, id: String?, type: Any.Type, info: Info?, subtrees: [TestTree]) {
        self.kind = kind
        self.id = id
        self.type = type
        self.wrappedInfo = AnyEquatable(info)
        self.subtrees = subtrees
    }

    public struct AnyEquatable {
        public let value: Any
        public let isEqual: (Any) -> Bool

        public init<E: Equatable>(_ value: E) {
            self.value = value
            isEqual = { value == $0 as? E }
        }
        public init?<E: Equatable>(_ value: E?) {
            guard let value = value else { return nil }
            self.init(value)
        }
    }

    /// Roughly equivalent to a CSS class
    public enum Kind: Equatable {
        case cell
        case section
        case text
    }
}

extension TestTree: Equatable {
    public static func == (lhs: TestTree, rhs: TestTree) -> Bool {
        lhs.kind == rhs.kind &&
            lhs.id == rhs.id &&
            String(reflecting: lhs.type) == String(reflecting: rhs.type) &&
            lhs.wrappedInfo == rhs.wrappedInfo &&
            lhs.subtrees == rhs.subtrees
    }
}

extension TestTree: PreferenceKey {
    public typealias Value = [TestTree]
    public static let defaultValue: Value = []
    public static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}

extension TestTree.AnyEquatable: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.isEqual(rhs.value)
    }
}

extension TestTree: CustomStringConvertible {
    public var description: String { description(indent: "", after: "").joined(separator: "\n") }

    private func description(indent: String, after: String) -> [String] {
        var result = ["\(indent)\(subtrees.isEmpty ? "" : "┬") \(id ?? "type: \(String(reflecting: type))")"]
        if let info = info {
            for line in String(reflecting: info).split(separator: "\n") {
                result.append("\(after)\(subtrees.isEmpty ? "" : "│")   \(line)")
            }
        }
        for subtree in subtrees.dropLast() {
            result.append(contentsOf: subtree.description(indent: "\(after)├─", after: "\(after)│ "))
        }
        if let subtree = subtrees.last {
            result.append(contentsOf: subtree.description(indent: "\(after)└─", after: "\(after)  "))
        }
        return result
    }
}

struct TestIdentifier<Info: Equatable>: ViewModifier {
    @Environment(\.appEnvironment.isTest) var isTest: Bool

    let kind: TestTree.Kind?
    let id: String?
    let type: Any.Type
    let info: Info?

    func body(content: Content) -> some View {
        content.transformPreference(TestTree.self) { trees in
            guard self.isTest else { return }
            trees = [TestTree(kind: self.kind, id: self.id, type: self.type, info: self.info, subtrees: trees)]
        }
    }
}

extension View {
    #if DEBUG
    public func testID<Info: Equatable>(_ kind: TestTree.Kind?, id: String? = nil, info: Info) -> some View {
        self.modifier(TestIdentifier(kind: kind, id: id, type: type(of: self), info: info))
    }
    public func testID<Info: Equatable>(_ id: String? = nil, info: Info) -> some View {
        self.modifier(TestIdentifier(kind: nil, id: id, type: type(of: self), info: info))
    }
    public func testID(_ kind: TestTree.Kind? = nil, id: String? = nil) -> some View {
        self.modifier(TestIdentifier<Bool>(kind: kind, id: id, type: type(of: self), info: nil))
    }
    public func testID(_ id: String? = nil) -> some View {
        self.modifier(TestIdentifier<Bool>(kind: nil, id: id, type: type(of: self), info: nil))
    }
    #else
    @inlinable
    public func testID<Info: Equatable>(_ kind: TestTree.Kind?, id: String? = nil, info: Info) -> some View {
        self
    }
    @inlinable
    public func testID<Info: Equatable>(_ id: String? = nil, info: Info) -> some View {
        self
    }
    @inlinable
    public func testID(_ kind: TestTree.Kind? = nil, id: String? = nil) -> some View {
        self
    }
    @inlinable
    public func testID(_ id: String? = nil) -> some View {
        self
    }
    #endif
}

extension Text {
    var verbatim: String? { Mirror(reflecting: self).descendant("storage", "verbatim") as? String }
    var key: String? { Mirror(reflecting: self).descendant("storage", "anyTextStorage", "key", "key") as? String }

    #if DEBUG
    public func testID(_ id: String? = nil) -> some View {
        self.modifier(TestIdentifier(kind: .text, id: id, type: type(of: self), info: ["value": verbatim ?? key]))
    }
    #else
    @inlinable
    public func testID(_ id: String? = nil) -> some View {
        self
    }
    #endif
}
