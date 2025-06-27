//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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
import Core
import Combine

protocol AssignmentInteractor: HUploadFileManager {
    func getAssignmentDetails(ignoreCache: Bool) -> AnyPublisher<HAssignment, Error>
    func submitTextEntry(
        with text: String,
        moduleID: String,
        moduleItemID: String
    ) -> AnyPublisher<[CreateSubmission.Model], Error>
    func getSubmissions(ignoreCache: Bool) -> AnyPublisher<[HSubmission], Error>
}

final class AssignmentInteractorLive: AssignmentInteractor {
    // MARK: - Outputs

    public let attachments = CurrentValueSubject<[File], Never>([])
    public let didUploadFiles = PassthroughSubject<Result<Void, Error>, Never>()

    // MARK: - Properties

    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Dependancies

    private let courseID: String
    private let assignmentID: String
    private let userID: String
    private let uploadManager: HUploadFileManager
    private let appEnvironment: AppEnvironment

    // MARK: - Init

    init(
        courseID: String,
        assignmentID: String,
        userID: String,
        uploadManager: HUploadFileManager,
        appEnvironment: AppEnvironment
    ) {
        self.courseID = courseID
        self.assignmentID = assignmentID
        self.userID = userID
        self.uploadManager = uploadManager
        self.appEnvironment = appEnvironment

        uploadManager.attachments
            .subscribe(attachments)
            .store(in: &subscriptions)

        uploadManager
            .didUploadFiles
            .subscribe(didUploadFiles)
            .store(in: &subscriptions)
    }

    func getAssignmentDetails(ignoreCache: Bool) -> AnyPublisher<HAssignment, Error> {
        let includes: [GetAssignmentRequest.GetAssignmentInclude] = [.submission, .score_statistics]
        return ReactiveStore(
            useCase: GetAssignment(
                courseID: courseID,
                assignmentID: assignmentID,
                include: includes
            )
        )
        .getEntities(ignoreCache: ignoreCache)
        .compactMap { $0.first }
        .map { HAssignment(from: $0)}
        .eraseToAnyPublisher()
    }

    func submitTextEntry(with text: String, moduleID: String, moduleItemID: String) -> AnyPublisher<[CreateSubmission.Model], Error> {
        let userID = appEnvironment.currentSession?.userID ?? ""
        let createSubmission = CreateSubmission(
            context: .course(courseID),
            assignmentID: assignmentID,
            userID: userID,
            submissionType: .online_text_entry,
            body: text,
            moduleID: moduleID,
            moduleItemID: moduleItemID
        )
        return ReactiveStore(useCase: createSubmission)
            .getEntities()
    }

    func addFile(url: URL) {
        uploadManager.addFile(url: url)
    }

    func cancelFile(_ file: File) {
        uploadManager.cancelFile(file)
    }

    func uploadFiles() {
        uploadManager.uploadFiles()
    }

    func cancelAllFiles() {
        uploadManager.cancelAllFiles()
    }

    func getSubmissions(ignoreCache: Bool) -> AnyPublisher<[HSubmission], Error> {
        let useCase = GetSubmission(context: .course(courseID), assignmentID: assignmentID, userID: userID)
        return ReactiveStore(useCase: useCase)
            .getEntities(ignoreCache: ignoreCache)
            .flatMap { Publishers.Sequence(sequence: $0).setFailureType(to: Error.self)}
            .filter { $0.attempt != 0 }
            .map { HSubmission(entity: $0) }
            .collect()
            .eraseToAnyPublisher()
    }
}
