//
//  SelectableAnswerCellProtocol.swift
//  Quizzes
//
//  Created by Ben Kraus on 3/2/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import UIKit

@objc protocol SelectableAnswerCell {
    func configureForState(selected selected: Bool)
}
