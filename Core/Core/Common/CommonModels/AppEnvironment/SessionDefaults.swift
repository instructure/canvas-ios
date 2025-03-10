//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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
import UIKit

public struct SessionDefaults: Equatable {
    /**
     This is a shared session storage with an empty string as `sessionID`.
     Can be used for testing/preview/fallback purposes.
     */
    public static let fallback = SessionDefaults(sessionID: "")
    public let sessionID: String

    /** This property is used by the file share extension to automatically select the course of the last viewed file in the app. The use-case is that the user views the assignment's file in the app, saves it to iOS Photos app, annotates it there and shares it back to the assignment. */
    public var submitAssignmentCourseID: String? {
        get { return self["submitAssignmentCourseID"] as? String }
        set { self["submitAssignmentCourseID"] = newValue }
    }

    /** This property is used by the file share extension to automatically select the assignment of the last viewed file in the app. The use-case is that the user views the assignment's file in the app, saves it to iOS Photos app, annotates it there and shares it back to the assignment. */
    public var submitAssignmentID: String? {
        get { return self["submitAssignmentID"] as? String }
        set { self["submitAssignmentID"] = newValue }
    }

    public var tokenExpires: Bool? {
        get { return self["tokenExpires"] as? Bool }
        set { self["tokenExpires"] = newValue }
    }

    public var showGradesOnDashboard: Bool? {
        get { return self["showGradesOnDashboard"] as? Bool }
        set {
            self["showGradesOnDashboard"] = newValue
            NotificationCenter.default.post(name: .showGradesOnDashboardDidChange, object: nil)
        }
    }

    public var isDashboardLayoutGrid: Bool {
        get { (self["isDashboardLayoutGrid"] as? Bool) ?? false }
        set { self["isDashboardLayoutGrid"] = newValue }
    }

    public var interfaceStyle: UIUserInterfaceStyle? {
        get {
            guard let styleInt = self["interfaceStyle"] else { return nil }
            return UIUserInterfaceStyle(rawValue: styleInt as? Int ?? -1)
        }
        set {
            guard let newValue = newValue else { return self["interfaceStyle"] = nil}
            self["interfaceStyle"] = newValue.rawValue
        }
    }

    public var isMissingItemsSectionOpenOnK5Schedule: Bool? {
        get { return self["isMissingItemsSectionOpenOnK5Schedule"] as? Bool }
        set { self["isMissingItemsSectionOpenOnK5Schedule"] = newValue }
    }

    public var isElementaryViewEnabled: Bool {
        get { (self["isElementaryViewEnabled"] as? Bool) ?? true }
        set { self["isElementaryViewEnabled"] = newValue }
    }

    public var isK5StudentView: Bool {
        get { (self["isK5StudentView"] as? Bool) ?? false }
        set { self["isK5StudentView"] = newValue }
    }

    public var landingPath: String? {
        mutating get {
            if let landingPath = self["landingPath"] as? String {
                return landingPath
            }
            if let legacy = (UserDefaults.standard.object(forKey: "landingPageSettings") as? [String: String])?.first?.value {
                let map = [
                    "Courses": "/",
                    "Calendar": "/calendar",
                    "To-Do List": "/to-do",
                    "Notifications": "/notifications",
                    "Messages": "/conversations"
                ]
                if let path = map[legacy] {
                    self.landingPath = path
                    return path
                }
            }
            return nil
        }
        set { self["landingPath"] = newValue }
    }

    public var limitWebAccess: Bool? {
        get { self["limitWebAccess"] as? Bool }
        set { self["limitWebAccess"] = newValue }
    }

    public var parentCurrentStudentID: String? {
        get { self["parentCurrentStudentID"] as? String }
        set { self["parentCurrentStudentID"] = newValue }
    }

    public var parentColorScheme: [String: Int]? {
        get { self["parentColorScheme"] as? [String: Int] }
        set { self["parentColorScheme"] = newValue }
    }

    public var hasSetPSPDFKitLastUsedValues: Bool {
        get { return self["hasSetPSPDFKitLastUsedValues"] as? Bool ?? false }
        set { self["hasSetPSPDFKitLastUsedValues"] = newValue }
    }

    public var collapsedModules: [String: [String]]? {
        get { self["collapsedModules"] as? [String: [String]] }
        set { self["collapsedModules"] = newValue }
    }

    // MARK: - Calendar Settings

    private typealias ObservedStudentID = String
    private typealias CanvasContextId = String
    private let calendarSelectedContextsContainerKey = "calendarSelectedContexts"

