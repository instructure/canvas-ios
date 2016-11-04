
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
import TooLegit
import SoPersistent
import SoLazy
import ReactiveCocoa

public typealias MarkAsFavoriteAction = Action<(favorite: Bool, session: Session), Void, NSError>

public class Enrollment: NSManagedObject {
    @NSManaged internal (set) public var id: String
    @NSManaged internal (set) public var name: String
    @NSManaged internal (set) public var isFavorite: Bool
    @NSManaged internal var rawColor: String
    
    var faves: String {
        return isFavorite ? NSLocalizedString("Favorites", comment: "favorite courses or groups"): NSLocalizedString("Hidden", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.EnrollmentKit")!, value: "", comment: "Non favorite hidden courses or groups")
    }
    
    internal (set) public var color: UIColor? {
        get {
            willAccessValueForKey("rawColor")
            defer { didAccessValueForKey("rawColor") }
                
            return UIColor.colorFromHexString(rawColor)
        } set {
            if let hex = newValue.map({ $0.hex }) {
                willChangeValueForKey("rawColor")
                rawColor = hex
                didChangeValueForKey("rawColor")
            }
        }
    }
    
    @objc
    public static func keyPathsForValuesAffectingColor() -> NSSet {
        return NSSet(objects: "rawColor")
    }
    
    public var contextID: ContextID { ❨╯°□°❩╯⌢"Enrollment is abstract, yo. This gots to be overrid" }
    
    public var hasGrades: Bool { return false }
    
    public var visibleGrade: String? { return nil }
    
    public var visibleScore: String? { return nil }
    
    public var roles: EnrollmentRoles? { return nil }
    
    public var shortName: String { return "" }

    public func markAsFavorite(favorite: Bool, session: Session) -> SignalProducer<Void, NSError> {
        return attemptProducer {
            self.isFavorite = favorite
            try self.managedObjectContext?.saveFRD()
        }
    }
    
    public var defaultViewPath: String {
        return contextID.htmlPath / "activity_stream"
    }
}

// MARK: fetching
extension Enrollment {
    public static func findOne(contextID: ContextID, inContext context: NSManagedObjectContext) throws -> Enrollment? {
        switch contextID.context {
        case .Course:
            let course: Course? = try context.findOne(withValue: contextID.id, forKey: "id")
            return course
        case .Group:
            let group: Group? = try context.findOne(withValue: contextID.id, forKey: "id")
            return group
        default:
            return nil
        }
    }
}
