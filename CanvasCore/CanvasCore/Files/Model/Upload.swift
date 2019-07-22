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

import CoreData
import ReactiveSwift
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

    @objc open var hasStarted: Bool { return startedAt != nil }
    @objc open var isInProgress: Bool { return hasStarted && terminatedAt == nil }
    @objc open var hasCompleted: Bool { return completedAt != nil }
    @objc open var hasTerminated: Bool { return terminatedAt != nil }

    @NSManaged open fileprivate(set) var sent: Int64
    @NSManaged open fileprivate(set) var total: Int64

    open override func awakeFromInsert() {
        super.awakeFromInsert()
        id = UUID().uuidString
    }

    @objc open func startWithTask(_ task: URLSessionTask) {
        taskIdentifier = task.taskIdentifier as NSNumber?
        start()
    }

    @objc open func start() {
        if hasTerminated {
            reset()
        }
        startedAt = Date()
    }

    @objc open func reset() {
        startedAt = nil
        completedAt = nil
        terminatedAt = nil
        failedAt = nil
        errorMessage = nil
        canceledAt = nil
        sent = 0
        total = 0
    }

    @objc open func complete() {
        guard completedAt == nil && isInProgress else { return }
        completedAt = Date()
        terminate()
    }

    @objc open func failWithError(_ error: NSError) {
        guard failedAt == nil && !hasTerminated else { return }
        self.startedAt = startedAt ?? Date()
        self.errorMessage = [error.localizedDescription, error.localizedFailureReason].compactMap { $0 }.joined(separator: ": ")
        self.failedAt = Date()
        self.terminate()
    }

    @objc open func cancel() {
        guard canceledAt == nil && isInProgress else { return }
        self.canceledAt = Date()
        self.terminate()
    }

    fileprivate func terminate() {
        terminatedAt = Date()
    }
}

extension Upload {
    @objc open func process(sent: Int64, of total: Int64) {
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
