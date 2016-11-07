//
// Copyright (C) 2016-present Instructure, Inc.
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

@testable import ObserverAlertKit
import TooLegit
import SoAutomated
import SoPersistent
import CoreData

extension Alert {
    static func build(context: NSManagedObjectContext,
                      id: String = "1",
                      observerID: String = "observerID",
                      studentID: String = "studentID",
                      courseID: String = "courseID",
                      thresholdID: String = "thresholdID",
                      title: String = "title",
                      read: Bool = false,
                      dismissed: Bool = false,
                      actionDate: NSDate = NSDate(),
                      assetPath: String = "assetPath",
                      type: AlertThresholdType = .CourseAnnouncement
        ) -> Alert {
        let alert: Alert = Alert.create(inContext: context)
        alert.id = id
        alert.observerID = observerID
        alert.studentID = studentID
        alert.courseID = courseID
        alert.thresholdID = thresholdID
        alert.title = title
        alert.read = read
        alert.dismissed = dismissed
        alert.actionDate = actionDate
        alert.assetPath = assetPath
        alert.type = type
        return alert
    }
}

extension AlertThreshold {
    static func build(context: NSManagedObjectContext,
                      id: String = "1",
                      observerID: String = "observerID",
                      studentID: String = "studentID",
                      threshold: String = "threshold",
                      type: AlertThresholdType = .CourseAnnouncement
        ) -> AlertThreshold {
        let alertThreshold: AlertThreshold = AlertThreshold.create(inContext: context)
        alertThreshold.id = id
        alertThreshold.observerID = observerID
        alertThreshold.studentID = studentID
        alertThreshold.threshold = threshold
        alertThreshold.type = type
        return alertThreshold
    }
}
