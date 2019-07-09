//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import Foundation


import Result
import ReactiveCocoa
import Marshal

extension Todo {
    public func markAsDone(_ session: Session, completion: ((Result<Bool, NSError>)->())? = nil) {
        guard let context = managedObjectContext else {
            fatalError("Every object should have a context or we're screwed")
        }

        context.perform {
            self.done = true
            let _ = try? context.save()
        }

        do {
            let producer = try ignore(session)
            producer.startWithSignal { signal, disposable in
                signal.observe { event in
                    switch event {
                    case .completed:
                        completion?(.success(true))
                    case .failed(let error):
                        context.perform {
                            self.done = false
                            let _ = try? context.save()
                        }
                        completion?(.failure(error))
                    case .interrupted:
                        context.perform {
                            self.done = false
                            let _ = try? context.save()
                        }
                        let error = NSError(subdomain: "Todos", description: NSLocalizedString("The request to mark a to do as done was interrupted", tableName: "Localizable", bundle: .core, value: "", comment: "Error message for interrupted requests marking a to do as done"))
                        completion?(.failure(error))
                    default:
                        break
                    }
                }
            }
        } catch let e as NSError {
            context.perform {
                self.done = false
                let _ = try? context.save()
            }
            completion?(.failure(e))
        }
    }
}
