//
//  QuestionDescriptionCell.swift
//  Quizzes
//
//  Created by Derrick Hathaway on 2/6/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import UIKit
import WhizzyWig

let QuestionDescriptionCellReuseID = "QuizDescriptionCell"

class QuestionDescriptionCell : WhizzyWigTableViewCell {
    init() {
        super.init(style: .Default, reuseIdentifier: QuestionDescriptionCellReuseID)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}