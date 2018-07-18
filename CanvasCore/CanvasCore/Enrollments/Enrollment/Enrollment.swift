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
    
    

import CoreData




import ReactiveSwift
import ReactiveCocoa

public typealias MarkAsFavoriteAction = Action<(favorite: Bool, session: Session), Void, NSError>

open class Enrollment: NSManagedObject {
    @NSManaged internal (set) open var id: String
    @NSManaged internal (set) open var name: String
    @NSManaged internal (set) open var isFavorite: Bool
    
    // If nil - hasn't checked yet to see if this enrollment supports arc
    // If an empty string - have checked, and it's not
    // Else, arc is supported!
    @NSManaged internal (set) open var arcLTIToolID: String?
    
    open override func awakeFromInsert() {
        super.awakeFromInsert()
        color.value = .prettyGray()
    }
    
    var faves: String {
        let favorites = NSLocalizedString("Favorites", tableName: "Localizable", bundle: .core, value: "", comment: "favorite courses or groups")
        let hidden = NSLocalizedString("Hidden", tableName: "Localizable", bundle: .core, value: "", comment: "Non favorite hidden courses or groups")
        return isFavorite ? favorites : hidden
    }
    
    public lazy var color: DynamicProperty<UIColor> = {
        return DynamicProperty(object: self, keyPath: "color")
    }()
    
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
