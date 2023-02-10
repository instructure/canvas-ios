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

import Foundation

private var tagAssociationStartKey: UInt8 = 0
private var tagAssociationEndKey: UInt8 = 0

public protocol PageViewEventViewControllerLoggingProtocol: AnyObject {
//    var timeOnViewControllerStart: Date? { get set }
//    var timeOnViewControllerEnd: Date? { get set }
    func startTrackingTimeOnViewController()
    func stopTrackingTimeOnViewController()
}

public extension PageViewEventViewControllerLoggingProtocol {

//    var timeOnViewControllerStart: Date? {
//        get {
//            return objc_getAssociatedObject(self, &tagAssociationStartKey) as? Date
//        }
//        set(newValue) {
//            objc_setAssociatedObject(self, &tagAssociationStartKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
//        }
//    }
//
//    var timeOnViewControllerEnd: Date? {
//        get {
//            return objc_getAssociatedObject(self, &tagAssociationEndKey) as? Date
//        }
//        set(newValue) {
//            objc_setAssociatedObject(self, &tagAssociationEndKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
//        }
//    }
//
//    // MARK: - Measure time spent on view controller
//    func startTrackingTimeOnViewController() {
//        timeOnViewControllerStart = Clock.now
//        print("💚", timeOnViewControllerStart)
//    }
//
//    func stopTrackingTimeOnViewController(eventName: String, attributes: [String: String] = [:]) {
//        timeOnViewControllerEnd = Clock.now
//        guard let start = timeOnViewControllerStart, let end = timeOnViewControllerEnd else { return }
//        let duration = end.timeIntervalSince(start)
//        print("💙 ", duration)
//
//        PageViewEventController.instance.logPageView(eventName, attributes: attributes, eventDurationInSeconds: duration)
//    }
}
