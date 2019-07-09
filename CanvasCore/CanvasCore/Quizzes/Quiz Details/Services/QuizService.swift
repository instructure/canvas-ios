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

    func getSubmission(_ completed: @escaping (QuizSubmissionResult)->())
    
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
