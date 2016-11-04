
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
import SoLazy
import Result

class QuizTakeabilityController {
    
    let quiz: Quiz
    let service: QuizService
    
    private (set) var attempts: Int = 0 // NOTE: right now this is broken due to an api bug that is being worked on, so don't rely on this
    
    /// This is the list of question types that is supported natively. 
    /// This will change as we add support for more question types.
    private var nativelySupportedQuestionTypes: [Question.Kind] {
        return [ .TrueFalse, .MultipleChoice, .MultipleAnswers, .Matching, .Essay, .ShortAnswer, .TextOnly, .Numerical ]
    }
    
    init(quiz: Quiz, service: QuizService) {
        self.quiz = quiz
        self.service = service
        
        refreshTakeability()
    }
    
    var takeabilityUpdated: QuizTakeabilityController->() = {_ in } {
        didSet {
            takeabilityUpdated(self)
        }
    }
    
    private (set) var takeability: Takeability = .NotTakeable(reason: .Undecided) {
        didSet {
            takeabilityUpdated(self)
        }
    }
    
    private func updateTakeability(submissions: [Submission]) {
        if quiz.lockAt != nil && NSDate() >= quiz.lockAt! {
            takeability = .NotTakeable(reason: .Locked)
            return
        }
        // TODO: passcode
        
        attempts = submissions.count
        if submissions.count == 0 && !quiz.lockedForUser {
            takeability = .Take
            return
        } else {
            let sortedSubmissions = submissions.sort({ $0.attempt < $1.attempt })
            if let lastSubmission = sortedSubmissions.last {
                switch quiz.attemptLimit {
                case .Count(let limit):
                    if lastSubmission.attempt >= limit && lastSubmission.workflowState != .Untaken && lastSubmission.attemptsLeft == 0 {
                        // You had your chance, and you probably ended up screwing up anyways :P 
                        takeability = .NotTakeable(reason: .AttemptLimitReached)
                        return
                    }
                default:
                    break
                }
                
                if lastSubmission.workflowState == .Untaken && !quiz.lockedForUser {
                    let now = NSDate()
                    if (lastSubmission.endAt != nil && now < lastSubmission.endAt! && lastSubmission.dateFinished == nil) || lastSubmission.endAt == nil  {
                        takeability = .Resume
                        unfinishedSubmission = lastSubmission
                        return
                    } else if lastSubmission.endAt != nil && now > lastSubmission.endAt! {
                        // This is the horrible hack where because the API never updated the workflow state, we have to manually complete the quiz before
                        // we can start another one
                        takeability = .NotTakeable(reason: .Undecided)
                        service.completeSubmission(lastSubmission) { [weak self] result in
                            if result.error != nil {
                                self?.takeability = .Retake
                            }
                        }
                        return
                    }
                }
            }
            
            if quiz.lockedForUser {
                takeability = .NotTakeable(reason: .Other(quiz.lockExplanation ?? "This quiz is locked."))
            } else {
                takeability = .Retake
            }
        }
    }
    
    func refreshTakeability() {
        service.getSubmissions() { result in
            switch result {
            case .Success(let submissionPage):
                self.updateTakeability(submissionPage.content)
            case .Failure(let error):
                print("error getting the submissions \(error)")
            }
        }
    }
    
    func takeableNatively() -> Bool {
        return takeability.takeable && quizQuestionsSupportedNatively(quiz) && !quiz.oneQuestionAtATime && !quiz.hasAccessCode && (quiz.ipFilter == nil)
    }
    
    func takeableInWebView() -> Bool {
        return takeability.takeable && !takeableNatively()
    }
    
    private func quizQuestionsSupportedNatively(quiz: Quiz) -> Bool {
        if quiz.questionTypes.count == 0 {
            return false
        }
        
        for questionType in quiz.questionTypes {
            if !nativelySupportedQuestionTypes.contains(questionType) {
                return false
            }
        }
        
        return true
    }
    
    
    
    // MARK: taking a quiz
    private var unfinishedSubmission: Submission? = nil

    func submissionControllerForTakingQuiz(quiz: Quiz) -> SubmissionController {
        return SubmissionController(service: service, submission: unfinishedSubmission, quiz: quiz)
    }
}