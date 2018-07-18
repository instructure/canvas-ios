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

