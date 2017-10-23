//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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


