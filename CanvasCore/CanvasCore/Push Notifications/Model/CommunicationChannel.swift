//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
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

open class CommunicationChannel {
    public var address: String
    var id: String
    var position: String
    public var type: CommunicationChannelType
    var userID: String
    var workflowState: CommunicationChannelWorkflowState
    
    open class func create(_ dictionary: [String: Any]) -> CommunicationChannel? {
        if  let address         = dictionary["address"] as? String,
            let id              = dictionary["id"] as? Int,
            let position        = dictionary["position"] as? Int,
            let type            = dictionary["type"] as? String,
            let userID          = dictionary["user_id"] as? Int,
            let workflowState   = dictionary["workflow_state"] as? String,
            let channelType     = CommunicationChannelType(rawValue: type),
            let channelWorkflowState = CommunicationChannelWorkflowState(rawValue: workflowState) {
                return CommunicationChannel(address: address, id: "\(id)", position: "\(position)", type: channelType, userID: "\(userID)", workflowState: channelWorkflowState)
        } else {
            return nil
        }
    }
    
    fileprivate init(address: String, id: String, position: String, type: CommunicationChannelType, userID: String, workflowState: CommunicationChannelWorkflowState) {
        
        self.address = address
        self.id = id
        self.position = position
        self.type = type
        self.userID = userID
        self.workflowState = workflowState
    }
}
