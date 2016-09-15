//
//  SyncOperation.swift
//  Assignments
//
//  Created by Derrick Hathaway on 12/30/15.
//  Copyright © 2015 Instructure. All rights reserved.
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
                    var existing = try Set(Self.findAll(fetchLocal, inContext: syncContext))
                    
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
