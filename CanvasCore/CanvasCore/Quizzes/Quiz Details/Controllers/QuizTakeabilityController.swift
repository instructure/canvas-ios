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

class QuizTakeabilityController {
    
    let quiz: Quiz
    let service: CanvasQuizService
    lazy var quizController: QuizController = {
        return QuizController(service: self.service, quiz: self.quiz)
    }()
    
    fileprivate (set) var attempts: Int = 0 // NOTE: right now this is broken due to an api bug that is being worked on, so don't rely on this
    
    init(quiz: Quiz, service: CanvasQuizService) {
        self.quiz = quiz
        self.service = service
        
        refreshTakeability()
    }
    
    var takeabilityUpdated: (QuizTakeabilityController)->() = {_ in } {
        didSet {
            takeabilityUpdated(self)
        }
    }
    
    fileprivate (set) var takeability: Takeability = .notTakeable(reason: .undecided) {
        didSet {
            takeabilityUpdated(self)
        }
    }
    
    fileprivate func updateTakeability(_ submissions: [QuizSubmission]) {
        let sortedSubmissions = submissions.sorted(by: { $0.attempt < $1.attempt })
        if quiz.lockedForUser {
            if let url = sortedSubmissions.last.flatMap({ self.quizController.urlForViewingResultsForAttempt($0.attempt) }) {
                takeability = .viewResults(url)
                return
            }
            takeability = .notTakeable(reason: .locked)
            return
        }
        // TODO: passcode
        
        attempts = submissions.count
        if submissions.count == 0 && !quiz.lockedForUser {
            takeability = .take
            return
        } else {
            let sortedSubmissions = submissions.sorted(by: { $0.attempt < $1.attempt })
            if let lastSubmission = sortedSubmissions.last {
                switch quiz.attemptLimit {
                case .count(let limit):
                    if lastSubmission.attempt >= limit && lastSubmission.workflowState != .Untaken && lastSubmission.attemptsLeft == 0 {
                        if let url = quizController.urlForViewingResultsForAttempt(lastSubmission.attempt) {
                            takeability = .viewResults(url)
                            return
                        }
                        takeability = .notTakeable(reason: .attemptLimitReached)
                        return
                    }
                default:
                    break
                }
                
                if lastSubmission.workflowState == .Untaken && !quiz.lockedForUser {
                    if case .minutes(_) = quiz.timeLimit {
                        let timedQuizSubmissionService = self.service.serviceForTimedQuizSubmission(lastSubmission)
                        timedQuizSubmissionService.getTimeRemaining { [weak self] result in
                            if let secondsLeft = result.value {
                                if (secondsLeft > 0 && lastSubmission.dateFinished == nil) {
                                    self?.takeability = .resume
                                    self?.unfinishedSubmission = lastSubmission
                                    return
                                } else {
                                    // This is the horrible hack where because the API never updated the workflow state, we have to manually complete the quiz before
                                    // we can start another one
                                    self?.takeability = .notTakeable(reason: .undecided)
                                    self?.service.completeSubmission(lastSubmission) { [weak self] result in
                                        if result.error != nil {
                                            self?.takeability = .retake
                                        }
                                    }
                                    return
                                }
                            }
                        }
                    } else if (lastSubmission.endAt.flatMap { $0 > Date() } ?? true)  {
                        takeability = .resume
                        unfinishedSubmission = lastSubmission
                        return
                    }
                }
            }
            
            if quiz.lockedForUser {
                takeability = .notTakeable(reason: .locked)
            } else {
                takeability = .retake
            }
        }
    }
    
    func refreshTakeability() {
        service.getSubmissions() { [weak self] result in
            switch result {
            case .success(let submissionPage):
                self?.updateTakeability(submissionPage.content)
            case .failure(let error):
                print("error getting the submissions \(error)")
                if error.domain == NSURLErrorDomain && error.code == NSURLErrorNotConnectedToInternet {
                    self?.takeability = .notTakeable(reason: .offline)
                }
            }
        }
    }
    
    func takeableInWebView() -> Bool {
        return takeability.takeable
    }
    
    // MARK: taking a quiz
    fileprivate var unfinishedSubmission: QuizSubmission? = nil
}
