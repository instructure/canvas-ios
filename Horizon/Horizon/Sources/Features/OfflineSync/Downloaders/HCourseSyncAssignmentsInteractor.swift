//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

import Core
import Combine

struct HAttachmentDownloadProgress {
    let totalSize: Double
    let downloadedSize: Double
    let isComplete: Bool
    let downloadedFiles: [(courseID: String, fileID: String)]

    static let zero = HAttachmentDownloadProgress(totalSize: 0, downloadedSize: 0, isComplete: false, downloadedFiles: [])
}

protocol HCourseSyncAssignmentsInteractor {
    var attachmentProgressPublisher: AnyPublisher<HAttachmentDownloadProgress, Never> { get }
    func getContent(courseIds: [String], sessionID: String) -> AnyPublisher<Void, Error>
    func cancelDownloads()
}

final class HCourseSyncAssignmentsInteractorLive: HCourseSyncAssignmentsInteractor {
    // MARK: - Private variables
    private var subscriptions = Set<AnyCancellable>()
    private let attachmentProgressSubject = CurrentValueSubject<HAttachmentDownloadProgress, Never>(.zero)

    // MARK: - Outputs

    var attachmentProgressPublisher: AnyPublisher<HAttachmentDownloadProgress, Never> {
        attachmentProgressSubject.eraseToAnyPublisher()
    }

    // MARK: - Dependencies

    public let htmlParser: HTMLParser
    private let filesInteractor: HCourseSyncFilesInteractor
    private let userId: String

    // MARK: - Init

    public init(
        htmlParser: HTMLParser,
        filesInteractor: HCourseSyncFilesInteractor,
        userId: String
    ) {
        self.htmlParser = htmlParser
        self.filesInteractor = filesInteractor
        self.userId = userId
    }

    func cancelDownloads() {
        subscriptions.removeAll()
        attachmentProgressSubject.send(.zero)
    }

    func getContent(
        courseIds: [String],
        sessionID: String
    ) -> AnyPublisher<Void, Error> {
        attachmentProgressSubject.send(.zero)
        return Publishers.Sequence(sequence: courseIds)
            .flatMap { [weak self] courseId -> AnyPublisher<Void, Error> in
                guard let self else {
                    return Just(())
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                return self.getContent(
                    courseId: courseId,
                    sessionID: sessionID
                )
            }
            .collect()
            .mapToVoid()
            .handleEvents(receiveCompletion: { [weak self] _ in
                guard let self else { return }
                let current = self.attachmentProgressSubject.value
                self.attachmentProgressSubject.send(HAttachmentDownloadProgress(
                    totalSize: current.totalSize,
                    downloadedSize: current.downloadedSize,
                    isComplete: true,
                    downloadedFiles: current.downloadedFiles
                ))
            })
            .eraseToAnyPublisher()
    }

    private func getContent(courseId: String, sessionID: String) -> AnyPublisher<Void, Error> {
        ReactiveStore(useCase: GetAssignmentsByGroup(courseID: courseId.localID))
        .getEntities(ignoreCache: true)
        .parseHtmlContent(attribute: \.details, id: \.id, courseId: .init(value: courseId), htmlParser: htmlParser)
        .flatMap { Publishers.Sequence(sequence: $0).setFailureType(to: Error.self) }
        .filter { $0.submission != nil }
        .flatMap { [weak self] assignment -> AnyPublisher<Void, Error> in
            guard let self else {
                return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
            }
            return self.getSubmissionContent(
                courseID: courseId,
                assignmentID: assignment.id,
                userID: assignment.submission!.userID,
                sessionID: sessionID
            )
        }
        .collect()
        .map { _ in () }
        .eraseToAnyPublisher()
    }

    private func getSubmissionContent(
        courseID: String,
        assignmentID: String,
        userID: String,
        sessionID: String
    ) -> AnyPublisher<Void, Error> {
        ReactiveStore(
            useCase: GetSubmission(
                context: .course(courseID),
                assignmentID: assignmentID,
                userID: userID
            )
        )
        .getEntities(ignoreCache: true)
        .parseHtmlContent(
            attribute: \.body,
            id: \.id,
            courseId: .init(value: courseID),
            htmlParser: htmlParser
        )
        .flatMap { [weak self] submissions -> AnyPublisher<Void, Error> in
            guard let self else {
                return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
            }
            let commentsPublisher = self.fetchSubmissionComments(
                submissions: submissions,
                assignmentID: assignmentID,
                userID: userID
            )
            let attachmentsPublisher = self.downloadSubmissionAttachments(
                submissions: submissions,
                courseID: courseID,
                sessionID: sessionID
            )
            return Publishers.Zip(commentsPublisher, attachmentsPublisher)
                .mapToVoid()
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }

    private func fetchSubmissionComments(
        submissions: [Submission],
        assignmentID: String,
        userID: String
    ) -> AnyPublisher<Void, Error> {
        Publishers.Sequence(sequence: submissions)
            .flatMap { [weak self] submission -> AnyPublisher<Void, Never> in
                guard let self else {
                    return Just(()).eraseToAnyPublisher()
                }
                return self.getSubmissionComments(
                    assignmentID: assignmentID,
                    userID: userID,
                    forAttempt: submission.attempt
                )
            }
            .collect()
            .mapToVoid()
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    private func getSubmissionComments(
        assignmentID: String,
        userID: String,
        forAttempt: Int
    ) -> AnyPublisher<Void, Never> {
        ReactiveStore(
            useCase: GetHSubmissionCommentsUseCase(
                userId: userID,
                assignmentId: assignmentID,
                forAttempt: forAttempt
            )
        )
        .getEntities(ignoreCache: true)
        .replaceError(with: [])
        .mapToVoid()
        .eraseToAnyPublisher()
    }

    private func downloadSubmissionAttachments(
        submissions: [Submission],
        courseID: String,
        sessionID: String
    ) -> AnyPublisher<Void, Error> {
        let attachments = submissions
            .compactMap(\.attachments)
            .flatMap { $0 }

        guard attachments.isNotEmpty else {
            return Just(())
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        let totalSize = Double(attachments.map(\.size).reduce(0, +))
        let prior = attachmentProgressSubject.value
        attachmentProgressSubject.send(HAttachmentDownloadProgress(
            totalSize: prior.totalSize + totalSize,
            downloadedSize: prior.downloadedSize,
            isComplete: false,
            downloadedFiles: prior.downloadedFiles
        ))

        var progressByFileID: [String: Double] = [:]

        return Publishers.Sequence(sequence: attachments)
            .flatMap { [filesInteractor, attachmentProgressSubject] file in
                let fileID = file.id ?? ""
                let fileSize = Double(file.size)
                return filesInteractor.download(file: file, courseID: courseID, sessionID: sessionID)
                    .handleEvents(receiveOutput: { progress in
                        let newDownloaded = fileSize * Double(progress)
                        let delta = newDownloaded - (progressByFileID[fileID] ?? 0)
                        progressByFileID[fileID] = newDownloaded
                        let current = attachmentProgressSubject.value
                        var downloadedFiles = current.downloadedFiles
                        if progress >= 1.0 {
                            downloadedFiles.append((courseID: courseID, fileID: fileID))
                        }
                        attachmentProgressSubject.send(HAttachmentDownloadProgress(
                            totalSize: current.totalSize,
                            downloadedSize: current.downloadedSize + delta,
                            isComplete: false,
                            downloadedFiles: downloadedFiles
                        ))
                    })
            }
            .collect()
            .mapToVoid()
            .eraseToAnyPublisher()
    }
}
