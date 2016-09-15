//
//  GradingPeriod+Factory.swift
//  Assignments
//
//  Created by Nathan Armstrong on 5/24/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import CoreData
@testable import EnrollmentKit

extension GradingPeriod {
    static func build(context: NSManagedObjectContext,
                      id: String = "1",
                      title: String = "Period 1",
                      courseID: String = "1",
                      startDate: NSDate = NSDate()
    ) -> GradingPeriod {
        let gradingPeriod = GradingPeriod.create(inContext: context)
        gradingPeriod.id = id
        gradingPeriod.title = title
        gradingPeriod.courseID = courseID
        gradingPeriod.startDate = startDate
        return gradingPeriod
    }
}
