//
// Copyright (C) 2018-present Instructure, Inc.
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
import UserNotifications
import CoreData

public enum LoggableType: String, Hashable, CaseIterable {
    case log, error
}

public protocol Loggable {
    var timestamp: Date { get }
    var type: LoggableType { get }
    var message: String { get }
}

public protocol LoggerProtocol {
    var queue: OperationQueue { get }
    func log(_ message: String)
    func error(_ message: String)
    func clearAll()
}

public class Logger: LoggerProtocol {
    public var database: Persistence
    public let queue: OperationQueue

    public static let shared = Logger()

    public init() {
        self.database = NSPersistentContainer.create()
        self.queue = OperationQueue()
    }

    public func log(_ message: String) {
        logEvent(.log, message: message)
    }

    public func error(_ message: String) {
        logEvent(.error, message: message)
    }

    private func logEvent(_ type: LoggableType, message: String) {
        print("[\(type.rawValue)]", message)
        let insert = DatabaseOperation(database: database) { client in
            let event: LogEvent = client.insert()
            event.timestamp = Clock.now
            event.type = type
            event.message = message
        }
        queue.addOperation(insert)
    }

    public func clearAll() {
        let clear = DatabaseOperation(database: database) { client in
            let events: [LogEvent] = client.fetch()
            for event in events {
                try client.delete(event)
            }
        }
        queue.addOperation(clear)
    }
}

extension LogEvent: Loggable {
    public var type: LoggableType {
        get { return LoggableType(rawValue: typeRaw) ?? .log }
        set { typeRaw = newValue.rawValue }
    }
}
