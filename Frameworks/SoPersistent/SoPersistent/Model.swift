//
//  Model.swift
//  Assignments
//
//  Created by Derrick Hathaway on 12/30/15.
//  Copyright © 2015 Instructure. All rights reserved.
//

import Foundation
import CoreData
import Marshal
import ReactiveCocoa

public protocol Model: Hashable {
    static func create(inContext context: NSManagedObjectContext) -> Self
    
    static func findOne(withValue value: AnyObject, forKey key: String, inContext context: NSManagedObjectContext) throws -> Self?
    static func findOne(predicate: NSPredicate, inContext context: NSManagedObjectContext) throws -> Self?
    
    static func findAll(context: NSManagedObjectContext) throws -> [Self]
    static func findAll(request: NSFetchRequest, inContext context: NSManagedObjectContext) throws -> [Self]
    static func findAll(withValue value: AnyObject, forKey key: String, inContext context: NSManagedObjectContext) throws -> [Self]
    static func findAll(withValues values: [AnyObject], forKey key: String, inContext context: NSManagedObjectContext) throws -> [Self]
    
    var objectID: NSManagedObjectID { get }
    static func findOne(inContext context: NSManagedObjectContext, objectID: NSManagedObjectID) throws -> Self
}

public protocol SynchronizedModel: Model {
    static func uniquePredicateForObject(json: JSONObject) throws -> NSPredicate
    func updateValues(json: JSONObject, inContext context: NSManagedObjectContext) throws
}

extension SynchronizedModel {
    public static func upsert(inContext context: NSManagedObjectContext, postProcess: (Self, JSONObject) throws -> () = { _,_ in })(jsonArray: [JSONObject]) -> SignalProducer<[Self], NSError> {
        return SignalProducer({ observer, disposable in
            context.performBlock {
                do {
                    let models: [Self] = try jsonArray.map { json in
                        let model: Self = (try findOne(uniquePredicateForObject(json), inContext: context)) ?? create(inContext: context)
                        try model.updateValues(json, inContext: context)
                        try postProcess(model, json)
                        return model
                    }
                    observer.sendNext(models)
                    observer.sendCompleted()
                } catch let e as Error {
                    observer.sendFailed(NSError(jsonError: e))
                } catch let e as NSError {
                    observer.sendFailed(e)
                }
            }
        })
    }
}

