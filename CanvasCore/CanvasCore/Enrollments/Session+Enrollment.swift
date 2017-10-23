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

import CoreData



let enrollmentKitModelName = "EnrollmentKit"
let enrollmentKitSubdomain = "EnrollmentKit"
let enrollmentKitFailedToLoadErrorCode = 10001
let enrollmentKitFailedToLoadErrorDescription = "Failed to load \(enrollmentKitModelName) NSManagedObjectModel"
let enrollmentKitDBFailedToLoadErrorDescription = NSLocalizedString("There was a problem loading the EnrollmentKit database file.", tableName: "Localizable", bundle: .core, value: "", comment: "EnrollmentKit Database Load Failure Message")

extension Session {
    public func enrollmentManagedObjectContext(_ scope: String? = nil) throws -> NSManagedObjectContext {
        let model = NSManagedObjectModel(named: enrollmentKitModelName, inBundle: Bundle(for: Course.self))?.mutableCopy() as! NSManagedObjectModel
        let storeName = scope == nil ? enrollmentKitModelName : "\(enrollmentKitModelName)_\(scope!)"
        let storeID = StoreID(storeName: storeName, model: model,
            localizedErrorDescription: enrollmentKitDBFailedToLoadErrorDescription)

        return try managedObjectContext(storeID)
    }
}

// MARK: Colorful

extension Session {
    private func color(for contextID: ContextID) -> UIColor {
        let enrollment = enrollmentsDataSource[contextID]
        let color = enrollment?.color.value ?? .prettyGray()
        return color
    }
    
    // for objc compatability
    public func colorForCourse(_ courseID: String) -> UIColor {
        return color(for: .course(withID: courseID))
    }
    
    // for objc compatability
    public func colorForGroup(_ groupID: String) -> UIColor {
        return color(for: .group(withID: groupID))
    }
    
    public func course(id courseID: String) -> Course? {
        return enrollmentsDataSource[.course(withID: courseID)] as? Course
    }
    
    public func group(id groupID: String) -> Group? {
        return enrollmentsDataSource[.group(withID: groupID)] as? Group
    }

}

