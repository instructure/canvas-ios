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
    func log(_ message: String)
    func error(_ message: String)
    func clearAll()
}

public class Logger: LoggerProtocol {
    public var database: Persistence

    public static let shared = Logger()

    public init() {
        self.database = NSPersistentContainer.create()
    }

    public func log(_ message: String = #function) {
        logEvent(.log, message: message)
    }

    public func error(_ message: String) {
        logEvent(.error, message: message)
    }

    public func error(_ error: Error) {
        logEvent(.error, message: error.localizedDescription)
    }

    private func logEvent(_ type: LoggableType, message: String) {
        print("[\(type.rawValue)]", message)
        database.performBackgroundTask { client in
            let event: LogEvent = client.insert()
            event.timestamp = Clock.now
            event.type = type
            event.message = message
            try? client.save()
        }
    }

    public func clearAll() {
        database.performBackgroundTask { client in
            let events: [LogEvent] = client.fetch()
            try? client.delete(events)
            try? client.save()
        }
    }
}

extension LogEvent: Loggable {
    public var type: LoggableType {
        get { return LoggableType(rawValue: typeRaw) ?? .log }
        set { typeRaw = newValue.rawValue }
    }
}
