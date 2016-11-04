
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
    
    

import UIKit
import TooLegit
import CoreData
import SoPersistent
import SoLazy

let enrollmentKitModelName = "EnrollmentKit"
let enrollmentKitSubdomain = "EnrollmentKit"
let enrollmentKitFailedToLoadErrorCode = 10001
let enrollmentKitFailedToLoadErrorDescription = "Failed to load \(enrollmentKitModelName) NSManagedObjectModel"
let enrollmentKitDBFailedToLoadErrorDescription = NSLocalizedString("There was a problem loading the EnrollmentKit database file.", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.EnrollmentKit")!, value: "", comment: "EnrollmentKit Database Load Failure Message")

extension Session {
    public func enrollmentManagedObjectContext(scope: String? = nil) throws -> NSManagedObjectContext {
        let model = NSManagedObjectModel(named: enrollmentKitModelName, inBundle: NSBundle(forClass: Course.self))?.mutableCopy() as! NSManagedObjectModel
        let storeName = scope == nil ? enrollmentKitModelName : "\(enrollmentKitModelName)_\(scope!)"
        let storeID = StoreID(storeName: storeName, model: model,
            localizedErrorDescription: enrollmentKitDBFailedToLoadErrorDescription)

        return try managedObjectContext(storeID)
    }
}


// MARK: Colorful

extension Session {
    public func colorForCourse(courseID: String) -> UIColor {
        let context = ContextID(id: courseID, context: .Course)
        let color = enrollmentsDataSource[context]?.color ?? .prettyGray()
        print("colorForCourse = \(color)")
        return color
    }
    
    public func colorForGroup(groupID: String) -> UIColor {
        let context = ContextID(id: groupID, context: .Group)
        let color = enrollmentsDataSource[context]?.color ?? .prettyGray()
        print("colorForGroup = \(color)")
        return color
    }
    
    
    public func courseWithID(courseID: String) -> Course? {
        return enrollmentsDataSource[ContextID(id: courseID, context: .Course)] as? Course
    }
    
    public func groupWithID(groupID: String) -> Group? {
        return enrollmentsDataSource[ContextID(id: groupID, context: .Group)] as? Group
    }
}