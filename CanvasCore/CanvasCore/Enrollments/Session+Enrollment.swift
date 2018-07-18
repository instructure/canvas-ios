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

