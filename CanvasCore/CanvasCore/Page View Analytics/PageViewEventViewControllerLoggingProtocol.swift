//
// Copyright (C) 2018-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
