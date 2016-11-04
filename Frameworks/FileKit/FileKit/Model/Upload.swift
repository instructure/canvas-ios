
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
import ReactiveCocoa
import TooLegit
import SoLazy
import Result
import SoPersistent
import WebKit

public class Upload: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var backgroundSessionID: String
    @NSManaged public private(set) var taskIdentifier: NSNumber?
    @NSManaged public private(set) var startedAt: NSDate?
    @NSManaged public private(set) var completedAt: NSDate?
    @NSManaged public private(set) var failedAt: NSDate?
    @NSManaged public private(set) var canceledAt: NSDate?
    @NSManaged public private(set) var terminatedAt: NSDate?
    @NSManaged public private(set) var errorMessage: String?

    public var hasStarted: Bool { return startedAt != nil }
    public var isInProgress: Bool { return hasStarted && terminatedAt == nil }
    public var hasCompleted: Bool { return completedAt != nil }
    public var hasTerminated: Bool { return terminatedAt != nil }

    @NSManaged public var sent: Int64
    @NSManaged public var total: Int64

    public override func awakeFromInsert() {
        super.awakeFromInsert()
        id = NSUUID().UUIDString
    }

    public func startWithTask(task: NSURLSessionTask) {
        taskIdentifier = task.taskIdentifier
        start()
    }

    private func start() {
        guard startedAt == nil else { return }
        startedAt = NSDate()
    }

    public func complete() {
        guard completedAt == nil && isInProgress else { return }
        completedAt = NSDate()
        terminate()
    }

    public func failWithError(error: NSError) {
        guard failedAt == nil && isInProgress else { return }
        self.errorMessage = [error.localizedDescription, error.localizedFailureReason].flatMap { $0 }.joinWithSeparator(": ")
        self.failedAt = NSDate()
        self.terminate()
    }

    public func cancel() {
        guard canceledAt == nil && isInProgress else { return }
        self.canceledAt = NSDate()
        self.terminate()
    }

    private func terminate() {
        terminatedAt = NSDate()
    }
}

// FileKit+RAC
extension Upload {
    public var onCompleted: SignalProducer<Void, NSError> {
        return rac_valuesForKeyPath("completedAt", observer: nil)
            .toSignalProducer()
            .map { $0 as? NSDate }
            .filter { $0 != nil }
            .map({})
            .take(1)
    }

    public var onStarted: SignalProducer<Void, NSError> {
        return rac_valuesForKeyPath("startedAt", observer: nil)
            .toSignalProducer()
            .map { $0 as? NSDate }
            .filter { $0 != nil }
            .map({})
            .take(1)
    }
    
    public var onFailed: SignalProducer<String?, NSError> {
        return rac_valuesForKeyPath("failedAt", observer: nil)
            .toSignalProducer()
            .map { $0 as? NSDate }
            .filter { $0 != nil }
            .map { self.errorMessage }
            .take(1)
    }

    public func saveError(context: NSManagedObjectContext) -> NSError -> SignalProducer<Void, NSError> {
        return { error in
            return attemptProducer {
                self.failWithError(error)
                try context.save()
            }
        }
    }
}
