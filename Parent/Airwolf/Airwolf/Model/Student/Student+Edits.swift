
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