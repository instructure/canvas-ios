//
//  Student+Edits.swift
//  Airwolf
//
//  Created by Ben Kraus on 5/17/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import SoPersistent
import TooLegit
import ReactiveCocoa
import Result

extension Student {
    public func remove(session: Session, completion: (Result<(), NSError>->())? = nil) {
        guard let context = managedObjectContext else {
            fatalError("Every Object should have a context or we're already screwed")
        }

        do {
            let producer = try Student.deleteStudent(session, parentID: session.user.id, studentID: id)
            producer.startWithSignal { signal, disposable in
                signal.observe { event in
                    switch event {
                    case .Failed(let e):
                        print("Error removing student: \(e), \(index)")
                        completion?(.Failure(e))
                    case .Completed:
                        print("Student Deleted")
                        context.performBlock {
                            context.deleteObject(self)
                        }
                        completion?(.Success(()))
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