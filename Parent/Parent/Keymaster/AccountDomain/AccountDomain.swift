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
import CoreData
import CanvasCore

// ---------------------------------------------
// MARK: - Model
// ---------------------------------------------
public final class AccountDomain: NSManagedObject {
    @NSManaged fileprivate (set) public var id: String
    @NSManaged fileprivate (set) public var name: String
    @NSManaged fileprivate (set) public var domain: String
    @NSManaged fileprivate (set) public var authenticationProvider: String?
}


import Marshal

// ---------------------------------------------
// MARK: - Synchronized Model
// ---------------------------------------------
extension AccountDomain: SynchronizedModel {
    public static func uniquePredicateForObject(_ json: JSONObject) throws -> NSPredicate {
        let id: String = try json.stringID("id")
        return NSPredicate(format: "%K == %@", "id", id)
    }
    
    public func updateValues(_ json: JSONObject, inContext context: NSManagedObjectContext) throws {
        id      = try json.stringID("id")
        name    = try json <| "name"
        domain  = try json <| "domain"
        authenticationProvider = try json <| "authentication_provider"
    }
}
