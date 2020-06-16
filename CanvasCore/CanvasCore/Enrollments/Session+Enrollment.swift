//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import UIKit

import CoreData



let enrollmentKitModelName = "EnrollmentKit"
let enrollmentKitSubdomain = "EnrollmentKit"
let enrollmentKitFailedToLoadErrorCode = 10001
let enrollmentKitFailedToLoadErrorDescription = "Failed to load \(enrollmentKitModelName) NSManagedObjectModel"
let enrollmentKitDBFailedToLoadErrorDescription = NSLocalizedString("There was a problem loading the EnrollmentKit database file.", tableName: "Localizable", bundle: .core, value: "", comment: "EnrollmentKit Database Load Failure Message")

extension Session {
    @objc public func enrollmentManagedObjectContext(_ scope: String? = nil) throws -> NSManagedObjectContext {
        let model = NSManagedObjectModel(named: enrollmentKitModelName, inBundle: Bundle(for: Course.self))?.mutableCopy() as! NSManagedObjectModel
        let storeName = scope == nil ? enrollmentKitModelName : "\(enrollmentKitModelName)_\(scope!)"
        let storeID = StoreID(storeName: storeName, model: model,
            localizedErrorDescription: enrollmentKitDBFailedToLoadErrorDescription)

        return try managedObjectContext(storeID)
    }
}

// MARK: Colorful

extension Session {
    private func color(for contextID: Context) -> UIColor {
        let enrollment = enrollmentsDataSource[contextID]
        let color = enrollment?.color.value ?? .prettyGray()
        return color
    }
    
    // for objc compatibility
    @objc public func colorForCourse(_ courseID: String) -> UIColor {
        return color(for: .course(courseID))
    }
    
    // for objc compatibility
    @objc public func colorForGroup(_ groupID: String) -> UIColor {
        return color(for: .group(groupID))
    }
    
    @objc public func course(id courseID: String) -> Course? {
        return enrollmentsDataSource[.course(courseID)] as? Course
    }
    
    @objc public func group(id groupID: String) -> Group? {
        return enrollmentsDataSource[.group(groupID)] as? Group
    }

}

