//
//  AuditSubmissionLoggingService.swift
//  Quizzes
//
//  Created by Ben Kraus on 5/14/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import Foundation

import TooLegit
import Result

typealias SubmissionAuditLoggingResult = Result<Page<Bool>, NSError>


protocol SubmissionAuditLoggingService {
    
    func logSessionStarted(completed: SubmissionAuditLoggingResult->())
    
    // TODO: in the future, include other events, such as going into the background, changing answer, flagging a question, etc
}