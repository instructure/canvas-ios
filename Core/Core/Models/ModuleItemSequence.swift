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

public class ModuleItemSequence: NSManagedObject {
    public typealias AssetType = GetModuleItemSequenceRequest.AssetType

    @NSManaged public var courseID: String
    @NSManaged public var assetTypeRaw: String
    @NSManaged public var assetID: String

    @NSManaged public var prev: ModuleItemSequenceNode?
    @NSManaged public var current: ModuleItemSequenceNode?
    @NSManaged public var next: ModuleItemSequenceNode?

    public var assetType: AssetType {
        get { AssetType(rawValue: assetTypeRaw) ?? .moduleItem }
        set { assetTypeRaw = newValue.rawValue }
    }

    public func update(_ response: APIModuleItemSequence, courseID: String, assetType: AssetType, assetID: String, in context: NSManagedObjectContext) {
        self.courseID = courseID
        self.assetType = assetType
        self.assetID = assetID
        let node = response.items.first
        prev = node?.prev.flatMap { .save($0, in: context) }
        current = node?.current.flatMap { .save($0, in: context) }
        next = node?.next.flatMap { .save($0, in: context) }
    }
}

public class ModuleItemSequenceNode: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var moduleID: String

    public static func save(_ item: APIModuleItem, in context: NSManagedObjectContext) -> ModuleItemSequenceNode {
        let node = context.insert() as ModuleItemSequenceNode
        node.id = item.id.value
        node.moduleID = item.module_id.value
        return node
    }
}
