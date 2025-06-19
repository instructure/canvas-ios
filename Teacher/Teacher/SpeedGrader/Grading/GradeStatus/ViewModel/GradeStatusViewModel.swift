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

import Core
import Combine
import CombineExt
import SwiftUI

class GradeStatusViewModel: ObservableObject {
    // MARK: - Outputs
    @Published private(set) var selectedOption = OptionItem.none
    @Published private(set) var isLoading: Bool = false
    @Published var isShowingSaveFailedAlert = false
    let options: [OptionItem]
    let errorAlertViewModel = ErrorAlertViewModel(
        title: String(localized: "Error", bundle: .teacher),
        message: String(localized: "Failed to save grade status.\nPlease try again.", bundle: .teacher),
        buttonTitle: String(localized: "OK", bundle: .teacher)
    )

    // MARK: - Inputs
    let didSelectGradeStatus = PassthroughSubject<OptionItem, Never>()
    let didChangeAttempt = PassthroughSubject<Int, Never>()

    // MARK: - Private
    private let interactor: GradeStatusInteractor
    private let submissionId: String
    private let userId: String
    private var subscriptions = Set<AnyCancellable>()
    private var databaseObservation: AnyCancellable?

    init(
        customGradeStatusId: String?,
        latePolicyStatus: LatePolicyStatus?,
        userId: String,
        submissionId: String,
        attempt: Int,
        interactor: GradeStatusInteractor
    ) {
        self.interactor = interactor
        self.submissionId = submissionId
        self.userId = userId
        options = interactor.gradeStatuses
            .map { OptionItem(id: $0.id, title: $0.name) }
            .sorted { $0.title < $1.title }

        uploadGradeStatus(on: didSelectGradeStatus)
        observeGradeStatusOnAttemptInDatabase(on: didChangeAttempt)
        didChangeAttempt.send(attempt)
    }

    private func uploadGradeStatus(
        on publisher: PassthroughSubject<OptionItem, Never>
    ) {
        publisher
            .compactMap { [weak self, interactor] selectedOption -> (OptionItem, GradeStatus)? in
                guard let self, let selectedStatus = interactor.gradeStatuses.first(where: { $0.id == selectedOption.id }) else {
                    return nil
                }
                self.isLoading = true
                let oldOption = self.selectedOption
                // We select the option now to make voiceover properly handle focus
                // after the menu is dismissed. If the request fails we revert to the old value.
                self.selectedOption = selectedOption
                return (oldOption, selectedStatus)
            }
            .flatMap { (oldOption: OptionItem, selectedStatus: GradeStatus) in
                UIAccessibility.announcePersistently(
                    String(localized: "Saving grade status.", bundle: .teacher)
                )
                .map { (oldOption, selectedStatus) }
            }
            .flatMap { [submissionId, userId, interactor] (oldOption: OptionItem, selectedStatus: GradeStatus) in
                let customGradeStatusId = selectedStatus.isCustom ? selectedStatus.id : nil
                let latePolicyStatus = selectedStatus.isCustom ? nil : selectedStatus.id
                return interactor.updateSubmissionGradeStatus(
                    submissionId: submissionId,
                    userId: userId,
                    customGradeStatusId: customGradeStatusId,
                    latePolicyStatus: latePolicyStatus
                )
                .mapToResult()
                .map { ($0, oldOption) }
            }
            .flatMap { (result: Result<Void, Error>, oldOption: OptionItem) in
                Self.announceSuccessfulSaveIfNecessary(result: result, oldOption: oldOption)
            }
            .receive(on: RunLoop.main)
            .sink { [weak self] result, oldOption in
                if result.isFailure {
                    self?.selectedOption = oldOption
                    self?.isShowingSaveFailedAlert = true
                }

                self?.isLoading = false
            }
            .store(in: &subscriptions)
    }

    private func observeGradeStatusOnAttemptInDatabase(on publisher: PassthroughSubject<Int, Never>) {
        publisher
            .receive(on: RunLoop.main)
            .sink { [weak self] attempt in
                guard let self else { return }
                let gradeStatusChanged = self.interactor.observeGradeStatusChanges(
                    submissionId: self.submissionId,
                    attempt: attempt
                )
                self.refreshGradeStatus(on: gradeStatusChanged)
            }
            .store(in: &subscriptions)
    }

    private func refreshGradeStatus(on publisher: AnyPublisher<GradeStatus?, Never>) {
        databaseObservation = publisher
            .map { OptionItem.from($0) }
            .receive(on: RunLoop.main)
            .sink { [weak self] option in
                self?.selectedOption = option
            }
    }

    private static func announceSuccessfulSaveIfNecessary(
        result: Result<Void, Error>,
        oldOption: OptionItem
    ) -> AnyPublisher<(Result<Void, Error>, OptionItem), Never> {
        if result.isFailure {
            return Just((result, oldOption))
                .eraseToAnyPublisher()
        }

        return UIAccessibility.announcePersistently(
            String(localized: "Grade status successfully saved.", bundle: .teacher)
        )
        .map { (result, oldOption) }
        .eraseToAnyPublisher()
    }
}

private extension OptionItem {
    static var none: OptionItem {
        OptionItem(
            id: "none",
            title: String(localized: "None", bundle: .teacher)
        )
    }

    static func from(_ status: GradeStatus?) -> OptionItem {
        guard let status else { return .none }
        return OptionItem(id: status.id, title: status.name)
    }
}
