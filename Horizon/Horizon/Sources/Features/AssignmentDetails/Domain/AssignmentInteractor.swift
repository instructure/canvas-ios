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

protocol AssignmentInteractor {
    func getAssignmentDetails() -> AnyPublisher<HAssignment, Never>
    func submitTextEntry(with text: String) -> AnyPublisher<[CreateSubmission.Model], Error>
    func addFile(url: URL)
    func cancelFile(_ file: File)
    func cancelAllFiles()
    func uploadFiles()
    var attachments: CurrentValueSubject<[File], Never> { get }
    var didUploadFiles: PassthroughSubject<Result<Void, Error>, Never> { get }
}

final class AssignmentInteractorLive: AssignmentInteractor {
    // MARK: - Outputs

    public let attachments = CurrentValueSubject<[File], Never>([])
    public let didUploadFiles = PassthroughSubject<Result<Void, Error>, Never>()

    // MARK: - Properties

    private lazy var fileStore = uploadManager.subscribe(batchID: batchId, eventHandler: {})
    private var subscriptions = Set<AnyCancellable>()
    private var batchId: String {
        "assignment-\(assignmentID)"
    }
    // MARK: - Dependancies

    private let courseID: String
    private let assignmentID: String
    private let appEnvironment: AppEnvironment
    private let uploadManager: UploadManager

    // MARK: - Init

    init(
        courseID: String,
        assignmentID: String,
        appEnvironment: AppEnvironment,
        uploadManager: UploadManager
    ) {
        self.courseID = courseID
        self.assignmentID = assignmentID
        self.appEnvironment = appEnvironment
        self.uploadManager = uploadManager

        fileStore.refresh()

        fileStore
            .allObjects
            .replaceError(with: [])
            .sink { [weak self] files in
                self?.attachments.send(files)
            }
            .store(in: &subscriptions)

        uploadManager
            .didUploadFile
            .subscribe(didUploadFiles)
            .store(in: &subscriptions)
    }

    func getAssignmentDetails() -> AnyPublisher<HAssignment, Never> {
        let includes: [GetAssignmentRequest.GetAssignmentInclude] = [.submission, .score_statistics]
        return ReactiveStore(useCase: GetAssignment(courseID: courseID, assignmentID: assignmentID, include: includes))
            .getEntities()
            .replaceError(with: [])
            .compactMap { $0.first }
            .map { HAssignment(from: $0)}
            .eraseToAnyPublisher()
    }

    func submitTextEntry(with text: String) -> AnyPublisher<[CreateSubmission.Model], Error> {
        let userID = appEnvironment.currentSession?.userID ?? ""
        let createSubmission = CreateSubmission(
            context: .course(courseID),
            assignmentID: assignmentID,
            userID: userID,
            submissionType: .online_text_entry,
            body: text
        )
        return ReactiveStore(useCase: createSubmission)
            .getEntities()
    }

    func addFile(url: URL) {
        do {
            try uploadManager.add(url: url, batchID: batchId)
            fileStore.refresh()
        } catch { debugPrint(error) }
    }

    func cancelFile(_ file: File) {
        uploadManager.cancel(file: file)
    }

    func uploadFiles() {
        let context = FileUploadContext.submission(courseID: courseID, assignmentID: assignmentID, comment: nil)
        UploadManager.shared.upload(batch: batchId, to: context)
    }

    func cancelAllFiles() {
        uploadManager.cancel(batchID: batchId)
    }
}
