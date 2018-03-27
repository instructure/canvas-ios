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
import Result

public protocol SynchronizedModel {
    static func uniquePredicateForObject(_ json: JSONObject) throws -> NSPredicate
    func updateValues(_ json: JSONObject, inContext context: NSManagedObjectContext) throws
}

extension SynchronizedModel where Self: NSManagedObject {
    public static func upsert(inContext context: NSManagedObjectContext, postProcess: @escaping (Self, JSONObject) throws -> () = { _,_ in }, jsonArray: [JSONObject]) -> SignalProducer<[Self], NSError> {
        return SignalProducer({ observer, disposable in
            upsert(inContext: context, postProcess: postProcess, jsonArray: jsonArray) { result in
                switch result {
                case .success(let models):
                    observer.send(value: models)
                    observer.sendCompleted()
                case .failure(let error):
                    observer.send(error: error)
                }
            }
        })
    }
    
    public static func upsert(inContext context: NSManagedObjectContext, postProcess: @escaping (Self, JSONObject) throws -> () = { _,_ in }, jsonArray: [JSONObject], completion: @escaping (Result<[Self], NSError>) -> Void) {
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
                completion(.success(models))
            } catch let e as MarshalError {
                completion(.failure(NSError(jsonError: e, parsingObjectOfType: self)))
            } catch let e as NSError {
                completion(.failure(e))
            }
        }
    }
}

