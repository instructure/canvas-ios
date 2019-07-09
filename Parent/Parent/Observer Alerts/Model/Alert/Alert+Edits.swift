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
import CanvasCore
import ReactiveSwift
import Result

extension Alert {
    public func dismiss(_ session: Session, completion: ((Result<Bool, NSError>)->())? = nil) {
        guard let context = managedObjectContext else {
            fatalError("Every Object should have a context or we're already screwed")
        }

        context.perform {
            self.dismissed = true
            let _ = try? context.save()
        }

        do {
            let producer = try markDismissed(true, session: session)
            producer.startWithSignal { signal, disposable in
                signal.observe(on: ManagedObjectContextScheduler(context: context)).observeResult { result in
                    if case .failure(let e) = result {
                        self.dismissed = false
                        let _ = try? context.save()
                        if e.code == 401 {
                            AirwolfAPI.validateSessionAndLogout(session, parentID: session.user.id)
                        }
                    }
                    
                    completion?(result.map { _ in true })
                }
            }
        } catch let e as NSError {
            completion?(.failure(e))
        }
    }

    public func markAsRead(_ session: Session, completion: ((Result<Bool, NSError>)->())? = nil) {
        guard let context = managedObjectContext else {
            fatalError("Every Object should have a context or we're already screwed")
        }

        context.perform {
            self.read = true
            let _ = try? context.save()
        }

        do {
            let producer = try markAsRead(true, session: session)
            producer.startWithSignal { signal, disposable in
                signal.observe(on: ManagedObjectContextScheduler(context: context)).observeResult { result in
                    if case .failure(let e) = result {
                        self.read = false
                        let _ = try? context.save()
                        if e.code == 401 {
                            AirwolfAPI.validateSessionAndLogout(session, parentID: session.user.id)
                        }
                    }
                    
                    completion?(result.map { _ in true })
                }
            }
        } catch let e as NSError {
            completion?(.failure(e))
        }
    }
}
