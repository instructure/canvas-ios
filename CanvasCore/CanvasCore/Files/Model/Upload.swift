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


import Result

import WebKit

open class Upload: NSManagedObject {
    @NSManaged open var id: String
    @NSManaged open var backgroundSessionID: String
    @NSManaged open internal(set) var taskIdentifier: NSNumber?
    @NSManaged open internal(set) var startedAt: Date?
    @NSManaged open internal(set) var completedAt: Date?
    @NSManaged open internal(set) var failedAt: Date?
    @NSManaged open internal(set) var canceledAt: Date?
    @NSManaged open internal(set) var terminatedAt: Date?
    @NSManaged open internal(set) var errorMessage: String?

    open var hasStarted: Bool { return startedAt != nil }
    open var isInProgress: Bool { return hasStarted && terminatedAt == nil }
    open var hasCompleted: Bool { return completedAt != nil }
    open var hasTerminated: Bool { return terminatedAt != nil }

    @NSManaged open fileprivate(set) var sent: Int64
    @NSManaged open fileprivate(set) var total: Int64

    open override func awakeFromInsert() {
        super.awakeFromInsert()
        id = UUID().uuidString
    }

    open func startWithTask(_ task: URLSessionTask) {
        taskIdentifier = task.taskIdentifier as NSNumber?
        start()
    }

    open func start() {
        if hasTerminated {
            reset()
        }
        startedAt = Date()
    }

    open func reset() {
        startedAt = nil
        completedAt = nil
        terminatedAt = nil
        failedAt = nil
        errorMessage = nil
        canceledAt = nil
        sent = 0
        total = 0
    }

    open func complete() {
        guard completedAt == nil && isInProgress else { return }
        completedAt = Date()
        terminate()
    }

    open func failWithError(_ error: NSError) {
        guard failedAt == nil && !hasTerminated else { return }
        self.startedAt = startedAt ?? Date()
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

extension Upload {
    open func process(sent: Int64, of total: Int64) {
        self.sent = sent
        self.total = total
    }

    open func saveError(_ context: NSManagedObjectContext) -> (NSError) -> SignalProducer<Void, NSError> {
        return { error in
            return attemptProducer {
                self.failWithError(error)
                try context.save()
            }
        }
    }
}

extension Upload {
    public enum Status {
        case notStarted
        case inProgress(Double)
        case completed
        case failed(String)
        case cancelled

        var terminated: Bool {
            switch self {
            case .completed, .failed, .cancelled:
                return true
            case .inProgress, .notStarted:
                return false
            }
        }
    }

    public var status: Status? {
        if startedAt == nil {
            return .notStarted
        }

        if completedAt != nil {
            return .completed
        }

        if failedAt != nil {
            guard let message = errorMessage else {
                fatalError("no error message?")
            }
            return .failed(message)
        }

        if canceledAt != nil {
            return .cancelled
        }

        if startedAt != nil, terminatedAt == nil {
            let progress = total > 0 ? (Double(sent) * 100) / Double(total) : 0
            return .inProgress(progress)
        }

        return nil
    }
}
