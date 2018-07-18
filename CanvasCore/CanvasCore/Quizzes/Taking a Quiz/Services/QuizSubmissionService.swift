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

typealias SubmissionQuestionsResult = Result<ResponsePage<[SubmissionQuestion]>, NSError>
typealias SelectAnswerResult = Result<ResponsePage<Bool>, NSError>
typealias FlagQuestionResult = Result<ResponsePage<Bool>, NSError>

protocol QuizSubmissionService {
    
    var submission: QuizSubmission { get }
    
    func getQuestions(_ completed: @escaping (SubmissionQuestionsResult)->())
    
    func selectAnswer(_ answer: SubmissionAnswer, forQuestion: SubmissionQuestion, completed: @escaping (SelectAnswerResult)->())
    
    func markQuestionFlagged(_ question: SubmissionQuestion, flagged: Bool, completed: @escaping (FlagQuestionResult)->())
}
