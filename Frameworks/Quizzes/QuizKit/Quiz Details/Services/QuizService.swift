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

import Result

typealias QuizSubmissionsResult = Result<Page<[Submission]>, NSError>
typealias QuizSubmissionResult = Result<Page<Submission>, NSError>
typealias QuizResult = Result<Page<Quiz>, NSError>


protocol QuizService {
    
    var session: Session { get }
    
    var baseURL: URL { get }
    
    var context: ContextID { get }
    var quizID: String { get }
    
    func getQuiz(_ completed: @escaping (QuizResult)->())
    
    func getSubmissions(_ completed: @escaping (QuizSubmissionsResult)->())
    
    func beginNewSubmission(_ completed: @escaping (QuizSubmissionResult)->())
    
    func completeSubmission(_ submission: Submission, completed: @escaping (QuizSubmissionResult)->())
    
    func serviceForSubmission(_ submission: Submission) -> QuizSubmissionService
    
    func serviceForTimedQuizSubmission(_ submission: Submission) -> TimedQuizSubmissionService
    
    func serviceForAuditLoggingSubmission(_ submission: Submission) -> SubmissionAuditLoggingService
}
