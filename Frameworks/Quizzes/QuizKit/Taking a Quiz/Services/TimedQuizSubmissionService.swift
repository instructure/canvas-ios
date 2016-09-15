//
//  TimedQuizSubmissionService.swift
//  Quizzes
//
//  Created by Ben Kraus on 4/1/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import Foundation

import TooLegit
import Result

typealias TimeRemainingResult = Result<Int, NSError>

protocol TimedQuizSubmissionService {
    
    var context: ContextID { get }
    var quizID: String { get }
    
    func getTimeRemaining(completed: TimeRemainingResult->())
}