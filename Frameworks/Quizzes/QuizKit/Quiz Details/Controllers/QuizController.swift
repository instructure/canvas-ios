//
//  QuizController.swift
//  Quizzes
//
//  Created by Derrick Hathaway on 1/28/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import Foundation

import TooLegit
import Result

class QuizController {
    let service: QuizService
    
    private (set) var quiz: Quiz?
    
    var quizUpdated: QuizResult->() = {_ in } {
        didSet {
            if let quiz = self.quiz {
                quizUpdated(Result(value: Page(content: quiz)))
            }
        }
    }
    
    init(service: QuizService, quiz: Quiz? = nil) {
        self.service = service
        self.quiz = quiz
    }
    
    func refreshQuiz() {
        service.getQuiz { quizResult in
            if let quiz = quizResult.value?.content {
                self.quiz = quiz
            }
            self.quizUpdated(quizResult)
        }
    }
    
    func urlForViewingResultsForAttempt(attempt: Int) -> NSURL? {
        var url: NSURL? = nil
        switch quiz!.hideResults {
        case .Never:
            url = resultURLForAttempt(attempt)
        case .Always:
            url = nil
        case .UntilAfterLastAttempt:
            switch quiz!.attemptLimit {
            case .Count(let attemptLimit):
                if attempt >= attemptLimit {
                    url = resultURLForAttempt(attempt)
                } else {
                    url = nil
                }
            case .Unlimited:
                break
            }
        }
        return url
    }
    
    private func resultURLForAttempt(attempt: Int) -> NSURL? {
        // URLByAppendingPathComponent encoded the version query param wrong so...
        let url = NSURL(string: service.baseURL.absoluteString! + "/" + service.context.htmlPath + "/quizzes/\(service.quizID)/history?attempt=\(attempt)")
        return url
    }
}


