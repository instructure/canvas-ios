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

import Foundation
import Combine
import Core
import CoreData

protocol GradeStatusInteractor {
    var gradeStatuses: [GradeStatus] { get }

    func fetchGradeStatuses() -> AnyPublisher<Void, Error>

    func updateSubmissionGradeStatus(
        submissionId: String,
        userId: String,
        customGradeStatusId: String?,
        latePolicyStatus: String?
    ) -> AnyPublisher<Void, Error>

    func gradeStatusFor(
        customGradeStatusId: String?,
        latePolicyStatus: LatePolicyStatus?,
        isExcused: Bool?,
        isLate: Bool?
    ) -> GradeStatus?

    func observeGradeStatusChanges(
        submissionId: String,
        attempt: Int
    ) -> AnyPublisher<(GradeStatus, daysLate: Int, dueDate: Date?), Never>

    func updateLateDays(
        submissionId: String,
        userId: String,
        daysLate: Int
    ) -> AnyPublisher<Void, Error>
}

class GradeStatusInteractorLive: GradeStatusInteractor {
    private(set) var gradeStatuses: [GradeStatus] = []

    private let api: API
    private let courseId: String
    private let assignmentId: String

    init(courseId: String, assignmentId: String, api: API) {
        self.courseId = courseId
        self.assignmentId = assignmentId
        self.api = api
    }

    func fetchGradeStatuses() -> AnyPublisher<Void, Error> {
        let request = GetGradeStatusesRequest(courseID: courseId)
        return api.makeRequest(request)
            .map { $0.body }
            .map { [weak self] response in
                let defaults = response.defaultGradeStatuses.map { GradeStatus(defaultName: $0) }
                let custom = response.customGradeStatuses.map { GradeStatus(custom: $0) }
                self?.gradeStatuses = defaults + custom
            }
            .eraseToAnyPublisher()
    }

    func updateSubmissionGradeStatus(
        submissionId: String,
        userId: String,
        customGradeStatusId: String?,
        latePolicyStatus: String?
    ) -> AnyPublisher<Void, Error> {
        let useCase = UpdateSubmissionGradeStatus(
            courseId: courseId,
            submissionId: submissionId,
            assignmentId: assignmentId,
            userId: userId,
            customGradeStatusId: customGradeStatusId,
            latePolicyStatus: latePolicyStatus
        )
        let store = ReactiveStore(useCase: useCase)
        return store.getEntities(ignoreCache: true)
            .mapToVoid()
            .eraseToAnyPublisher()
    }

    func gradeStatusFor(
        customGradeStatusId: String?,
        latePolicyStatus: LatePolicyStatus?,
        isExcused: Bool?,
        isLate: Bool?
    ) -> GradeStatus? {
        if let customGradeStatusId {
            return gradeStatuses.first { $0.isCustom && $0.id == customGradeStatusId }
        } else if let lateStatus = latePolicyStatus?.rawValue {
            return gradeStatuses.first { !$0.isCustom && $0.id == lateStatus }
        } else if isExcused == true {
            return gradeStatuses.first { !$0.isCustom && $0.id == "excused" }
        } else if isLate == true {
            return gradeStatuses.first { !$0.isCustom && $0.id == LatePolicyStatus.late.rawValue }
        }
        return nil
    }

    func observeGradeStatusChanges(
        submissionId: String,
        attempt: Int
    ) -> AnyPublisher<(GradeStatus, daysLate: Int, dueDate: Date?), Never> {
        let predicate = NSPredicate.id(submissionId).and(NSPredicate(key: "attempt", equals: attempt))
        let useCase = LocalUseCase<Submission>(scope: Scope(predicate: predicate, order: []))
        let store = ReactiveStore(useCase: useCase)
        return store.getEntities(keepObservingDatabaseChanges: true)
            .map { $0.first }
            .compactMap { [weak self] submission in
                guard
                    let self,
                    let submission,
                    let status = self.gradeStatusFor(
                        customGradeStatusId: submission.customGradeStatusId,
                        latePolicyStatus: submission.latePolicyStatus,
                        isExcused: submission.excused,
                        isLate: submission.late
                    )
                else {
                    return nil
                }
                let daysLate = Int(ceil(Double(submission.lateSeconds) / (24 * 60 * 60.0)))
                let dueDate = submission.assignment?.dueAt
                return (status, daysLate, dueDate)
            }
            .removeDuplicates {
                // Without explicit comparison the compiler is unable to type check
                // the publisher chain, despite the tuple is implicitly equatable.
                $0 == $1
            }
            .catch { _ in Publishers.typedEmpty() }
            .eraseToAnyPublisher()
    }

    func updateLateDays(
        submissionId: String,
        userId: String,
        daysLate: Int
    ) -> AnyPublisher<Void, Error> {
        let lateSeconds = daysLate * 24 * 60 * 60
        let useCase = GradeSubmission(
            courseID: courseId,
            assignmentID: assignmentId,
            userID: userId,
            lateSeconds: lateSeconds
        )
        let store = ReactiveStore(useCase: useCase)
        return store.getEntities(ignoreCache: true)
            .mapToVoid()
            .eraseToAnyPublisher()
    }
}
