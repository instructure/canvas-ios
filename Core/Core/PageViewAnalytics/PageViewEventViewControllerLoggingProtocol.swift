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

// swiftlint:disable:next private_over_fileprivate
fileprivate var tagAssociationStartKey: UInt8 = 0
// swiftlint:disable:next private_over_fileprivate
fileprivate var tagAssociationEndKey: UInt8 = 0

public protocol PageViewEventViewControllerLoggingProtocol: class {
    var timeOnViewControllerStart: Date? { get set }
    var timeOnViewControllerEnd: Date? { get set }
    func startTrackingTimeOnViewController()
    func stopTrackingTimeOnViewController(eventName: String, attributes: [String: String])
}

public extension PageViewEventViewControllerLoggingProtocol {

    var timeOnViewControllerStart: Date? {
        get {
            return objc_getAssociatedObject(self, &tagAssociationStartKey) as? Date
        }
        set(newValue) {
            objc_setAssociatedObject(self, &tagAssociationStartKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }

    var timeOnViewControllerEnd: Date? {
        get {
            return objc_getAssociatedObject(self, &tagAssociationEndKey) as? Date
        }
        set(newValue) {
            objc_setAssociatedObject(self, &tagAssociationEndKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }

    // MARK: - Measure time spent on view controller
    func startTrackingTimeOnViewController() {
        timeOnViewControllerStart = Date()
    }

    func stopTrackingTimeOnViewController(eventName: String, attributes: [String: String] = [:]) {
        timeOnViewControllerEnd = Date()
        guard let start = timeOnViewControllerStart, let end = timeOnViewControllerEnd else { return }
        let duration = end.timeIntervalSince(start)
        PageViewEventController.instance.logPageView(eventName, attributes: attributes, eventDurationInSeconds: duration)
    }
}
