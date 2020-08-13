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

@available(iOSApplicationExtension 13.0, *)
struct TestTree: Equatable, CustomStringConvertible {
    let id: String?
    let typeName: String
    let info: AnyEquatable?
    let subtrees: [TestTree]

    var description: String { description(indent: "", after: "").joined(separator: "\n") }
    private func description(indent: String, after: String) -> [String] {
        var result = ["\(indent)\(subtrees.isEmpty ? "" : "┬") \(id ?? "type: \(typeName)")"]
        for subtree in subtrees.dropLast() {
            result.append(contentsOf: subtree.description(indent: "\(after)├─", after: "\(after)│ "))
        }
        if let subtree = subtrees.last {
            result.append(contentsOf: subtree.description(indent: "\(after)└─", after: "\(after)  "))
        }
        return result
    }

    subscript(_ index: Int) -> TestTree? {
        index < subtrees.count ? subtrees[index] : nil
    }
    subscript(_ id: String) -> TestTree? {
        subtrees.first { $0.id == id }
    }
    subscript<T>(_ type: T.Type) -> TestTree? {
        subtrees.first { $0.typeName == "\(type)" }
    }
}

@available(iOSApplicationExtension 13.0, *)
extension TestTree: PreferenceKey {
    typealias Value = [TestTree]
    static let defaultValue: Value = []
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}

struct AnyEquatable {
    let value: Any
    let isEqual: (Any) -> Bool
    init<E: Equatable>(_ value: E) {
        self.value = value
        isEqual = { value == $0 as? E }
    }
}

extension AnyEquatable: Equatable {
    static func == (lhs: AnyEquatable, rhs: AnyEquatable) -> Bool {
        lhs.isEqual(rhs.value)
    }
}

@available(iOSApplicationExtension 13.0, *)
struct TestIdentifier<Info: Equatable>: ViewModifier {
    @Environment(\.appEnvironment.isTest) var isTest: Bool

    let id: String?
    let typeName: String
    let info: (() -> Info)?

    private var erasedInfo: AnyEquatable? {
        guard let info = info else { return nil}
        return AnyEquatable(info())
    }

    func body(content: Content) -> some View {
        content.transformPreference(TestTree.self) { trees in
            guard self.isTest else { return }
            trees = [TestTree(id: self.id, typeName: self.typeName, info: self.erasedInfo, subtrees: trees)]
        }
    }
}

@available(iOSApplicationExtension 13.0, *)
extension View {
    #if DEBUG
    func testID<Info: Equatable>(_ id: String? = nil, info: @escaping @autoclosure () -> Info) -> some View {
        self.modifier(TestIdentifier(id: id, typeName: "\(type(of: self))", info: info))
    }
    func testID(_ id: String? = nil) -> some View {
        self.modifier(TestIdentifier<Bool>(id: id, typeName: "\(type(of: self))", info: nil))
    }
    #else
    @inlinable
    func testID<Info: Equatable>(_ id: String? = nil, info: @escaping @autoclosure () -> Info) -> some View {
        self
    }
    @inlinable
    func testID(_ id: String? = nil) -> some View {
        self
    }
    #endif
}
