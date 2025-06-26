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
    @Published private(set) var selectedOption: OptionItem = OptionItem.none
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var isShowingDaysLateSection: Bool = false
    @Published private(set) var daysLate: String = ""
    @Published private(set) var daysLateA11yLabel: String = ""
    @Published private(set) var dueDate: String = ""
    @Published var isShowingSaveFailedAlert: Bool = false
    let daysLateA11yHint = String(localized: "Double-tap to change late days number.", bundle: .teacher)
    let options: [OptionItem]
    let errorAlertViewModel = ErrorAlertViewModel(
        title: String(localized: "Error", bundle: .teacher),
        message: String(localized: "Failed to save grade status.\nPlease try again.", bundle: .teacher),
        buttonTitle: String(localized: "OK", bundle: .teacher)
    )

    // MARK: - Inputs
    let didSelectGradeStatus = PassthroughSubject<OptionItem, Never>()
    let didChangeAttempt = PassthroughSubject<Int, Never>()
    let didChangeLateDaysValue = PassthroughSubject<Int, Never>()

    // MARK: - Private
    private let interactor: GradeStatusInteractor
    private let submissionId: String
    private let userId: String
    private var subscriptions = Set<AnyCancellable>()
    private var databaseObservation: AnyCancellable?

    init(
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
        uploadLateDays(on: didChangeLateDaysValue)
        didChangeAttempt.send(attempt)
    }

    private func uploadGradeStatus(
        on publisher: PassthroughSubject<OptionItem, Never>
    ) {
        publisher
            .compactMap { [weak self, interactor] selectedOption -> (OptionItem, GradeStatus)? in
                guard
                    let self,
                    self.selectedOption != selectedOption, // If the user selects the same option, we don't need to do anything
                    let selectedStatus = interactor.gradeStatuses.element(for: selectedOption)
                else {
                    return nil
                }
                self.isLoading = true
                let oldOption = self.selectedOption
                // We select the option now to make voiceover properly handle focus
                // after the menu is dismissed. If the request fails we revert to the old value.
                self.selectedOption = selectedOption

                // If late is disabled we instantly hide the days late section to avoid
                // inconsistencies of it being edited while the disable request is in progress.
                if oldOption.isLate {
                    self.isShowingDaysLateSection = false
                }

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
                guard let self else { return }

                if result.isFailure {
                    self.selectedOption = oldOption
                    self.isShowingSaveFailedAlert = true
                }

                self.isLoading = false

                if self.selectedOption.isLate {
                    self.isShowingDaysLateSection = true
                }
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

    private func refreshGradeStatus(on publisher: AnyPublisher<(GradeStatus, daysLate: Int, dueDate: Date?), Never>) {
        databaseObservation = publisher
            .map { (status, daysLate, dueDate) -> (OptionItem, daysLate: Int, dueDate: String) in
                (OptionItem.from(status), daysLate, dueDate?.relativeDateTimeString ?? "")
            }
            .receive(on: RunLoop.main)
            .sink { [weak self] (option, daysLate, dueDate) in
                self?.selectedOption = option
                self?.isShowingDaysLateSection = option.isLate
                self?.daysLate = "\(daysLate)"
                self?.dueDate = dueDate.isEmpty ? String(localized: "No Due Date", bundle: .teacher) : dueDate
                self?.daysLateA11yLabel = {
                    let daysLateText = String(localized: "\(daysLate) days late.", bundle: .teacher)
                    let dueDateText = dueDate.isEmpty ? String(localized: "No due date was set.", bundle: .teacher)
                                                      : String(localized: "Due date was on \(dueDate).", bundle: .teacher)
                    return "\(daysLateText) \(dueDateText)"
                }()
            }
    }

    private func uploadLateDays(on publisher: PassthroughSubject<Int, Never>) {
        let submissionId = self.submissionId
        let userId = self.userId

        publisher
            .map { [weak self] newLateDays in
                self?.isLoading = true
                return newLateDays
            }
            .flatMap { newLateDays in
                UIAccessibility.announcePersistently(
                    String(localized: "Saving days late.", bundle: .teacher)
                )
                .map { newLateDays }
            }
            .flatMap { [interactor] newLateDays in
                interactor.updateLateDays(
                    submissionId: submissionId,
                    userId: userId,
                    daysLate: newLateDays
                )
                .mapToResult()
            }
            .flatMap { result in
                if result.isSuccess {
                    return UIAccessibility.announcePersistently(
                        String(localized: "Days late successfully saved.", bundle: .teacher)
                    )
                    .map { result }
                    .eraseToAnyPublisher()
                } else {
                    return Just(result).eraseToAnyPublisher()
                }
            }
            .receive(on: RunLoop.main)
            .sink { [weak self] result in
                if result.isFailure {
                    self?.isShowingSaveFailedAlert = true
                }

                self?.isLoading = false
            }
            .store(in: &subscriptions)
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
    var isLate: Bool {
        id == LatePolicyStatus.late.rawValue
    }

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
