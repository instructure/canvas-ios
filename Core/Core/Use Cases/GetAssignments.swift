//
// Copyright (C) 2018-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation

public class GetAssignments: CollectionUseCase {

    public enum Sort: String {
        case position, dueAt
    }

    public typealias Model = Assignment
    public let courseID: String
    private let sort: Sort

    public init(courseID: String, sort: Sort = .position) {
        self.courseID = courseID
        self.sort = sort
    }

    public var cacheKey: String? {
        return "get-\(courseID)-assignments"
    }

    public var request: GetAssignmentsRequest {
        return GetAssignmentsRequest(courseID: courseID)
    }

    public var scope: Scope {

        switch sort {
        case .dueAt:
            //  this puts nil dueAt at the bottom of the list
            let sortDescriptor = NSSortDescriptor(key: #keyPath(Assignment.dueAt), ascending: false, selector: #selector(NSDate.fetchedResultsControllerComparatorSortNilsToBottom))
            let predicate = NSPredicate(format: "%K == %@", argumentArray: [#keyPath(Assignment.courseID), courseID])
            return Scope.init(predicate: predicate, order: [sortDescriptor])
        case .position:
        return .where(#keyPath(Assignment.courseID), equals: courseID, orderBy: #keyPath(Assignment.position))
        }

//        let s3 = NSSortDescriptor(key: #keyPath(Assignment.dueAtEmpty), ascending: true) { id1, id2 in
//            if let id1 = id1 as? Bool, let id2 = id2 as? Bool {
//                if id1 == id2 { return .orderedSame }
//                if id1 && !id2 { return .orderedAscending }
//                if !id1 && id2 { return .orderedDescending }
//            }
////            else {
//                return .orderedSame
////            }
//
//        }

//        let s4 = NSSortDescriptor(key: #keyPath(Assignment.dueAtOrder), ascending: true, selector: #selector(NSNumber.comp(_:)))
//        return Scope.where(#keyPath(Assignment.courseID), equals: courseID, orderBy: sort, ascending: false, naturally: false)
//        return .where(#keyPath(Assignment.courseID), equals: courseID, orderBy: sort, naturally: true)
//        return .where(#keyPath(Assignment.courseID), equals: courseID, orderBy: #keyPath(Assignment.position), naturally: false)
    }

    public func write(response: [APIAssignment]?, urlResponse: URLResponse?, to client: PersistenceClient) throws {
        guard let response = response else {
            return
        }

        for item in response {
            let predicate = NSPredicate(format: "%K == %@", #keyPath(Assignment.htmlURL), item.html_url as CVarArg)
            let model: Assignment = client.fetch(predicate).first ?? client.insert()
            try model.update(fromApiModel: item, in: client, updateSubmission: false)
        }
    }
}

extension NSNumber {
    @objc open func comp(_ b: NSNumber) -> ComparisonResult {
//        if let id1 = id1 as? Bool, let id2 = id2 as? Bool {
            if self.boolValue == b.boolValue { return .orderedSame }
            if self.boolValue && !b.boolValue { return .orderedAscending }
            if !self.boolValue && b.boolValue { return .orderedDescending }
//        }
        return .orderedSame
    }
}
