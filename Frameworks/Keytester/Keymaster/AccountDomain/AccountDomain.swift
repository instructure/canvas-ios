
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

import CoreData

// ---------------------------------------------
// MARK: - Model
// ---------------------------------------------
public final class AccountDomain: NSManagedObject {
    @NSManaged private (set) public var name: String
    @NSManaged private (set) public var domain: String
}

import SoPersistent
import Marshal

// ---------------------------------------------
// MARK: - Synchronized Model
// ---------------------------------------------
extension AccountDomain: SynchronizedModel {
    public static func uniquePredicateForObject(json: JSONObject) throws -> NSPredicate {
        let domain: String = try json <| "domain"
        return NSPredicate(format: "%K == %@", "domain", domain)
    }
    
    public func updateValues(json: JSONObject, inContext context: NSManagedObjectContext) throws {
        name    = try json <| "name"
        domain  = try json <| "domain"
    }
}