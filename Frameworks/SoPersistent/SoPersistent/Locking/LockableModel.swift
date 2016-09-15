//
//  LockableModel.swift
//  SoPersistent
//
//  Created by Derrick Hathaway on 1/13/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation


public protocol LockableModel: class {
    var lockedForUser: Bool { get set }
    var lockExplanation: String? { get set }
    var canView: Bool { get set }
}

import Marshal

extension LockableModel {
    public func updateLockStatus(json: JSONObject) throws {
        try lockedForUser = json <| "locked_for_user" ?? false
        try lockExplanation = json <| "lock_explanation"
        try canView = json <| "lock_info.can_view" ?? true
    }
}