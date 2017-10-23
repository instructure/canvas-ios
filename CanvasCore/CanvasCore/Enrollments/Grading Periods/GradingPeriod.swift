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
    
    

import CoreData


import Marshal

public final class GradingPeriod: NSManagedObject {
    @NSManaged internal (set) public var id: String
    @NSManaged internal (set) public var title: String
    @NSManaged internal (set) public var courseID: String
    @NSManaged internal (set) public var startDate: Date
}

extension GradingPeriod: SynchronizedModel {
    public static func uniquePredicateForObject(_ json: JSONObject) throws -> NSPredicate {
        let id: String = try json.stringID("id")
        return NSPredicate(format: "%K == %@", "id", id)
    }

    public func updateValues(_ json: JSONObject, inContext context: NSManagedObjectContext) throws {
        try id          = json.stringID("id")
        try title       = json <| "title"
        try startDate   = json <| "start_date"
    }
}
