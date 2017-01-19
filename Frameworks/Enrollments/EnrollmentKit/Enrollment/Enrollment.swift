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
import SoPretty
import ReactiveSwift
import ReactiveCocoa

public typealias MarkAsFavoriteAction = Action<(favorite: Bool, session: Session), Void, NSError>

open class Enrollment: NSManagedObject {
    @NSManaged internal (set) open var id: String
    @NSManaged internal (set) open var name: String
    @NSManaged internal (set) open var isFavorite: Bool
    
    open override func awakeFromInsert() {
        super.awakeFromInsert()
        color.value = .prettyGray()
    }
    
    var faves: String {
        let favorites = NSLocalizedString("Favorites", tableName: "Localizable", bundle: Bundle(identifier: "com.instructure.EnrollmentKit")!, value: "", comment: "favorite courses or groups")
        let hidden = NSLocalizedString("Hidden", tableName: "Localizable", bundle: Bundle(identifier: "com.instructure.EnrollmentKit")!, value: "", comment: "Non favorite hidden courses or groups")
        return isFavorite ? favorites : hidden
    }
    
    public lazy var color: DynamicProperty<UIColor> = {
        return DynamicProperty(object: self, keyPath: "color")
    }()
    
    @objc
    open static func keyPathsForValuesAffectingColor() -> NSSet {
        return NSSet(objects: "rawColor")
    }
    
    open var contextID: ContextID { ❨╯°□°❩╯⌢"Enrollment is abstract, yo. This gots to be overrid" }
    
    open var hasGrades: Bool { return false }
    
    open var visibleGrade: String? { return nil }
    
    open var visibleScore: String? { return nil }
    
    open var roles: EnrollmentRoles? { return nil }
    
    open var shortName: String { return "" }

    open func markAsFavorite(_ favorite: Bool, session: Session) -> SignalProducer<Void, NSError> {
        return attemptProducer {
            self.isFavorite = favorite
            try self.managedObjectContext?.saveFRD()
        }
    }
    
    open var defaultViewPath: String {
        return contextID.htmlPath / "activity_stream"
    }
}

// MARK: fetching
extension Enrollment {
    public static func findOne(_ contextID: ContextID, inContext context: NSManagedObjectContext) throws -> Enrollment? {
        switch contextID.context {
        case .course:
            let course: Course? = try context.findOne(withValue: contextID.id, forKey: "id")
            return course
        case .group:
            let group: Group? = try context.findOne(withValue: contextID.id, forKey: "id")
            return group
        default:
            return nil
        }
    }
}
