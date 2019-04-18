//
// Copyright (C) 2016-present Instructure, Inc.
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


public struct Progress: Equatable, Hashable {
    public enum Kind: String {
        case viewed
        case submitted
        case contributed
        case markedDone
        case minimumScore
    }
    
    public enum ItemType: String {
        case file
        case page
        case discussion
        case assignment
        case quiz
        case url
        case externalTool
        case legacyModuleProgressShim
        case moduleItem
    }
    
    public init(kind: Kind, contextID: ContextID, itemType: ItemType, itemID: String) {
        self.kind = kind
        self.contextID = contextID
        self.itemType = itemType
        self.itemID = itemID
    }
    
    public let kind: Kind
    public let contextID: ContextID
    public let itemType: ItemType
    public let itemID: String
}
