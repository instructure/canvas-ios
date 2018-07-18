//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
    
    

import Foundation


import Result

class QuizController {
    let service: QuizService
    
    fileprivate (set) var quiz: Quiz?
    
    var quizUpdated: (QuizResult)->() = {_ in } {
        didSet {
            if let quiz = self.quiz {
                quizUpdated(Result(value: ResponsePage(content: quiz)))
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


