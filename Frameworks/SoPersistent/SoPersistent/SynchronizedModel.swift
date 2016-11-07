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

