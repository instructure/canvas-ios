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

import Marshal
import TooLegit
import CoreData
@testable import AssignmentKit
@testable import FileKit
@testable import EnrollmentKit

extension Session {
    public func managedObjectContext<T: NSManagedObject>(_ type: T.Type, options: [String: Any] = [:]) -> NSManagedObjectContext {
        let scope: String? = try? options <| "scope"
        let className = NSStringFromClass(object_getClass(T))
        let frameworkName = className.components(separatedBy: ".").first!

        let context: NSManagedObjectContext
        switch frameworkName {
        case "AssignmentKit":
            context = try! assignmentsManagedObjectContext(scope)
        case "FileKit":
            context = try! filesManagedObjectContext()
        case "EnrollmentKit":
            context = try! enrollmentManagedObjectContext(scope)
        default: fatalError("Plz to add your context above for \(frameworkName)")
        }

        return context
    }
}
