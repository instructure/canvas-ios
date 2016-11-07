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

import TooLegit
import SoLazy
import Result

typealias SubmissionQuestionsUpdateResult = Result<[SubmissionQuestionsController.Update], NSError>

class SubmissionQuestionsController {
    
    enum Update {
        case Added(questionIndex: Int) // questions should only ever be appended
        case AnswerChanged(questionIndex: Int)
        case FlagChanged(questionIndex: Int)
    }
    
    let service: QuizSubmissionService
    let quiz: Quiz
    
    init(service: QuizSubmissionService, quiz: Quiz) {
        self.service = service
        self.quiz = quiz
        
        isLoading = true
        service.getQuestions { result in
            self.handleResultPage(result)
        }
    }
    
    private (set) var flaggedCount: Int = 0

    // MARK: questions state
    private (set) var questions: [SubmissionQuestion] = []
    var questionUpdates: SubmissionQuestionsUpdateResult->() = {_ in} {
        didSet {
            if questions.count > 0 {
                // notify the new observer of the current questions
                let updates: [Update] = (0..<questions.count).map { index in
                    return .Added(questionIndex: index)
                }
                questionUpdates(Result(value: updates))
            }
        }
    }
    
    // MARK: loading state
    private (set) var isLoading: Bool {
        didSet {
            loadingChanged(isLoading: isLoading)
        }
    }
    var loadingChanged: (isLoading: Bool)->() = { _ in }
}


// MARK: - Pagination

extension SubmissionQuestionsController {
    private func handleResultPage(questionsResult: SubmissionQuestionsResult) {
        if let questionsPage = questionsResult.value {
            
            let currentCount = questions.count
            let questionIndices = currentCount..<(questionsPage.content.count + currentCount)
                
            let updates: [Update] = questionIndices.map { .Added(questionIndex:$0) }
            flaggedCount = questionsPage.content.reduce(flaggedCount) { count, question in
                return question.flagged ? count + 1 : count
            }
            
            var newQuestions = questionsPage.content
            if quiz.shuffleAnswers {
                for (index, submissionQuestion) in newQuestions.enumerate() {
                    let newSubmissionQuestion = submissionQuestion.shuffleAnswers()
                    newQuestions[index] = newSubmissionQuestion
                }
            }
            
            questions.appendContentsOf(newQuestions)
            questionUpdates(Result(value: updates))

            // exhaust pagination
            if questionsPage.hasMorePages {
                questionsPage.getNextPage { result in
                    self.handleResultPage(result)
                }
            } else {
                isLoading = false
            }
        } else if let error = questionsResult.error {
            questionUpdates(Result(error: error))
            isLoading = false
        }
    }
}

// MARK: - SubmissionInteractor

extension SubmissionQuestionsController: SubmissionInteractor {
    
    var submission: Submission {
        return service.submission
    }
    
    func selectAnswer(answer: SubmissionAnswer, forQuestionAtIndex questionIndex: Int, completed: ()->()) {
        let oldQuestion = questions[questionIndex]
        
        if answer == oldQuestion.answer {
            return // no need to re-select
        }

        var realAnswer = answer

        switch answer {
        case .Text(let text):
            if text == "" {
                realAnswer = .Unanswered
            }
        default:
            break
        }

        let updatedQuestion = oldQuestion.selectAnswer(realAnswer)
        questions[questionIndex] = updatedQuestion
        questionUpdates(Result(value: [.AnswerChanged(questionIndex: questionIndex)]))
        
        service.selectAnswer(answer, forQuestion: oldQuestion) { result in
            defer {
                completed()
            }
            
            if let err = result.error {
                // back out any changes we made
                self.questions[questionIndex] = oldQuestion
                self.questionUpdates(Result(value: [.AnswerChanged(questionIndex: questionIndex)]))
                self.questionUpdates(Result(error: err))
                
                return
            }
        }
    }
    
    func markQuestonFlagged(flagged: Bool, forQuestionAtIndex questionIndex: Int) {
        let oldQuestion = questions[questionIndex]
        let oldFlaggedCount = flaggedCount
        
        if flagged == oldQuestion.flagged {
            return // no need to do anything
        }
        
        let updatedQuestion = oldQuestion.toggleFlag()
        questions[questionIndex] = updatedQuestion
        if flagged {
            flaggedCount += 1
        } else {
            flaggedCount -= 1
        }
        questionUpdates(Result(value: [.FlagChanged(questionIndex: questionIndex)]))
        
        service.markQuestionFlagged(oldQuestion, flagged: flagged) { result in
            if let err = result.error {
                // back out of any changes we made
                self.questions[questionIndex] = oldQuestion
                self.flaggedCount = oldFlaggedCount
                self.questionUpdates(Result(value: [.FlagChanged(questionIndex: questionIndex)]))
                self.questionUpdates(Result(error: err))
                
                return
            }
        }
    }
}
