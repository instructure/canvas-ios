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
import CoreData

public class GetModuleItemSequence: APIUseCase {
    public typealias Model = ModuleItemSequence

    public let courseID: String
    public let assetType: GetModuleItemSequenceRequest.AssetType
    public let assetID: String

    public var cacheKey: String? {
        "module-item-sequence/\(courseID)/\(assetType.rawValue)/\(assetID)"
    }

    public var request: GetModuleItemSequenceRequest {
        GetModuleItemSequenceRequest(courseID: courseID, assetType: assetType, assetID: assetID)
    }

    public var scope: Scope {
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(key: #keyPath(ModuleItemSequence.courseID), equals: courseID),
            NSPredicate(key: #keyPath(ModuleItemSequence.assetTypeRaw), equals: assetType.rawValue),
            NSPredicate(key: #keyPath(ModuleItemSequence.assetID), equals: assetID)
        ])
        return Scope(predicate: predicate, orderBy: #keyPath(ModuleItemSequence.assetID))
    }

    public init(courseID: String, assetType: GetModuleItemSequenceRequest.AssetType, assetID: String) {
        self.courseID = courseID
        self.assetType = assetType
        self.assetID = assetID
    }

    public func write(response: APIModuleItemSequence?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let response = response else { return }
        let sequence: ModuleItemSequence = client.fetch(scope: scope).first ?? client.insert()
        sequence.update(response, courseID: courseID, assetType: assetType, assetID: assetID, in: client)
    }
}
