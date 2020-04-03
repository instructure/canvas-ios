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

import Foundation
import Core

struct AssignmentListModel {

    var assignments: [ID: NSMutableOrderedSet] =  [:]
    var groups: NSMutableOrderedSet = NSMutableOrderedSet()
    var sectionMeta: [ID: NSMutableOrderedSet] = [:]
    private var debug = false

    mutating func addResponse(response: APIAssignmentListResponse?) {
        guard let response = response else { return }

        for g in response.groups {
            if g.assignments.count == 0 { continue }
            groups.add(g)
            addAssignmentsToGroup(g.assignments, groupID: g.id)
            if let cursor = g.pageInfo?.endCursor { addCursor(cursor, groupID: g.id) }
        }

        if debug { printDebugInfo(msg: "response received") }
    }

    mutating func addCursor(_ cursor: String, groupID: ID) {
        let existing = sectionMeta[groupID] ?? NSMutableOrderedSet()
        existing.add(cursor)
        sectionMeta[groupID] = existing
    }

    mutating func dequeueCursor(forSection section: Int) -> String? {
        guard let group = group(forSection: section),
            let existing = sectionMeta[group.id], existing.count > 0 else { return nil }
        let cursor = existing.object(at: 0) as? String
        existing.removeObject(at: 0)
        sectionMeta[group.id] = existing
        return cursor
    }

    mutating func addAssignmentsToGroup(_ a: [APIAssignmentListAssignment], groupID: ID) {
        let existing = assignments[groupID] ?? NSMutableOrderedSet()
        existing.addObjects(from: a)
        assignments[groupID] = existing
    }

    func assignment(for indexPath: IndexPath) -> APIAssignmentListAssignment? {
        guard indexPath.section < groups.count,
        let group = groups[indexPath.section] as? APIAssignmentListGroup else { return nil }
        guard let existing = assignments[group.id], indexPath.row < existing.count else { return nil }
        return existing[indexPath.row] as? APIAssignmentListAssignment
    }

    func group(forSection section: Int) -> APIAssignmentListGroup? {
        guard section < groups.count,
        let group = groups[section] as? APIAssignmentListGroup else { return nil }
        return group
    }

    func assignmentCount(forSection: Int) -> Int {
        guard forSection < groups.count,
        let group = groups[forSection] as? APIAssignmentListGroup else { return 0 }
        guard let existing = assignments[group.id] else { return 0 }
        return existing.count
    }

    func hasNext(groupID: ID) -> Bool {
        guard let existing = sectionMeta[groupID] else { return false }
        return existing.count > 0
    }

    func hasNext(forSection: Int) -> Bool {
        guard forSection < groups.count,
        let group = groups[forSection] as? APIAssignmentListGroup else { return false }
        return hasNext(groupID: group.id)
    }

    func printDebugInfo(msg: String? = nil) {
        if let msg = msg { print(msg) }
        for g in groups {
            guard let group = g as? APIAssignmentListGroup else { continue }
            let collection = assignments[group.id] ?? NSMutableOrderedSet()
            let meta = sectionMeta[group.id]?.compactMap { ($0 as? String) ?? "" } ?? []
            print("[\(group.id.value)]: \(collection.count) \(group.name)  cursors: \(meta)")
        }
    }
}
