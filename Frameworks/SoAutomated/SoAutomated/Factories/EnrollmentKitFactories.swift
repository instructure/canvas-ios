//
//  EnrollmentKitFactories.swift
//  SoAutomated
//
//  Created by Nathan Armstrong on 8/3/16.
//  Copyright © 2016 instructure. All rights reserved.
//

@testable import EnrollmentKit
import CoreData

extension Course {
    public static func build(context: NSManagedObjectContext,
                      id: String = "1",
                      name: String = "One",
                      code: String = "one",
                      isFavorite: Bool = false,
                      color: UIColor? = nil,
                      currentGradingPeriodID: String? = nil) -> Course {
        let course = Course(inContext: context)
        course.id = id
        course.name = name
        course.code = code
        course.isFavorite = isFavorite
        course.color = color
        course.currentGradingPeriodID = currentGradingPeriodID
        return course
    }
}

extension Group {
    public static func build(context: NSManagedObjectContext,
                      id: String = "1",
                      name: String = "One",
                      code: String = "one",
                      isFavorite: Bool = false,
                      color: UIColor? = nil
        ) -> Group {
        let group = Group(inContext: context)
        group.id = id
        group.name = name
        group.isFavorite = isFavorite
        group.color = color
        return group
    }
}

extension Tab {
    public static func build(context: NSManagedObjectContext) -> Tab {
        let tab = Tab(inContext: context)
        return tab
    }
}

extension Grade {
    public static func build(context: NSManagedObjectContext,
                      gradingPeriodID: String? = nil,
                      currentGrade: String? = nil,
                      currentScore: NSNumber? = nil,
                      finalGrade: String? = nil,
                      finalScore: NSNumber? = nil,
                      @noescape course: (NSManagedObjectContext -> Course) = { Course.build($0) }) -> Grade {
        let grade = Grade(inContext: context)
        grade.gradingPeriodID = gradingPeriodID
        grade.currentGrade = currentGrade
        grade.currentScore = currentScore
        grade.finalGrade = finalGrade
        grade.finalScore = finalScore
        grade.course = course(context)
        return grade
    }
}

extension GradingPeriod {
    public static func build(context: NSManagedObjectContext,
                      id: String = "1",
                      title: String = "Period 1",
                      courseID: String = "1",
                      startDate: NSDate = NSDate()
    ) -> GradingPeriod {
        let gradingPeriod = GradingPeriod(inContext: context)
        gradingPeriod.id = id
        gradingPeriod.title = title
        gradingPeriod.courseID = courseID
        gradingPeriod.startDate = startDate
        return gradingPeriod
    }
}
