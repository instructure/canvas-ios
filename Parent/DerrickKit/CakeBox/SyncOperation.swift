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
import JaSON

extension SynchronizedModel {
    public typealias ModelSignalProducer = SignalProducer<Self, NSError>
    
    public static func syncSignalProducer(fetchLocal: NSFetchRequest, inContext context: NSManagedObjectContext, fetchRemote: SignalProducer<JSONObject, NSError>) -> SignalProducer<Self, NSError> {
        let syncContext = context.syncContext
        
        return ModelSignalProducer({ observer, compositeDisposable in
            syncContext.performBlock() {
                do {
                    var existing = try Set(Self.findAll(fetchLocal, inContext: syncContext))
                    
                    let upsertSignal: ModelSignalProducer = fetchRemote.flatMap(.Concat, transform: Self.upsert(inContext: syncContext))
                    
                    upsertSignal.startWithSignal { signal, signalDisposable in
                        compositeDisposable += signalDisposable
                        
                        signal.observe { event in
                            switch event {
                            case .Completed:
                                print("existing: \(existing)")
                                
                                for item in existing {
                                    item.delete(inContext: syncContext)
                                }
                                
                                // Holiday Extravaganza TODO: Doh, forgot one use-case
                                
                                do {
                                    try syncContext.saveFRD()
                                    observer.sendCompleted()
                                } catch let e as NSError {
                                    observer.sendFailed(e)
                                }
                                
                            case .Next(let value):
                                existing.remove(value)
                                observer.sendNext(value)
                                
                            default:
                                observer.action(event)
                            }
                        }
                    }
                } catch let e as NSError {
                    observer.sendFailed(e)
                }
            }
        })
        
            // Holiday Extravaganza TODO: Name that queue
        .startOn(QueueScheduler(queue: dispatch_queue_create("com.instructure.cakebox.sync", DISPATCH_QUEUE_CONCURRENT)))
        .observeOn(UIScheduler())
    }
    
}
