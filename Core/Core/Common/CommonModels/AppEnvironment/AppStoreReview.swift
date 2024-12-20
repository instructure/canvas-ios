//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
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
import StoreKit

public class AppStoreReview: NSObject {
    static let lastRequestDateKey = "InstLastReviewRequestKey"
    static let viewAssignmentDateKey = "InstViewAssignmentDateKey"
    static let viewAssignmentCountKey = "InstViewAssignmentCountKey"
    static let launchCountKey = "InstLaunchCount"
    static let fakeRequestKey = "InstFakeReviewRequestKey"

    private class func requestReview() {
        if UserDefaults.standard.bool(forKey: fakeRequestKey) {
            let appName = Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String ?? ""
            let alert = UIAlertController(title: "Enjoying \(appName)?", message: "This is a fake request to rate it on the App Store.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Submit", style: .default))

            if let top = AppEnvironment.shared.topViewController {
                AppEnvironment.shared.router.show(alert, from: top, options: .modal())
            }
        } else {
            #if RELEASE

            if let windowScene = AppEnvironment.shared.window?.windowScene {
                SKStoreReviewController.requestReview(in: windowScene)
            }

            #endif
        }
        UserDefaults.standard.set(Date(), forKey: lastRequestDateKey)
    }

    private class func requestReviewIfAppropriate() {
        let date = UserDefaults.standard.value(forKey: lastRequestDateKey) as? Date ?? Date.distantPast
        let calendar = Calendar.current
        let comps = calendar.dateComponents([.day], from: date, to: Date())
        if let daysSince = comps.day, daysSince > 30 {
            requestReview()
        }
    }

    public class func handleLaunch() {
        let count = UserDefaults.standard.integer(forKey: launchCountKey) + 1
        UserDefaults.standard.set(count, forKey: launchCountKey)
        if count >= 10 {
            requestReviewIfAppropriate()
        }
    }

    @objc
    public class func handleSuccessfulSubmit() {
        requestReviewIfAppropriate()
    }

    @objc
    public class func handleNavigateToAssignment() {
        // or discussion, or announcement
        let date = UserDefaults.standard.value(forKey: viewAssignmentDateKey) as? Date ?? Date.distantPast
        if Calendar.current.isDateInYesterday(date) { // yesterday
            let count = UserDefaults.standard.integer(forKey: viewAssignmentCountKey)
            UserDefaults.standard.set(count + 1, forKey: viewAssignmentCountKey)
            UserDefaults.standard.set(Date(), forKey: viewAssignmentDateKey)
        } else if !Calendar.current.isDateInToday(date) { // not today
            UserDefaults.standard.set(1, forKey: viewAssignmentCountKey)
            UserDefaults.standard.set(Date(), forKey: viewAssignmentDateKey)
        } // else already updated today, do nothing
    }

    @objc
    public class func handleNavigateFromAssignment() {
        let count = UserDefaults.standard.integer(forKey: viewAssignmentCountKey)
        let date = UserDefaults.standard.value(forKey: viewAssignmentDateKey) as? Date ?? Date.distantPast
        if count >= 3 && Calendar.current.isDateInToday(date) {
            requestReviewIfAppropriate()
        }
    }

    @objc
    public class func getState() -> [String: Int] {
        func getTime (forKey: String) -> Int {
            if let date = UserDefaults.standard.value(forKey: forKey) as? Date {
                return Int(date.timeIntervalSince1970 * 1000)
            }
            return 0
        }
        return [
            "lastRequestDate": getTime(forKey: lastRequestDateKey),
            "viewAssignmentDate": getTime(forKey: viewAssignmentDateKey),
            "viewAssignmentCount": UserDefaults.standard.integer(forKey: viewAssignmentCountKey),
            "launchCount": UserDefaults.standard.integer(forKey: launchCountKey),
            "fakeRequest": UserDefaults.standard.integer(forKey: fakeRequestKey)
        ]
    }

    @objc
    public class func setState(_ key: String, withValue value: Int64) {
        switch (key) {
        case "lastRequestDate":
            UserDefaults.standard.set(Date(timeIntervalSince1970: Double(value) / 1000), forKey: lastRequestDateKey)
        case "viewAssignmentDate":
            UserDefaults.standard.set(Date(timeIntervalSince1970: Double(value) / 1000), forKey: viewAssignmentDateKey)
        case "viewAssignmentCount":
            UserDefaults.standard.set(value, forKey: viewAssignmentCountKey)
        case "launchCount":
            UserDefaults.standard.set(value, forKey: launchCountKey)
        case "fakeRequest":
            UserDefaults.standard.set(value, forKey: fakeRequestKey)
        default:
            break
        }
        UserDefaults.standard.synchronize()
    }
}
