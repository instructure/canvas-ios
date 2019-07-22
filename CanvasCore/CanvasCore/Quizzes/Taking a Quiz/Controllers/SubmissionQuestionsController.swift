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

typealias SubmissionQuestionsUpdateResult = Result<[SubmissionQuestionsController.Update], NSError>

class SubmissionQuestionsController {
    
    enum Update {
        case added(questionIndex: Int) // questions should only ever be appended
        case answerChanged(questionIndex: Int)
        case flagChanged(questionIndex: Int)
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
    
    fileprivate (set) var flaggedCount: Int = 0

    // MARK: questions state
    fileprivate (set) var questions: [SubmissionQuestion] = []
    var questionUpdates: (SubmissionQuestionsUpdateResult)->() = {_ in} {
        didSet {
            if questions.count > 0 {
                // notify the new observer of the current questions
                let updates: [Update] = (0..<questions.count).map { index in
                    return .added(questionIndex: index)
                }
                questionUpdates(.success(updates))
            }
        }
    }
    
    // MARK: loading state
    fileprivate (set) var isLoading: Bool {
        didSet {
            loadingChanged(isLoading)
        }
    }
    var loadingChanged: (_ isLoading: Bool)->() = { _ in }
}


// MARK: - Pagination

extension SubmissionQuestionsController {
    fileprivate func handleResultPage(_ questionsResult: SubmissionQuestionsResult) {
        if let questionsPage = questionsResult.value {
            
            let currentCount = questions.count
            let questionIndices = currentCount..<(questionsPage.content.count + currentCount)
                
            let updates: [Update] = questionIndices.map { .added(questionIndex:$0) }
            flaggedCount = questionsPage.content.reduce(flaggedCount) { count, question in
                return question.flagged ? count + 1 : count
            }
            
            var newQuestions = questionsPage.content
            if quiz.shuffleAnswers {
                for (index, submissionQuestion) in newQuestions.enumerated() {
                    let newSubmissionQuestion = submissionQuestion.shuffleAnswers()
                    newQuestions[index] = newSubmissionQuestion
                }
            }
            
            questions.append(contentsOf: newQuestions)
            questions.sort(by: { $0.question.position < $1.question.position })
            questionUpdates(.success(updates))

            // exhaust pagination
            if questionsPage.hasMorePages {
                let _ = questionsPage.getNextPage { result in
                    self.handleResultPage(result)
                }
            } else {
                isLoading = false
            }
        } else if let error = questionsResult.error {
            questionUpdates(.failure(error))
            isLoading = false
        }
    }
}

// MARK: - SubmissionInteractor

extension SubmissionQuestionsController: SubmissionInteractor {
    
    var submission: QuizSubmission {
        return service.submission
    }
    
    func selectAnswer(_ answer: SubmissionAnswer, forQuestionAtIndex questionIndex: Int, completed: @escaping ()->()) {
        let oldQuestion = questions[questionIndex]
        
        if answer == oldQuestion.answer {
            return // no need to re-select
        }

        var realAnswer = answer

        switch answer {
        case .text(let text):
            if text == "" {
                realAnswer = .unanswered
            }
        default:
            break
        }

        let updatedQuestion = oldQuestion.selectAnswer(realAnswer)
        questions[questionIndex] = updatedQuestion
        questionUpdates(.success([.answerChanged(questionIndex: questionIndex)]))
        
        service.selectAnswer(answer, forQuestion: oldQuestion) { result in
            defer {
                completed()
            }
            
            if let err = result.error {
                // back out any changes we made
                self.questions[questionIndex] = oldQuestion
                self.questionUpdates(.success([.answerChanged(questionIndex: questionIndex)]))
                self.questionUpdates(.failure(err))
                
                return
            }
        }
    }
    
    func markQuestonFlagged(_ flagged: Bool, forQuestionAtIndex questionIndex: Int) {
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
        questionUpdates(.success([.flagChanged(questionIndex: questionIndex)]))
        
        service.markQuestionFlagged(oldQuestion, flagged: flagged) { result in
            if let err = result.error {
                // back out of any changes we made
                self.questions[questionIndex] = oldQuestion
                self.flaggedCount = oldFlaggedCount
                self.questionUpdates(.success([.flagChanged(questionIndex: questionIndex)]))
                self.questionUpdates(.failure(err))
                
                return
            }
        }
    }
}
