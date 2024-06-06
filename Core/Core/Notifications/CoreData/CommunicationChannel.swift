//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

public final class CommunicationChannel: NSManagedObject {
    @NSManaged public var address: String
    @NSManaged public var id: String
    @NSManaged public var position: Int
    @NSManaged var typeRaw: String
    @NSManaged public var userID: String
    @NSManaged var workflowStateRaw: String

    public var type: CommunicationChannelType {
        get { return CommunicationChannelType(rawValue: typeRaw) ?? .email }
        set { typeRaw = newValue.rawValue }
    }
    public var workflowState: CommunicationChannelWorkflowState {
        get { return CommunicationChannelWorkflowState(rawValue: workflowStateRaw) ?? .unconfirmed }
        set { workflowStateRaw = newValue.rawValue }
    }
}

extension CommunicationChannel: WriteableModel {
    @discardableResult
    public static func save(_ item: APICommunicationChannel, in context: NSManagedObjectContext) -> CommunicationChannel {
        let model: CommunicationChannel = context.first(where: #keyPath(CommunicationChannel.id), equals: item.id.value) ?? context.insert()
        model.address = item.address
        model.id = item.id.value
        model.position = item.position
        model.type = item.type
        model.userID = item.user_id.value
        model.workflowState = item.workflow_state
        return model
    }
}
