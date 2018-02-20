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
import ReactiveSwift

public protocol SynchronizedModel {
    static func uniquePredicateForObject(_ json: JSONObject) throws -> NSPredicate
    func updateValues(_ json: JSONObject, inContext context: NSManagedObjectContext) throws
}

extension SynchronizedModel where Self: NSManagedObject {
    public static func upsert(inContext context: NSManagedObjectContext, postProcess: @escaping (Self, JSONObject) throws -> () = { _,_ in }, jsonArray: [JSONObject]) -> SignalProducer<[Self], NSError> {
        return SignalProducer({ observer, disposable in
            context.perform {
                do {
                    let models: [Self] = try jsonArray.flatMap { json in
                        let model: Self = (try context.findOne(withPredicate: uniquePredicateForObject(json)) ?? create(inContext: context))
                        
                        // Historically we failed if _any_ of the models failed
                        // However, since a lot of these models are coming from the javascript side
                        // We just want these things to get into the database so that the existing native components work
                        // This is no longer the source of truth, the RN stuff is
                        do {
                            try model.updateValues(json, inContext: context)
                            try postProcess(model, json)
                        } catch let e {
                            print("error parsing model", e)
                            context.delete(model)
                            return nil
                        }
                        
                        return model
                    }
                    observer.send(value: models)
                    observer.sendCompleted()
                } catch let e as MarshalError {
                    observer.send(error: NSError(jsonError: e, parsingObjectOfType: self))
                } catch let e as NSError {
                    observer.send(error: e)
                }
            }
        })
    }
}

