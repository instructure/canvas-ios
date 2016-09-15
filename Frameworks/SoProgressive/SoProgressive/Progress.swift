//
//  Progress.swift
//  SoProgressive
//
//  Created by Derrick Hathaway on 4/5/16.
//  Copyright © 2016 Instructure. All rights reserved.
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
        case File, Page, Discussion, Assignment, Quiz, URL, ExternalTool
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