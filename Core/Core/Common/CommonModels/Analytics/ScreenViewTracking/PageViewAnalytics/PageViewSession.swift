//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

import UIKit

class PageViewSession {
    var creationDate: Date?
    var ID: String = ""
    var sessionLengthInMinutes: Int = 30
    static let sessionCreationDateKey = "com.instructure.pageview.session.creationDate"
    static let UUIDKey = "com.instructure.pageview.session.UUID"

    init(defaultSessionLength: Int = 30) {
        sessionLengthInMinutes = defaultSessionLength
        setup()
    }

    func setup() {
        creationDate = dateFromDefaults()
        if sessionExpired(creationDate) || creationDate == nil {
            resetSessionInfo()
        } else {
            ID = UUIDFromDefaults()
        }
    }

    func sessionExpired(_ sessionDate: Date?) -> Bool {
        if let sessionDate = sessionDate {
            return Date().differenceInMinutes(sessionDate) >= sessionLengthInMinutes
        } else { return false }
    }

    func resetSessionInfo() {
        ID = UUIDFromDefaults(true)
        creationDate = Date()
        if let creationDate = creationDate {
            persistCreationDate(creationDate)
        }
    }

    func UUIDFromDefaults(_ reset: Bool = false) -> String {
        var defaultsID = UserDefaults.standard.object(forKey: type(of: self).UUIDKey) as? String
        if defaultsID == nil || reset {
            defaultsID = Foundation.UUID().uuidString
            UserDefaults.standard.set(defaultsID, forKey: type(of: self).UUIDKey)
            UserDefaults.standard.synchronize()
        }
        return defaultsID ?? ""
    }

    func persistCreationDate(_ creationDate: Date) {
        UserDefaults.standard.set(creationDate, forKey: type(of: self).sessionCreationDateKey)
        UserDefaults.standard.synchronize()
    }

    func dateFromDefaults() -> Date? {
        let date = UserDefaults.standard.object(forKey: type(of: self).sessionCreationDateKey) as? Date
        return date
    }
}

extension Date {
    func differenceInMinutes(_ date: Date) -> Int {
        let calendar = Calendar.autoupdatingCurrent
        let deltaComponents = (calendar as NSCalendar).components(.minute, from: date, to: self, options: .matchStrictly)
        return deltaComponents.minute!
    }
}
