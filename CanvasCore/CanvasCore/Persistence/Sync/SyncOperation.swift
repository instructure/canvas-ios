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
import ReactiveSwift
import CoreData
import Marshal


extension SynchronizedModel where Self: NSManagedObject {
    public typealias ModelPageSignalProducer = SignalProducer<[Self], NSError>
    
    public static func sync(_ localPredicate: NSPredicate? = nil, inContext context: NSManagedObjectContext, jsonArray: [JSONObject], completion: @escaping (NSError?) -> Void) {
        context.perform {
            do {
                let fetchLocal: NSFetchRequest<Self> = context.fetch(localPredicate, sortDescriptors: nil)
                fetchLocal.includesPropertyValues = false
                fetchLocal.returnsObjectsAsFaults = true
                fetchLocal.includesSubentities = true
                var existing = try Set(context.findAll(fromFetchRequest: fetchLocal))
                Self.upsert(inContext: context, jsonArray: jsonArray) { result in
                    switch result {
                    case .success(let models):
                        context.perform {
                            for model in models {
                                existing.remove(model)
                            }
                            for item in existing {
                                item.delete(inContext: context)
                            }
                            do {
                                try context.saveFRD()
                                completion(nil)
                            } catch let e as NSError {
                                completion(e)
                            }
                        }
                    case .failure(let error):
                        completion(error)
                    }
                }
            } catch let e as NSError {
                completion(e)
            }
        }
    }
    
    public static func syncSignalProducer(_ localPredicate: NSPredicate? = nil, includeSubentities: Bool = true, inContext context: NSManagedObjectContext, fetchRemote: SignalProducer<[JSONObject], NSError>, postProcess: @escaping (Self, JSONObject) throws -> Void = { _, _ in }) -> ModelPageSignalProducer {
        
        let syncContextModelsSignal = ModelPageSignalProducer({ observer, compositeDisposable in
            
            let syncContext = context.syncContext
            
            syncContext.perform() {
                do {
                    let fetchLocal: NSFetchRequest<Self> = syncContext.fetch(localPredicate, sortDescriptors: nil)
                    fetchLocal.includesPropertyValues = false
                    fetchLocal.returnsObjectsAsFaults = true
                    fetchLocal.includesSubentities = includeSubentities
                    var existing = try Set(syncContext.findAll(fromFetchRequest: fetchLocal))
                    
                    let upsertSignal: ModelPageSignalProducer = fetchRemote.flatMap(.concat) { Self.upsert(inContext: syncContext, postProcess: postProcess, jsonArray: $0) }

                    upsertSignal.startWithSignal { signal, signalDisposable in
                        compositeDisposable += signalDisposable
                        
                        signal.observe { event in
                            syncContext.perform {
                                switch event {
                                case .interrupted:
                                    print("What?! why??!")
                                case .completed:
                                    
                                    guard existing.count > 0 else {
                                        observer.sendCompleted()
                                        break
                                    }
                                    
                                    for item in existing {
                                        item.delete(inContext: syncContext)
                                    }
                                    
                                    do {
                                        try syncContext.saveFRD()
                                        observer.sendCompleted()
                                    } catch let e as NSError {
                                        observer.send(error: e)
                                    }
                                    
                                case .value(let models):
                                    for model in models {
                                        existing.remove(model)
                                    }
                                    
                                    do {
                                        try syncContext.saveFRD()
                                        observer.send(value: models)
                                    } catch let e as NSError {
                                        observer.send(error: e)
                                    }
                                    
                                default:
                                    observer.action(event)
                                }
                            }
                        }
                    }
                } catch let e as NSError {
                    observer.send(error: e)
                }
            }
        })

        let scheduler = QueueScheduler(qos: .userInitiated, name: "com.instructure.SoPersistent")
        return syncContextModelsSignal
            .start(on: scheduler)
            .flatMap(.merge) { _ in return ModelPageSignalProducer.empty }
            .observe(on: UIScheduler())
    }
    
}
