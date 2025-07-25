//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

import Combine
import Foundation
@testable import Core
@testable import Teacher

final class SubmissionCommentsInteractorMock: SubmissionCommentsInteractor {

    // MARK: - getSubmissionAttempts

    var getSubmissionAttemptsCallsCount: Int = 0
    var getSubmissionAttemptsResult: AnyPublisher<[Submission], Error>?
    func getSubmissionAttempts() -> AnyPublisher<[Submission], Error> {
        getSubmissionAttemptsCallsCount += 1
        return getSubmissionAttemptsResult ?? Publishers.typedJust([])
    }

    // MARK: - getComments

    var getCommentsCallsCount: Int = 0
    var getCommentsResult: AnyPublisher<[SubmissionComment], Error>?
    func getComments() -> AnyPublisher<[SubmissionComment], Error> {
        getCommentsCallsCount += 1
        return getCommentsResult ?? Publishers.typedJust([])
    }

    // MARK: - getIsAssignmentEnhancementsEnabled

    var getIsAssignmentEnhancementsEnabledCallsCount: Int = 0
    var getIsAssignmentEnhancementsEnabledResult: AnyPublisher<Bool, Error>?
    func getIsAssignmentEnhancementsEnabled() -> AnyPublisher<Bool, Error> {
        getIsAssignmentEnhancementsEnabledCallsCount += 1
        return getIsAssignmentEnhancementsEnabledResult ?? Publishers.typedJust(false)
    }

    // MARK: - getIsCommentLibraryEnabled

    var getIsCommentLibraryEnabledCallsCount: Int = 0
    var getIsCommentLibraryEnabledResult: AnyPublisher<Bool, Error>?
    func getIsCommentLibraryEnabled() -> AnyPublisher<Bool, Error> {
        getIsCommentLibraryEnabledCallsCount += 1
        return getIsCommentLibraryEnabledResult ?? Publishers.typedJust(false)
    }

    // MARK: - createTextComment

    var createTextCommentCallsCount: Int = 0
    var createTextCommentInput: (text: String, attemptNumber: Int?, completion: (Result<Void, Error>) -> Void)?
    func createTextComment(_ text: String, attemptNumber: Int?, completion: @escaping (Result<Void, Error>) -> Void) {
        createTextCommentCallsCount += 1
        createTextCommentInput = (text: text, attemptNumber: attemptNumber, completion: completion)
    }

    // MARK: - createMediaComment

    var createMediaCommentCallsCount: Int = 0
    var createMediaCommentInput: (type: MediaCommentType, url: URL, attemptNumber: Int?, completion: (Result<Void, Error>) -> Void)?
    func createMediaComment(type: MediaCommentType, url: URL, attemptNumber: Int?, completion: @escaping (Result<Void, Error>) -> Void) {
        createMediaCommentCallsCount += 1
        createMediaCommentInput = (type: type, url: url, attemptNumber: attemptNumber, completion: completion)
    }

    // MARK: - createFileComment

    var createFileCommentCallsCount: Int = 0
    var createFileCommentInput: (batchId: String, attemptNumber: Int?, completion: (Result<Void, Error>) -> Void)?
    func createFileComment(batchId: String, attemptNumber: Int?, completion: @escaping (Result<Void, Error>) -> Void) {
        createFileCommentCallsCount += 1
        createFileCommentInput = (batchId: batchId, attemptNumber: attemptNumber, completion: completion)
    }
}
