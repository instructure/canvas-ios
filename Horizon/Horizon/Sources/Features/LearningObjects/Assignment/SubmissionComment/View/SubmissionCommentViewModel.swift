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
import Core
import Observation
import Foundation

@Observable
final class SubmissionCommentViewModel {
    enum ViewState {
        case initialLoading
        case postingComment
        case data
        case error
    }

    // MARK: - Dependencies

    private let courseID: String
    private let assignmentID: String
    private let attempt: Int?
    private let router: Router
    private let interactor: SubmissionCommentInteractor
    private let fileInteractor: DownloadFileInteractor

    // MARK: - Inputs/Outputs

    var text = ""

    // MARK: - Outputs

    private(set) var viewState: ViewState = .initialLoading
    private(set) var isPostingComment: Bool = false
    private(set) var arePaginationButtonsVisible: Bool = false
    private(set) var isNextButtonEnabled: Bool = false
    private(set) var isPreviousButtonEnabled: Bool = false
    private(set) var comments: [SubmissionComment] = []
    private(set) var fileState: FileDownloadStatus = .initial

    // MARK: - Private properties

    private static let pageSize = 5

    private var subscriptions = Set<AnyCancellable>()
    private var fileSubscription: AnyCancellable?
    private var allComments: [SubmissionComment] = []
    private var currentPage = 0

    // MARK: - Init

    init(
        courseID: String,
        assignmentID: String,
        attempt: Int?,
        interactor: SubmissionCommentInteractor,
        fileInteractor: DownloadFileInteractor,
        router: Router
    ) {
        self.courseID = courseID
        self.assignmentID = assignmentID
        self.attempt = attempt
        self.router = router
        self.interactor = interactor
        self.fileInteractor = fileInteractor
        getComments()
    }

    // MARK: - Inputs

    func goBack(from viewController: WeakViewController) {
        router.pop(from: viewController)
    }

    func postComment() {
        viewState = .postingComment
        interactor.postComment(
            courseID: courseID,
            assignmentID: assignmentID,
            attempt: attempt,
            text: text
        )
        .sink(
            receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    self?.getComments(ignoreCache: true)
                case .failure:
                    self?.viewState = .error
                }
            },
            receiveValue: { _ in }
        ).store(in: &subscriptions)
    }

    func downloadFile(attachment: CommentAttachment, viewController: WeakViewController) {
        guard let url = attachment.url, let name = attachment.displayName else {
            return
        }
        fileState = .loading
        fileSubscription = fileInteractor.download(
            remoteURL: url,
            fileName: name
        )
        .sink(
            receiveCompletion: { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.fileState = .error(error.localizedDescription)
                }
            },
            receiveValue: { [weak self] url in
                self?.fileState = .initial
                self?.showShareSheet(fileURL: url, viewController: viewController)
            }
        )
    }

    func cancelDownload() {
        fileSubscription?.cancel()
        fileState = .initial
    }

    func goNext() {
        currentPage -= 1
        updateCurrentPageComments()
    }

    func goPrevious() {
        currentPage += 1
        updateCurrentPageComments()
    }

    func refresh() async {
        await withCheckedContinuation { continuation in
            getComments(ignoreCache: true) {
                continuation.resume()
            }
        }
    }

    // MARK: - Private functions

    private func getComments(ignoreCache: Bool = false, completionHandler: (() -> Void)? = nil) {
        interactor.getComments(
            assignmentID: assignmentID,
            attempt: attempt ?? 0,
            ignoreCache: ignoreCache
        )
        .sink(
            receiveCompletion: { [weak self] completion in
                if case .failure = completion {
                    self?.viewState = .error
                }
                completionHandler?()
            },
            receiveValue: { [weak self] comments in
                guard let self else { return }
                text = ""
                viewState = .data
                allComments = comments
                currentPage = 0
                updateCurrentPageComments()
            }
        )
        .store(in: &subscriptions)
    }

    private func updateCurrentPageComments() {
        let total = allComments.count
        let end = total - currentPage * Self.pageSize
        let start = max(0, end - Self.pageSize)
        comments = Array(allComments[start..<end])
        arePaginationButtonsVisible = total > Self.pageSize
        isNextButtonEnabled = currentPage > 0
        isPreviousButtonEnabled = start > 0
    }

    private func showShareSheet(fileURL: URL, viewController: WeakViewController) {
        let controller = CoreActivityViewController(activityItems: [fileURL], applicationActivities: nil)
        DispatchQueue.main.async { [weak self] in
            self?.router.show(controller, from: viewController, options: .modal())
        }
    }
}
