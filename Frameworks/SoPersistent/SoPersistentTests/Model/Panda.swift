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
import SoAutomated
import TooLegit
import SoLazy

protocol PandaProtocol {
    var id: String { get }
    var name: String { get }
    var birthday: NSDate { get }
}

final class Panda: NSManagedObject, PandaProtocol {

    @NSManaged var id: String
    @NSManaged var name: String
    @NSManaged var birthday: NSDate

    var firstLetterOfName: String {
        return name.substringToIndex(name.startIndex.advancedBy(1))
    }

}

// MARK: - SynchronizedModel

import SoPersistent
import Marshal

extension Panda: SynchronizedModel {

    static func uniquePredicateForObject(json: JSONObject) throws -> NSPredicate {
        let id: String = try json.stringID("id")
        return NSPredicate(format: "%K == %@", "id", id)
    }

    func updateValues(json: JSONObject, inContext context: NSManagedObjectContext) throws {
        id = try json.stringID("id")
        name = try json <| "name"
        birthday = try json <| "birthday"
    }

}
