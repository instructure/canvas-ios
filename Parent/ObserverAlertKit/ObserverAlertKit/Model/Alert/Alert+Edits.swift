//
//  Alert+Edits.swift
//  ObserverAlertKit
//
//  Created by Ben Kraus on 3/9/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import SoPersistent
import TooLegit
import ReactiveCocoa
import Result

extension Alert {
    public func dismiss(session: Session, completion: (Result<Bool, NSError>->())? = nil) {
        guard let context = managedObjectContext else {
            fatalError("Every Object should have a context or we're already screwed")
        }

        context.performBlock {
            self.dismissed = true
            let _ = try? context.save()
        }

        do {
            let producer = try markDismissed(true, session: session)
            producer.startWithSignal { signal, disposable in
                signal.observeOn(ManagedObjectContextScheduler(context: context)).observe { event in
                    switch event {
                    case .Completed:
                        completion?(.Success(true))
                    case .Failed(let error):
                        self.dismissed = false
                        let _ = try? context.save()
                        completion?(.Failure(error))
                    default:
                        break
                    }
                }
            }
        } catch let e as NSError {
            completion?(.Failure(e))
        }
    }

    public func markAsRead(session: Session, completion: (Result<Bool, NSError>->())? = nil) {
        guard let context = managedObjectContext else {
            fatalError("Every Object should have a context or we're already screwed")
        }

        context.performBlock {
            self.read = true
            let _ = try? context.save()
        }

        do {
            let producer = try markAsRead(true, session: session)
            producer.startWithSignal { signal, disposable in
                signal.observeOn(ManagedObjectContextScheduler(context: context)).observe { event in
                    switch event {
                    case .Completed:
                        completion?(.Success(true))
                    case .Failed(let error):
                        self.read = false
                        let _ = try? context.save()
                        completion?(.Failure(error))
                    default:
                        break
                    }
                }
            }
        } catch let e as NSError {
            completion?(.Failure(e))
        }
    }
}