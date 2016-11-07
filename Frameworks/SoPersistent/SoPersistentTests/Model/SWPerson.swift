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

/**
 Star Wars Api Person
 https://swapi.co/documentation#people
 */
protocol SWPersonProtocol {
    var name: String { get }
    var height: String { get }
}

final class SWPerson: NSManagedObject, SWPersonProtocol {
    @NSManaged var name: String
    @NSManaged var height: String
}

// MARK: SynchronizedModel

import SoPersistent
import Marshal

extension SWPerson: SynchronizedModel {

    static func uniquePredicateForObject(json: JSONObject) throws -> NSPredicate {
        let name: String = try json <| "name"
        return NSPredicate(format: "%K == %@", "name", name)
    }

    func updateValues(json: JSONObject, inContext context: NSManagedObjectContext) throws {
        name = try json <| "name"
        height = try json <| "height"
    }

}
