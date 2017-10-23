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


import Result
import ReactiveCocoa
import Marshal

extension Todo {
    public func markAsDone(_ session: Session, completion: ((Result<Bool, NSError>)->())? = nil) {
        guard let context = managedObjectContext else {
            ❨╯°□°❩╯⌢"Every object should have a context or we're screwed"
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
