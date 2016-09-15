//
//  QuizSubmissionService.swift
//  Quizzes
//
//  Created by Derrick Hathaway on 2/17/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import Foundation

import TooLegit
import Result

typealias SubmissionQuestionsResult = Result<Page<[SubmissionQuestion]>, NSError>
typealias SelectAnswerResult = Result<Page<Bool>, NSError>
typealias FlagQuestionResult = Result<Page<Bool>, NSError>

protocol QuizSubmissionService {
    
    var submission: Submission { get }
    
    func getQuestions(completed: SubmissionQuestionsResult->())
    
    func selectAnswer(answer: SubmissionAnswer, forQuestion: SubmissionQuestion, completed: SelectAnswerResult->())
    
    func markQuestionFlagged(question: SubmissionQuestion, flagged: Bool, completed: FlagQuestionResult->())
}