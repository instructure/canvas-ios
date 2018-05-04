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
import ReactiveSwift
import Result
import CanvasCore

extension AlertThreshold {
    public func remove(_ session: Session) -> SignalProducer<Bool, NSError> {
        return SignalProducer { [weak self] observer, disposable in
            guard let me = self, let context = me.managedObjectContext else {
                fatalError("Every Object should have a context or we're already screwed")
            }

            do {
                let type = me.type
                let threshold = me.threshold
                let thresholdID = me.id
                let observerID = me.observerID
                let studentID = me.studentID

                context.performAndWait {
                    me.delete(inContext: context)
                    let _ = try? context.save()
                }

                let producer = try me.deleteAlertThreshold(session, observerID: session.user.id, thresholdID: thresholdID)
                producer.startWithSignal { signal, disposable in
                    signal.observe(on: ManagedObjectContextScheduler(context: context)).observe { event in
                        switch event {
                        case .failed(let e):
                            let alertThreshold = AlertThreshold(inContext: context)
                            alertThreshold.type = type
                            alertThreshold.threshold = threshold
                            alertThreshold.observerID = observerID
                            alertThreshold.studentID = studentID
                            alertThreshold.id = thresholdID

                            try? context.save()
                            observer.send(error: e)
                            if e.code == 401 {
                                AirwolfAPI.validateSessionAndLogout(session, parentID: session.user.id)
                            }
                        case .value(_):
                            observer.send(value: true)
                        case .completed:
                            observer.sendCompleted()
                        default:
                            break
                        }
                    }
                }
            } catch let e as NSError {
                observer.send(error: e)
            }
        }
    }

    public static func createThreshold(_ session: Session, type: AlertThresholdType, observerID: String, observeeID: String, threshold: String? = nil) -> SignalProducer<Bool, NSError> {
        return SignalProducer { observer, disposable in
            do {
                let context = try session.alertsManagedObjectContext()
                let alertThreshold = AlertThreshold(inContext: context)

                context.performAndWait {
                    alertThreshold.type = type
                    alertThreshold.threshold = threshold
                    alertThreshold.observerID = observerID
                    alertThreshold.studentID = observeeID
                    alertThreshold.id = "\(alertThreshold.objectID)"

                    let _ = try? context.save()
                }

                let producer = try AlertThreshold.insertAlertThreshold(session, observerID: session.user.id, studentID: observeeID, type: type.rawValue, threshold: threshold).observe(on: ManagedObjectContextScheduler(context: context))
                    .flatMap(.concat) { json in
                        return attemptProducer {
                            let _ = try? alertThreshold.updateValues(json, inContext: context)
                            let _ = try? context.save()
                        }
                }
                producer.startWithSignal { signal, disposable in
                    signal.observe(on: ManagedObjectContextScheduler(context: context)).observe { event in
                        switch event {
                        case .failed(let e):
                            alertThreshold.delete(inContext: context)
                            let _ = try? context.save()
                            observer.send(error: e)
                            if e.code == 401 {
                                AirwolfAPI.validateSessionAndLogout(session, parentID: session.user.id)
                            }
                        case .value(_):
                            observer.send(value: true)
                        case .completed:
                            observer.sendCompleted()
                        default:
                            break
                        }
                    }
                }
            } catch let e as NSError {
                observer.send(error: e)
            }
        }
    }

    public func update(_ session: Session, newThreshold: String) -> SignalProducer<Bool, NSError> {
        return SignalProducer { [weak self] observer, disposable in
            guard let me = self, let context = me.managedObjectContext else {
                fatalError("Every Object should have a context or we're already screwed")
            }

            do {
                let oldThresholdValue = me.threshold
                context.performAndWait {
                    me.threshold = newThreshold
                    let _ = try? context.save()
                }

                let producer = try me.updateAlertThreshold(session, observerID: session.user.id)
                producer.startWithSignal { signal, disposable in
                    signal.observe(on: ManagedObjectContextScheduler(context: context)).observe { event in
                        switch event {
                        case .failed(let e):
                            me.threshold = oldThresholdValue
                            let _ = try? context.save()
                            observer.send(error: e)
                            if e.code == 401 {
                                AirwolfAPI.validateSessionAndLogout(session, parentID: session.user.id)
                            }
                        case .value(_):
                            observer.send(value: true)
                        case .completed:
                            observer.sendCompleted()
                        default:
                            break
                        }
                    }
                }
            } catch let e as NSError {
                observer.send(error: e)
            }
        }
    }
}
