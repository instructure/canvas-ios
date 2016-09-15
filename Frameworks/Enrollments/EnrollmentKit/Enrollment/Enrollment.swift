//
//  Enrollment.swift
//  Enrollments
//
//  Created by Derrick Hathaway on 2/9/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
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
        return isFavorite ? NSLocalizedString("Favorites", comment: "favorite courses or groups"): NSLocalizedString("Hidden", comment: "Non favorite hidden courses or groups")
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
            return try Course.findOne(withValue: contextID.id, forKey: "id", inContext: context)
        case .Group:
            return try Group.findOne(withValue: contextID.id, forKey: "id", inContext: context)
        default:
            return nil
        }
    }
}
