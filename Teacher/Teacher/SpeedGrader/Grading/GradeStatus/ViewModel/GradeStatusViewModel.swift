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
import SwiftUI

class GradeStatusViewModel: ObservableObject {
    // MARK: - Outputs
    @Published private(set) var selectedOption: OptionItem
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

    // MARK: - Private
    private let gradeStatuses: [GradeStatus]
    private let interactor: GradeStatusInteractor
    private let submissionId: String
    private var subscriptions = Set<AnyCancellable>()
    private static let defaultOption = OptionItem(
        id: "none",
        title: String(localized: "None", bundle: .teacher)
    )

    init(
        gradeStatuses: [GradeStatus],
        customGradeStatusId: String?,
        latePolicyStatus: LatePolicyStatus?,
        selectedId: String? = nil,
        submissionId: String,
        interactor: GradeStatusInteractor
    ) {
        self.gradeStatuses = gradeStatuses
        self.interactor = interactor
        self.submissionId = submissionId
        options = gradeStatuses.map { OptionItem(id: $0.id, title: $0.name) }

        if let initialStatus = gradeStatuses.gradeStatusFor(
            customGradeStatusId: customGradeStatusId,
            latePolicyStatus: latePolicyStatus
        ) {
            self.selectedOption = OptionItem(id: initialStatus.id, title: initialStatus.name)
        } else {
            self.selectedOption = Self.defaultOption
        }

        uploadGradeStatus(on: didSelectGradeStatus)
    }

    private func uploadGradeStatus(
        on publisher: PassthroughSubject<OptionItem, Never>
    ) {
        publisher
            .compactMap { [gradeStatuses] selectedOption in
                guard let selectedStatus = gradeStatuses.first(where: { $0.id == selectedOption.id }) else {
                    return nil
                }
                return (selectedOption, selectedStatus)
            }
            .map { [weak self] (selectedOption: OptionItem, selectedStatus: GradeStatus) in
                self?.isLoading = true
                return (selectedOption, selectedStatus)
            }
            .flatMap { [submissionId, interactor] (selectedOption, selectedStatus) in
                let customGradeStatusId = selectedStatus.isCustom ? selectedStatus.id : nil
                let latePolicyStatus = selectedStatus.isCustom ? nil : selectedStatus.id
                return interactor.updateSubmissionGradeStatus(
                    submissionId: submissionId,
                    customGradeStatusId: customGradeStatusId,
                    latePolicyStatus: latePolicyStatus
                )
                .map { (selectedOption, selectedStatus) }
            }
            .receive(on: RunLoop.main)
            .sinkFailureOrValue(
                receiveFailure: { [weak self] _ in
                    self?.isLoading = false
                    self?.isShowingSaveFailedAlert = true
                },
                receiveValue: { [weak self] (selectedOption, selectedStatus) in
                    self?.selectedOption = selectedOption
                    self?.isLoading = false
                }
            )
            .store(in: &subscriptions)
    }
}

extension [GradeStatus] {

    func gradeStatusFor(
        customGradeStatusId: String?,
        latePolicyStatus: LatePolicyStatus?
    ) -> GradeStatus? {
        if let customGradeStatusId {
            return first { $0.isCustom && $0.id == customGradeStatusId }
        } else if let lateStatus = latePolicyStatus?.rawValue {
            return first { !$0.isCustom && $0.id == lateStatus }
        }
        return nil
    }
}