    public mutating func setCalendarSelectedContexts(
        _ selectedContexts: Set<Context>,
        observedStudentId: String?
    ) {
        let observedStudentId = observedStudentId ?? ""
        var container = self[calendarSelectedContextsContainerKey] as? [ObservedStudentID: [CanvasContextId]] ?? [:]
        container[observedStudentId] = Array(selectedContexts.map { $0.canvasContextID })
        self[calendarSelectedContextsContainerKey] = container
    }

    /**
     - returns: Nil if the user has never selected calendars.
     */
    public func calendarSelectedContexts(observedStudentId: String?) -> Set<Context>? {
        let observedStudentId = observedStudentId ?? ""

        guard
            let container = self[calendarSelectedContextsContainerKey] as? [ObservedStudentID: [CanvasContextId]],
            let selectedContextCodes = container[observedStudentId]
        else {
            return nil
        }

        let selectedContexts = selectedContextCodes.compactMap { Context(canvasContextID: $0) }

        return Set(selectedContexts)
    }

    // MARK: - Offline Settings

    public var isOfflineAutoSyncEnabled: Bool? {
        get { self["isOfflineAutoSyncEnabled"] as? Bool }
        set { self["isOfflineAutoSyncEnabled"] = newValue }
    }

    public var offlineSyncFrequency: CourseSyncFrequency? {
        get {
            guard let raw = self["offlineSyncFrequency"] as? Int,
                  let syncFrequency = CourseSyncFrequency(rawValue: raw) else {
                return nil
            }
            return syncFrequency
        }
        set { self["offlineSyncFrequency"] = newValue?.rawValue }
    }

    public var offlineSyncNextDate: Date? {
        get { self["offlineSyncNextDate"] as? Date }
        set { self["offlineSyncNextDate"] = newValue }
    }

    public var isOfflineWifiOnlySyncEnabled: Bool? {
        get { self["isOfflineWifiOnlySyncEnabled"] as? Bool }
        set { self["isOfflineWifiOnlySyncEnabled"] = newValue }
    }

    public var offlineSyncSelections: [CourseSyncItemSelection] {
        get {
            self["offlineSyncSelections"] as? [String] ?? []
        }
        set {
            self["offlineSyncSelections"] = newValue
        }
    }

    // MARK: Offline Settings -

    public mutating func reset() {
        sessionDefaults = nil
    }

    private subscript(key: String) -> Any? {
        get { return sessionDefaults?[key] }
        set {
            var defaults = sessionDefaults ?? [:]
            if let value = newValue {
                defaults[key] = value
            } else {
                defaults.removeValue(forKey: key)
            }
            sessionDefaults = defaults
        }
    }

    private var userDefaults: UserDefaults {
        return UserDefaults(suiteName: Bundle.main.appGroupID()) ?? .standard
    }

    private var sessionDefaults: [String: Any]? {
        get { return userDefaults.dictionary(forKey: sessionID) }
        set { userDefaults.set(newValue, forKey: sessionID) }
    }

    // MARK: - Grades
    public var selectedGradingPeriodIdsByCourseIDs: [String: String]? {
        get { self["selectedGradingPeriodIdsByCourseIDs"] as? [String: String] }
        set { self["selectedGradingPeriodIdsByCourseIDs"] = newValue }
    }

    public var selectedSortByOptionIDs: [String: String]? {
        get { self["selectedSortByOptionIDs"] as? [String: String] }
        set { self["selectedSortByOptionIDs"] = newValue }
    }

    // MARK: - Assignments
    public var assignmentListGroupBySettingByCourseId: [String: String]? {
        get { self["assignmentListGroupBySettingByCourseId"] as? [String: String] }
        set { self["assignmentListGroupBySettingByCourseId"] = newValue }
    }

    public var assignmentListStudentFilterSettingsByCourseId: [String: [String]]? {
        get { self["assignmentListStudentFilterSettingsByCourseId"] as? [String: [String]] }
        set { self["assignmentListStudentFilterSettingsByCourseId"] = newValue }
    }

    public var assignmentListTeacherFilterSettingByCourseId: [String: String]? {
        get { self["assignmentListTeacherFilterSettingByCourseId"] as? [String: String] }
        set { self["assignmentListTeacherFilterSettingByCourseId"] = newValue }
    }

    public var assignmentListTeacherStatusFilterSettingByCourseId: [String: String]? {
        get { self["assignmentListTeacherStatusFilterSettingByCourseId"] as? [String: String] }
        set { self["assignmentListTeacherStatusFilterSettingByCourseId"] = newValue }
    }
}
