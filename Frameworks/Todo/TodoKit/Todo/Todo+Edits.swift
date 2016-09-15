//
//  Todo+Edits.swift
//  Todo
//
//  Created by Ben Kraus on 4/27/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import TooLegit
import SoLazy
import Result
import ReactiveCocoa
import Marshal

extension Todo {
    public func markAsDone(session: Session, completion: (Result<Bool, NSError>->())? = nil) {
        guard let context = managedObjectContext else {
            ❨╯°□°❩╯⌢"Every object should have a context or we're screwed"
        }

        context.performBlock {
            self.done = true
            let _ = try? context.save()
        }

        do {
            let producer = try ignore(session)
            producer.startWithSignal { signal, disposable in
                signal.observe { event in
                    switch event {
                    case .Completed:
                        completion?(.Success(true))
                    case .Failed(let error):
                        context.performBlock {
                            self.done = false
                            let _ = try? context.save()
                        }
                        completion?(.Failure(error))
                    case .Interrupted:
                        context.performBlock {
                            self.done = false
                            let _ = try? context.save()
                        }
                        let error = NSError(subdomain: "Todos", description: NSLocalizedString("The request to mark a to do as done was interrupted", comment: "Error message for interrupted requests marking a to do as done"))
                        completion?(.Failure(error))
                    default:
                        break
                    }
                }
            }
        } catch let e as NSError {
            context.performBlock {
                self.done = false
                let _ = try? context.save()
            }
            completion?(.Failure(e))
        }
    }
}