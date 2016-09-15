//
//  User.swift
//  Peeps
//
//  Created by Brandon Pluim on 1/13/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import Foundation
import CoreData
import SoPersistent
import JaSON

public protocol UserProtocol {
    var id: Int64 { get }
    var loginID: String? { get }
    var name: String { get }
    var sortableName: String { get }
    var email: String? { get }
    var avatarURL: NSURL? { get }
    var obverveeID: String? { get }
}

public final class User: NSManagedObject, UserProtocol {
    
    @NSManaged public var id: Int64
    @NSManaged public var loginID: String?
    @NSManaged public var name: String
    @NSManaged public var sortableName: String
    @NSManaged public var email: String?
    @NSManaged public var avatarURL: NSURL?
    @NSManaged public var obverveeID: String?

}

extension User: SynchronizedModel {
    
    public static func uniquePredicateForObject(json: JSONObject) throws -> NSPredicate {
        let id: Int64 = try json <| "id"
        return NSPredicate(format: "%K == %@", "id", NSNumber(longLong: id))
    }
    
    public func updateValues(json: JSONObject, inContext context: NSManagedObjectContext) throws {
        id              = try json <| "id"
        name            = try json <| "name"
        loginID         = try json <| "login_id"
        sortableName    = try json <| "sortable_name"
        email           = try json <| "primary_email"
        
        let avatarURLString: String? = try json <| "avatar_url"
        if let urlString = avatarURLString {
            avatarURL   = NSURL(string: urlString)
        }
    }
    
}

import ReactiveCocoa
import TooLegit

extension User {
    static func getObserveeUsers(session: Session) throws -> SignalProducer<JSONObjectArray, NSError> {
        let request = try session.GET("/api/v1/users/self/observees", parameters: ["include": ["avatar_url"]])
        return session.URLSession.paginatedJSONSignalProducer(request)
    }
}

extension User {
    static func context(session: Session) throws -> NSManagedObjectContext {
        guard let model = NSManagedObjectModel(named: "UserKit", inBundle: NSBundle(forClass: User.self)) else { fatalError("problems?") }
        let storeURL = session.localStoreDirectoryURL.URLByAppendingPathComponent("user.sqlite")
        
        let context = try NSManagedObjectContext(storeURL: storeURL, model: model)
        return context
    }
}