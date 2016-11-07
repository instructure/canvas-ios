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
import ReactiveCocoa
import CoreData
import Marshal
import TooLegit

extension SynchronizedModel where Self: NSManagedObject {
    public typealias ModelPageSignalProducer = SignalProducer<[Self], NSError>
    
    public static func syncSignalProducer(localPredicate: NSPredicate? = nil, inContext context: NSManagedObjectContext, fetchRemote: SignalProducer<[JSONObject], NSError>, postProcess: (Self, JSONObject) throws -> Void = { _, _ in }) -> ModelPageSignalProducer {
        
        let syncContextModelsSignal = ModelPageSignalProducer({ observer, compositeDisposable in
            
            let syncContext = context.syncContext
            
            syncContext.performBlock() {
                do {
                    let fetchLocal = fetch(localPredicate, sortDescriptors: nil, inContext: syncContext)
                    fetchLocal.includesPropertyValues = false
                    fetchLocal.returnsObjectsAsFaults = true
                    var existing = try Set(syncContext.findAll(fromFetchRequest: fetchLocal))
                    
                    let upsertSignal: ModelPageSignalProducer = fetchRemote.flatMap(.Concat, transform: Self.upsert(inContext: syncContext, postProcess: postProcess))

                    upsertSignal.startWithSignal { signal, signalDisposable in
                        compositeDisposable += signalDisposable
                        
                        signal.observe { event in
                            syncContext.performBlock {
                                switch event {
                                case .Completed:
                                    
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
                                        observer.sendFailed(e)
                                    }
                                    
                                case .Next(let models):
                                    for model in models {
                                        existing.remove(model)
                                    }
                                    
                                    do {
                                        try syncContext.saveFRD()
                                        observer.sendNext(models)
                                    } catch let e as NSError {
                                        observer.sendFailed(e)
                                    }
                                    
                                default:
                                    observer.action(event)
                                }
                            }
                        }
                    }
                } catch let e as NSError {
                    observer.sendFailed(e)
                }
            }
        })

        let scheduler = QueueScheduler(qos: QOS_CLASS_USER_INITIATED, name: "com.instructure.SoPersistent")
        return syncContextModelsSignal
            .startOn(scheduler)
            .flatMap(.Merge) { _ in return ModelPageSignalProducer.empty }
            .observeOn(UIScheduler())
    }
    
}
