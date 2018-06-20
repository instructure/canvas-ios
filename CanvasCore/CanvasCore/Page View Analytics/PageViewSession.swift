//
//  PageViewSession.swift
//  CanvasCore
//
//  Created by Garrett Richards on 6/18/18.
//  Copyright © 2018 Instructure, Inc. All rights reserved.
//

import Foundation

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
        }
        else {
            ID = UUIDFromDefaults()
        }
    }
    
    func sessionExpired(_ sessionDate: Date?) -> Bool {
        if let sessionDate = sessionDate {
            return Date().differenceInMinutes(sessionDate) >= sessionLengthInMinutes
        }
        else { return false }
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
            defaultsID = UUID().uuidString
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
    func dateByAddingMinutes(_ minutes: NSInteger) -> Date? {
        let calendar = Calendar.autoupdatingCurrent
        let components: NSCalendar.Unit = [.year, .month, .day, .hour, .minute, .second]
        var dateComponents = (calendar as NSCalendar).components(components, from: self)
        if let currentMinute = dateComponents.minute {
            dateComponents.minute = currentMinute + minutes
        }
        return calendar.date(from: dateComponents)
    }
    
    func differenceInMinutes(_ date: Date) -> Int {
        let calendar = Calendar.autoupdatingCurrent
        let deltaComponents = (calendar as NSCalendar).components(.minute, from: date, to: self, options: .matchStrictly)
        return deltaComponents.minute!
    }
}
