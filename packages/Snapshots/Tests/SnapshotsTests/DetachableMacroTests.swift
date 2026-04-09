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
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(SnapshotsMacros)
import SnapshotsMacros

let testMacros: [String: Macro.Type] = [
    "Detachable": DetachableMacro.self,
]
#endif

final class DetachableMacroTests: XCTestCase {
    func testNoClassThrowsError() throws {
        #if canImport(SnapshotsMacros)
        assertMacroExpansion(
            """
            @Detachable
            struct TestModel { }
            """,
            expandedSource: """
            struct TestModel { }
            """,
            diagnostics: [.init(
                message: "@Detachable can only be applied to classes",
                line: 1,
                column: 1
            )],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testNotNSManagedObjectSubclassThrowsError() throws {
        #if canImport(SnapshotsMacros)
        assertMacroExpansion(
            """
            @Detachable
            final class TestModel { }
            """,
            expandedSource: """
            final class TestModel { }
            """,
            diagnostics: [.init(
                message: "@Detachable can only be applied to subclasses of NSManagedObject",
                line: 1,
                column: 1
            )],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testMultiplBindingsThrowsError() throws {
        #if canImport(SnapshotsMacros)
        assertMacroExpansion(
            """
            @Detachable
            final class TestModel: NSManagedObject { 
                @NSManaged var id, name: String
            }
            """,
            expandedSource: """
            final class TestModel: NSManagedObject { 
                @NSManaged var id, name: String
            }
            
            extension TestModel: Detachable {
                public struct Snapshot: Snapshots.Snapshot {
            
                    public init(model: TestModel) {
                    }
                }
            }
            """,
            diagnostics: [.init(
                message: "@​Detachable does not yet support multiple bindings in a single variable declaration",
                line: 3,
                column: 5
            )],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testPrimitiveProperty() throws {
        #if canImport(SnapshotsMacros)
        assertMacroExpansion(
            """
            @Detachable
            final class TestModel: NSManagedObject {
                @NSManaged var id: String
            }
            """,
            expandedSource: """
            final class TestModel: NSManagedObject {
                @NSManaged var id: String
            }
            
            extension TestModel: Detachable {
                public struct Snapshot: Snapshots.Snapshot {
                    let id: String
            
                    public init(model: TestModel) {
                        self.id = model.id
                    }
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testRawProperty() throws {
        #if canImport(SnapshotsMacros)
        assertMacroExpansion(
            """
            @Detachable
            final class TestModel: NSManagedObject {
                @Raw @NSManaged var idRaw: Data
                var id: String { 
                    get { String(data: idRaw, encoding: .utf8) ?? "" }
                    set { idRaw = newValue.data(using: .utf8) ?? Data() }
                }
            }
            """,
            expandedSource: """
            final class TestModel: NSManagedObject {
                @Raw @NSManaged var idRaw: Data
                var id: String { 
                    get { String(data: idRaw, encoding: .utf8) ?? "" }
                    set { idRaw = newValue.data(using: .utf8) ?? Data() }
                }
            }
            
            extension TestModel: Detachable {
                public struct Snapshot: Snapshots.Snapshot {
                    let id: String
            
                    public init(model: TestModel) {
                        self.id = model.id
                    }
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testRawPropertyWarning() throws {
        #if canImport(SnapshotsMacros)
        assertMacroExpansion(
            """
            @Detachable
            final class TestModel: NSManagedObject {
                @NSManaged var idRaw: Data
                var id: String { 
                    get { String(data: idRaw, encoding: .utf8) ?? "" }
                    set { idRaw = newValue.data(using: .utf8) ?? Data() }
                }
            }
            """,
            expandedSource: """
            final class TestModel: NSManagedObject {
                @NSManaged var idRaw: Data
                var id: String { 
                    get { String(data: idRaw, encoding: .utf8) ?? "" }
                    set { idRaw = newValue.data(using: .utf8) ?? Data() }
                }
            }
            
            extension TestModel: Detachable {
                public struct Snapshot: Snapshots.Snapshot {
                    let idRaw: Data
                    let id: String
            
                    public init(model: TestModel) {
                        self.idRaw = model.idRaw
                        self.id = model.id
                    }
                }
            }
            """,
            diagnostics: [.init(
                message: "Property 'idRaw' appears to be raw, but is not marked with @Raw",
                line: 3,
                column: 5,
                severity: .warning,
                fixIts: [.init(message: "Mark with @Raw")]
            )],
            macros: testMacros,
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testRelationNotMapped() throws {
        #if canImport(SnapshotsMacros)
        assertMacroExpansion(
            """
            @Detachable
            final class TestModel: NSManagedObject {
                @NSManaged var id: String

                @Relation @NSManaged var relation: TestRelationModel
            }

            @Detachable
            final class TestRelationModel: NSManagedObject {
                @NSManaged var id: Int
            }
            """,
            expandedSource: """
            final class TestModel: NSManagedObject {
                @NSManaged var id: String

                @Relation @NSManaged var relation: TestRelationModel
            }
            final class TestRelationModel: NSManagedObject {
                @NSManaged var id: Int
            }
            
            extension TestModel: Detachable {
                public struct Snapshot: Snapshots.Snapshot {
                    let id: String
            
                    public init(model: TestModel) {
                        self.id = model.id
                    }
                }
            }
            
            extension TestRelationModel: Detachable {
                public struct Snapshot: Snapshots.Snapshot {
                    let id: Int
            
                    public init(model: TestRelationModel) {
                        self.id = model.id
                    }
                }
            }
            """,
            macros: testMacros,
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testComputedProperty() throws {
        #if canImport(SnapshotsMacros)
        assertMacroExpansion(
            """
            @Detachable
            final class TestModel: NSManagedObject {
                var id: String { 
                    get { String(data: idRaw, encoding: .utf8) ?? "" }
                    set { idRaw = newValue.data(using: .utf8) ?? Data() }
                }
            }
            """,
            expandedSource: """
            final class TestModel: NSManagedObject {
                var id: String { 
                    get { String(data: idRaw, encoding: .utf8) ?? "" }
                    set { idRaw = newValue.data(using: .utf8) ?? Data() }
                }
            }
            
            extension TestModel: Detachable {
                public struct Snapshot: Snapshots.Snapshot {
                    let id: String
            
                    public init(model: TestModel) {
                        self.id = model.id
                    }
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
