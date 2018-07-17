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

fileprivate var tagAssociationStartKey: UInt8 = 0
fileprivate var tagAssociationEndKey: UInt8 = 0

public protocol PageViewEventViewControllerLoggingProtocol: class {
    var timeOnViewControllerStart: Date? { get set }
    var timeOnViewControllerEnd: Date? { get set }
}

public extension PageViewEventViewControllerLoggingProtocol {
    
    public var timeOnViewControllerStart: Date? {
        get {
            return objc_getAssociatedObject(self, &tagAssociationStartKey) as? Date
        }
        set(newValue) {
            objc_setAssociatedObject(self, &tagAssociationStartKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    public var timeOnViewControllerEnd: Date? {
        get {
            return objc_getAssociatedObject(self, &tagAssociationEndKey) as? Date
        }
        set(newValue) {
            objc_setAssociatedObject(self, &tagAssociationEndKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    //  MARK: - Measure time spent on view controller
    public func startTrackingTimeOnViewController() {
        timeOnViewControllerStart = Date()
    }

    public func stopTrackingTimeOnViewController(eventName: String, attributes: [String: Any]? = nil) {
        timeOnViewControllerEnd = Date()
        guard let start = timeOnViewControllerStart, let end = timeOnViewControllerEnd else { return }
        let duration = end.timeIntervalSince(start)
        PageViewEventController.instance.logPageView(eventName, attributes: attributes, eventDurationInSeconds: duration)
    }
}

@objc public protocol PageViewEventLoggerLegacySupportProtocol: class {
    var pageViewEventLog:  PageViewEventLoggerLegacySupport { get }
    var pageViewEventName: String { get set }
}

@objc public class PageViewEventLoggerLegacySupport: NSObject, PageViewEventViewControllerLoggingProtocol {
    public func start() {
        startTrackingTimeOnViewController()
    }
    
    public func stop(eventName: String) {
        stopTrackingTimeOnViewController(eventName: eventName)
    }
}

@objc public protocol ModuleItemEmbeddedProtocol: class {
    var moduleItemID: String? { get set }
}
