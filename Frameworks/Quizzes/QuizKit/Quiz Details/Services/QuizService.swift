//
//  QuizService.swift
//  Quizzes
//
//  Created by Derrick Hathaway on 2/2/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import Foundation

import TooLegit

import Result

typealias QuizSubmissionsResult = Result<Page<[Submission]>, NSError>
typealias QuizSubmissionResult = Result<Page<Submission>, NSError>
typealias QuizResult = Result<Page<Quiz>, NSError>


protocol QuizService {
    
    var session: Session { get }
    
    var baseURL: NSURL { get }
    
    var context: ContextID { get }
    var quizID: String { get }
    
    func getQuiz(completed: QuizResult->())
    
    func getSubmissions(completed: QuizSubmissionsResult->())
    
    func beginNewSubmission(completed: QuizSubmissionResult->())
    
    func completeSubmission(submission: Submission, completed: QuizSubmissionResult->())
    
    func serviceForSubmission(submission: Submission) -> QuizSubmissionService
    
    func serviceForTimedQuizSubmission(submission: Submission) -> TimedQuizSubmissionService
    
    func serviceForAuditLoggingSubmission(submission: Submission) -> SubmissionAuditLoggingService
}