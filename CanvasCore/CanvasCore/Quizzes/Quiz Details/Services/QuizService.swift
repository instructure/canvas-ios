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

typealias QuizSubmissionsResult = Result<ResponsePage<[QuizSubmission]>, NSError>
typealias QuizSubmissionResult = Result<ResponsePage<QuizSubmission>, NSError>
typealias QuizSubmissionFileResult = Result<File, NSError>
typealias QuizResult = Result<ResponsePage<Quiz>, NSError>


protocol QuizService {
    
    var session: Session { get }
    
    var baseURL: URL { get }
    
    var context: ContextID { get }
    var quizID: String { get }
    
    func getQuiz(_ completed: @escaping (QuizResult)->())
    
    func getSubmissions(_ completed: @escaping (QuizSubmissionsResult)->())
    
    func beginNewSubmission(_ completed: @escaping (QuizSubmissionResult)->())
    
    func completeSubmission(_ submission: QuizSubmission, completed: @escaping (QuizSubmissionResult)->())

    func uploadSubmissionFile(_ uploadable: Uploadable, completed: @escaping (QuizSubmissionFileResult)->())

    func cancelUploadSubmissionFile()

    func findFile(withID id: String) -> File?
    
    func serviceForSubmission(_ submission: QuizSubmission) -> QuizSubmissionService
    
    func serviceForTimedQuizSubmission(_ submission: QuizSubmission) -> TimedQuizSubmissionService
    
    func serviceForAuditLoggingSubmission(_ submission: QuizSubmission) -> SubmissionAuditLoggingService
}

extension QuizService {
    func pageViewName() -> String {
        let event: NSString = baseURL.absoluteString as NSString
        return event.appendingPathComponent(context.apiPath.pruneApiVersionFromPath() + "/quizzes/" + quizID)
    }
}
