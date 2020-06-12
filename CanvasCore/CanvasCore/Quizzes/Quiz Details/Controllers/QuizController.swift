//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import Foundation

class QuizController {
    let service: CanvasQuizService
    
    fileprivate (set) var quiz: Quiz?
    fileprivate (set) var submission: QuizSubmission?
    
    var quizUpdated: (QuizResult)->() = {_ in } {
        didSet {
            if let quiz = self.quiz {
                quizUpdated(.success(ResponsePage(content: quiz)))
            }
        }
    }
    
    init(service: CanvasQuizService, quiz: Quiz? = nil) {
        self.service = service
        self.quiz = quiz
    }
    
    func refreshQuiz(completionHandler: (() -> Void)? = nil) {
        service.getQuiz { [weak self] quizResult in
            if let quiz = quizResult.value?.content {
                self?.quiz = quiz
            }
            self?.service.getSubmission { submissionResult in
                self?.submission = submissionResult.value?.content
                self?.quizUpdated(quizResult)
                DispatchQueue.main.async {
                    completionHandler?()
                }
            }
        }
    }
    
    func urlForViewingResultsForAttempt(_ attempt: Int) -> URL? {
        var url: URL? = nil
        switch quiz!.hideResults {
        case .never:
            url = resultURLForAttempt(attempt)
        case .always:
            url = nil
        case .untilAfterLastAttempt:
            switch quiz!.attemptLimit {
            case .count(let attemptLimit):
                if attempt >= attemptLimit {
                    url = resultURLForAttempt(attempt)
                } else {
                    url = nil
                }
            case .unlimited:
                break
            }
        }
        return url
    }
    
    fileprivate func resultURLForAttempt(_ attempt: Int) -> URL? {
        // URLByAppendingPathComponent encoded the version query param wrong so...
        let url = URL(string: service.baseURL.absoluteString + "/" + service.context.htmlPath + "/quizzes/\(service.quizID)/history?attempt=\(attempt)")
        return url
    }
}


