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

import Observation
import Combine
import CombineSchedulers
import Core

@Observable
final class AssignmentDetailsViewModel {
    // MARK: - Properties

    private(set) var assignment: HAssignment?
    private(set) var state: InstUI.ScreenState = .loading
    private(set) var didSubmitAssignment = false
    private(set) var attachments: [File] = []
    private(set) var errorMessage = ""
    private(set) var submissionEvents = PassthroughSubject<AssignmentSubmissionView.Events, Never>()
    private(set) var aiEvents = PassthroughSubject<(AIButtonsType, WeakViewController), Never>()
    let keyboardObserveID = "keyboardObserveID"
    var textEntry: String = ""
    var selectedSubmission: AssignmentType?
    var isShowSubmitButton = false
    var isShowAlertVisible = false
    var isKeyboardVisible = false
    var isSubmitButtonDisable: Bool {
        let selectedSubmission = selectedSubmission ?? .textEntry
        switch selectedSubmission {
        case .textEntry:
            return textEntry.isEmpty
        case .uploadFile:
            return attachments.isEmpty
        }
    }

    // MARK: - Properties

    private var subscriptions = Set<AnyCancellable>()
    var controller: WeakViewController = .init()

    // MARK: - Dependancies

    private let interactor: AssignmentInteractor
    private let appEnvironment: AppEnvironment
    private let scheduler: AnySchedulerOf<DispatchQueue>

    // MARK: - Init

    deinit {
        interactor.cancelAllFiles()
    }

    init(
        interactor: AssignmentInteractor,
        appEnvironment: AppEnvironment,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.interactor = interactor
        self.appEnvironment = appEnvironment
        self.scheduler = scheduler
        fetchAssignmentDetails()
        bindSubmissionAssignmentEvents()
    }

    // MARK: - Public Functions

    func showTabBar() { appEnvironment.tabBar(isVisible: true) }

    // MARK: - Private Functions

    private func fetchAssignmentDetails() {
        interactor.getAssignmentDetails()
            .sink { [weak self] response in
                self?.state = .data
                self?.assignment = response
            }
            .store(in: &subscriptions)
    }

    private func bindSubmissionAssignmentEvents() {
        submissionEvents.sink { [weak self] event in
            guard let self else {
                return
            }
            switch event {
            case .onTextEntry:
                submitTextEntry()
            case .uploadFile(url: let url):
                interactor.addFile(url: url)
            case .sendFileTapped:
                state = .loading
                interactor.uploadFiles()
            case .deleteFile(file: let file):
                interactor.cancelFile(file)
            }
        }
        .store(in: &subscriptions)

        interactor.attachments
            .receive(on: scheduler)
            .sink { [weak self] values in
                self?.attachments = values
            }
            .store(in: &subscriptions)

        interactor
            .didUploadFiles
            .receive(on: scheduler)
            .sink { [weak self] result in
                switch result {
                case .success:
                    self?.state = .data
                    self?.didSubmitAssignment = true
                case .failure(let error):
                    self?.state = .data
                    self?.isShowAlertVisible = true
                    self?.errorMessage = error.localizedDescription
                }
            }.store(in: &subscriptions)

        aiEvents.sink {  [weak self] event, controller in
            switch event {
            case .assist:
                self?.appEnvironment.router.route(to: "/tutor", from: controller)
            default:
                break

            }
        }.store(in: &subscriptions)
    }

    private func submitTextEntry() {
        state = .loading
        interactor.submitTextEntry(with: textEntry)
            .sink { [weak self] completion in
                self?.state = .data
                if case .failure(let error) = completion {
                    self?.isShowAlertVisible = true
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] _ in
                self?.didSubmitAssignment = true
            }
            .store(in: &subscriptions)
    }
}
