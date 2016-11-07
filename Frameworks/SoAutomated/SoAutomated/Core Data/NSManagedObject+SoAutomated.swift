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
import SoPersistent

extension NSManagedObject {

    public var isValid: Bool {
        do {
            try self.validateForInsert()
            return true
        } catch {
            return false
        }
    }

}

extension NSManagedObject {
    public static func count(inContext context: NSManagedObjectContext) -> Int {
        let all = fetch(nil, sortDescriptors: nil, inContext: context)
        return (try? context.countForFetchRequest(all)) ?? -1
    }
}
