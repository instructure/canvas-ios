//
// Copyright (C) 2017-present Instructure, Inc.
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
import StoreKit

public class AppStoreReview: NSObject {
    static let lastRequestDateKey = "InstLastReviewRequestKey"
    static let viewAssignmentDateKey = "InstViewAssignmentDateKey"
    static let viewAssignmentCountKey = "InstViewAssignmentCountKey"
    static let launchCountKey = "InstLaunchCount"
    static let fakeRequestKey = "InstFakeReviewRequestKey"

    class func immediatelyRequestReview () {
        if #available(iOS 10.3, *) {
            if UserDefaults.standard.bool(forKey: fakeRequestKey) {
                let appName = Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
                let alert = UIAlertController(title: "Enjoying \(appName)?", message: "This is a fake request to rate it on the App Store.", preferredStyle: .alert)
                func dismiss(action: UIAlertAction) {
                    alert.presentingViewController?.dismiss(animated: true, completion: nil)
                }
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: dismiss))
                alert.addAction(UIAlertAction(title: "Submit", style: .default, handler: dismiss))
                UIApplication.shared.delegate?.topViewController?.present(alert, animated: true, completion: nil)
            } else {
                #if RELEASE
                SKStoreReviewController.requestReview()
                #endif
            }
            UserDefaults.standard.set(Date(), forKey: lastRequestDateKey)
        }
    }

    class func shouldRequestReview () -> Bool {
        let date = UserDefaults.standard.value(forKey: lastRequestDateKey) as? Date ?? Date.distantPast
        let calendar = Calendar.current
        let comps = calendar.dateComponents([Calendar.Component.day], from: date, to: Date())
        if let daysSince = comps.day, daysSince <= 30 {
            return false
        }
        return true
    }

    public class func handleLaunch () {
        let count = UserDefaults.standard.integer(forKey: launchCountKey) + 1
        UserDefaults.standard.set(count, forKey: launchCountKey)
        if count >= 10 && shouldRequestReview() {
            immediatelyRequestReview()
        }
    }

    @objc
    public class func handleSuccessfulSubmit () {
        if shouldRequestReview() {
            immediatelyRequestReview()
        }
    }

    @objc
    public class func handleNavigateToAssignment () {
        // or discussion, or announcement
        let date = UserDefaults.standard.value(forKey: viewAssignmentDateKey) as? Date ?? Date.distantPast
        if date.addingTimeInterval(24 * 60 * 60).isTheSameDayAsDate(Date()) { // yesterday
            let count = UserDefaults.standard.integer(forKey: viewAssignmentCountKey)
            UserDefaults.standard.set(count + 1, forKey: viewAssignmentCountKey)
            UserDefaults.standard.set(Date(), forKey: viewAssignmentDateKey)
        } else if !date.isTheSameDayAsDate(Date()) { // not today
            UserDefaults.standard.set(1, forKey: viewAssignmentCountKey)
            UserDefaults.standard.set(Date(), forKey: viewAssignmentDateKey)
        } // else already updated today, do nothing
    }

    @objc
    public class func handleNavigateFromAssignment () {
        let count = UserDefaults.standard.integer(forKey: viewAssignmentCountKey)
        let date = UserDefaults.standard.value(forKey: viewAssignmentDateKey) as? Date ?? Date.distantPast
        if count >= 3 && date.isTheSameDayAsDate(Date()) && shouldRequestReview() {
            immediatelyRequestReview()
        }
    }

    @objc
    public class func getState () -> Dictionary<String, Int> {
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
            "fakeRequest": UserDefaults.standard.integer(forKey: fakeRequestKey),
        ]
    }

    @objc
    public class func setState (_ key: String, withValue value: Int64) {
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
    }
}
