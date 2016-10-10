//
//  Factories.swift
//  ObserverAlertKit
//
//  Created by Brandon Pluim on 5/26/16.
//  Copyright © 2016 Instructure. All rights reserved.
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
