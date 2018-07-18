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

class SubmissionController {
    
    let quiz: Quiz
    let service: QuizService
    
    fileprivate (set) var submission: QuizSubmission?
    fileprivate var submissionService: QuizSubmissionService?
    fileprivate var auditLoggingService: SubmissionAuditLoggingService?
    
    var submissionDidChange: (QuizSubmissionResult)->() = {_ in } {
        didSet {
            if let submission = self.submission {
                submissionDidChange(Result(value: ResponsePage(content: submission)))
            }
        }
    }
    var almostDue: ()->() = { }
    var lockQuiz: ()->() = {}
    
    init(service: QuizService, submission: QuizSubmission? = nil, quiz: Quiz) {
        self.service = service
        self.submission = submission
        self.quiz = quiz
        if let sub = submission {
            submissionService = service.serviceForSubmission(sub)
            auditLoggingService = service.serviceForAuditLoggingSubmission(sub)
        }
    }
    
    func beginTakingQuiz() {
        if self.submission != nil {
            auditLoggingService?.logSessionStarted({ _ in })
        } else {
            service.beginNewSubmission { [weak self] submissionResult in
                if let submission = submissionResult.value?.content {
                    self?.submission = submission
                    self?.submissionService = self?.service.serviceForSubmission(submission)
                    self?.auditLoggingService = self?.service.serviceForAuditLoggingSubmission(submission)
                    
                    self?.auditLoggingService?.logSessionStarted({ _ in })
                    
                    // help them out so they aren't slackers and submit things late
                    switch self!.quiz.due {
                    case .date(let dueDate):
                        let warnDate = (dueDate as Date) - 1.minutesComponents // 1 minute to give them ample time to read the warning and make a decision
                        let triggerTime = warnDate.timeIntervalSinceNow
                        if triggerTime > 0 {
                            delay(triggerTime) { [weak self] in
                                if self?.submission?.dateFinished == nil { // if it's now 1 minute prior to the due date and they haven't submitted yet
                                    self?.almostDue()
                                }
                            }
                        }
                        
                    case .noDueDate:
                        break
                    }

                    // the server automatically completes quiz submissions when the lock date is reached
                    // let's just tell the user their time is almost up
                    if let lockDate = self?.quiz.lockAt {
                        let warnDate = (lockDate as Date) - 1.minutesComponents // 1 minute to give them ample time to read the warning and make a decision
                        if warnDate >= Date() { // moderated quizzes may have already passed the lock date, in which case no warning is needed
                            delay(warnDate.timeIntervalSinceNow) { [weak self] in
                                if self?.submission?.dateFinished == nil { // if it's now 1 minute prior to the due date and they haven't submitted yet
                                    self?.almostDue()
                                }
                            }
                        }
                    }
                }
                
                self?.submissionDidChange(submissionResult)
            }
        }
        
        // For folks who are running under an MDM or a configurator and want to lock the device down...
        // This is a fire and forget cuz well, some folks care, others don't
        UIAccessibilityRequestGuidedAccessSession(true) { _ in }
    }

    func submit(_ completed: @escaping (QuizSubmissionResult)->()) {
        if let sub = submission {
            // For folks who are running under an MDM or a configurator and want to unlock the device now...
            // This is a fire and forget cuz well, some folks care, others don't
            UIAccessibilityRequestGuidedAccessSession(false) { _ in }
            service.completeSubmission(sub, completed: completed)
        } else {
            completed(Result(error: NSError.quizErrorWithMessage("You don't appear to be taking a quiz.")))
        }
    }
    
    var controllerForSubmissionQuestions: SubmissionQuestionsController? {
        if let subService = submissionService {
            return SubmissionQuestionsController(service: subService, quiz: quiz)
        }
        
        return nil
    }
}
