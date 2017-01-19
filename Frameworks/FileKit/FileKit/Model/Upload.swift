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
    
    

import CoreData
import ReactiveSwift
import TooLegit
import SoLazy
import Result
import SoPersistent
import WebKit

open class Upload: NSManagedObject {
    @NSManaged open var id: String
    @NSManaged open var backgroundSessionID: String
    @NSManaged open fileprivate(set) var taskIdentifier: NSNumber?
    @NSManaged open fileprivate(set) var startedAt: Date?
    @NSManaged open fileprivate(set) var completedAt: Date?
    @NSManaged open fileprivate(set) var failedAt: Date?
    @NSManaged open fileprivate(set) var canceledAt: Date?
    @NSManaged open fileprivate(set) var terminatedAt: Date?
    @NSManaged open fileprivate(set) var errorMessage: String?

    open var hasStarted: Bool { return startedAt != nil }
    open var isInProgress: Bool { return hasStarted && terminatedAt == nil }
    open var hasCompleted: Bool { return completedAt != nil }
    open var hasTerminated: Bool { return terminatedAt != nil }

    @NSManaged open var sent: Int64
    @NSManaged open var total: Int64

    open override func awakeFromInsert() {
        super.awakeFromInsert()
        id = UUID().uuidString
    }

    open func startWithTask(_ task: URLSessionTask) {
        taskIdentifier = task.taskIdentifier as NSNumber?
        start()
    }

    fileprivate func start() {
        guard startedAt == nil else { return }
        startedAt = Date()
    }

    open func complete() {
        guard completedAt == nil && isInProgress else { return }
        completedAt = Date()
        terminate()
    }

    open func failWithError(_ error: NSError) {
        guard failedAt == nil && isInProgress else { return }
        self.errorMessage = [error.localizedDescription, error.localizedFailureReason].flatMap { $0 }.joined(separator: ": ")
        self.failedAt = Date()
        self.terminate()
    }

    open func cancel() {
        guard canceledAt == nil && isInProgress else { return }
        self.canceledAt = Date()
        self.terminate()
    }

    fileprivate func terminate() {
        terminatedAt = Date()
    }
}

//// FileKit+RAC
extension Upload {
//    public var onCompleted: SignalProducer<Void, NSError> {
//        MutableProperty
//        return rac_valuesForKeyPath("completedAt", observer: nil)
//            .toSignalProducer()
//            .map { $0 as? NSDate }
//            .filter { $0 != nil }
//            .map({})
//            .take(1)
//    }
//
//    public var onStarted: SignalProducer<Void, NSError> {
//        return rac_valuesForKeyPath("startedAt", observer: nil)
//            .toSignalProducer()
//            .map { $0 as? NSDate }
//            .filter { $0 != nil }
//            .map({})
//            .take(1)
//    }
//    
//    public var onFailed: SignalProducer<String?, NSError> {
//        return rac_valuesForKeyPath("failedAt", observer: nil)
//            .toSignalProducer()
//            .map { $0 as? NSDate }
//            .filter { $0 != nil }
//            .map { self.errorMessage }
//            .take(1)
//    }
//
    public func saveError(_ context: NSManagedObjectContext) -> (NSError) -> SignalProducer<Void, NSError> {
        return { error in
            return attemptProducer {
                self.failWithError(error)
                try context.save()
            }
        }
    }
}
