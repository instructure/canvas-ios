//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    
    

import Foundation
import TooLegit

public struct Progress: Equatable, Hashable {
    public enum Kind: String {
        case Viewed
        case Submitted
        case Contributed
        case MarkedDone
        case MinimumScore
    }
    
    public enum ItemType: String {
        case File
        case Page
        case Discussion
        case Assignment
        case Quiz
        case URL
        case ExternalTool
        case LegacyModuleProgressShim
        case ModuleItem
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
    
    
    public var hashValue: Int {
        return kind.hashValue
            + 11 * contextID.hashValue
            + 37 * itemType.hashValue
            + 101 * itemID.hashValue
    }
}

public func ==(lhs: Progress, rhs: Progress) -> Bool {
    return lhs.kind == rhs.kind
        && lhs.contextID == rhs.contextID
        && lhs.itemType == rhs.itemType
        && lhs.itemID == rhs.itemID
}
