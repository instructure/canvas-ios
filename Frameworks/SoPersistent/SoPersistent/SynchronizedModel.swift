//
//  SynchronizedModel.swift
//  Assignments
//
//  Created by Derrick Hathaway on 12/30/15.
//  Copyright © 2015 Instructure. All rights reserved.
//

import Foundation
import CoreData
import Marshal
import ReactiveCocoa

public protocol SynchronizedModel {
    static func uniquePredicateForObject(json: JSONObject) throws -> NSPredicate
    func updateValues(json: JSONObject, inContext context: NSManagedObjectContext) throws
}

extension SynchronizedModel where Self: NSManagedObject {
    public static func upsert(inContext context: NSManagedObjectContext, postProcess: (Self, JSONObject) throws -> () = { _,_ in })(jsonArray: [JSONObject]) -> SignalProducer<[Self], NSError> {
        return SignalProducer({ observer, disposable in
            context.performBlock {
                do {
                    let models: [Self] = try jsonArray.map { json in
                        let model: Self = (try context.findOne(withPredicate: uniquePredicateForObject(json)) ?? create(inContext: context))
                        
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

