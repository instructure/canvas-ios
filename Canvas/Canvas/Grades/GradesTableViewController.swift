//
//  GradesTableViewController.swift
//  iCanvas
//
//  Created by Nathan Armstrong on 5/3/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import SoPersistent
import AssignmentKit
import TooLegit
import SoLazy
import EnrollmentKit
import SoPretty
import ReactiveCocoa
import Result

extension Assignment {
    func gradeColorfulViewModel(dataSource: ContextDataSource) -> ColorfulViewModel {
        let model = ColorfulViewModel(style: .RightDetail)
        model.title.value = name
        model.detail.value = grade
        model.color <~ dataSource.producer(ContextID(id: courseID, context: .Course)).map { $0?.color ?? .prettyGray() }
        model.icon.value = icon
        return model
    }
}
