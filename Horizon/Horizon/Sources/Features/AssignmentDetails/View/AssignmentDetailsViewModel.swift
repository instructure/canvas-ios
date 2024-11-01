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
    // MARK: - Output Properties
    private(set) var assignment: HAssignment?
    private(set) var state: InstUI.ScreenState = .loading
    private(set) var didSubmitAssignment = false
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Input Properties
    var onSelectSubmissionType: ((AssignmentSubmission.Events) -> Void)?

    // MARK: - Dependance
    private let interactor: AssignmentInteractor
    private let scheduler: AnySchedulerOf<DispatchQueue>

    // MARK: - Init
    init(
        interactor: AssignmentInteractor,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.interactor = interactor
        self.scheduler = scheduler
        fetchAssignmentDetails()
        bindSubmissionAssignmentEvents()
    }

    private func fetchAssignmentDetails() {
        interactor.getAssignmentDetails()
            .sink { [weak self] response in
                self?.state = .data
                self?.assignment = response
            }
            .store(in: &subscriptions)
    }

    private func bindSubmissionAssignmentEvents() {
        onSelectSubmissionType = { [weak self] event in
            switch event {
            case .onTextEntry(text: let text, controller: let controller):
                self?.submitTextEntry(with: text, controller: controller)
            }
        }
    }

    private func submitTextEntry(with text: String, controller: WeakViewController) {
        state = .loading
        interactor.submitTextEntry(with: text)
            .sink { [weak self] completion in
            self?.state = .data
            if case .failure(let error) = completion {
                self?.showAlertError(with: error.localizedDescription, controller: controller)
            }
        } receiveValue: { [weak self] _ in
            self?.didSubmitAssignment = true
        }
        .store(in: &subscriptions)
    }

    private func showAlertError(with message: String, controller: WeakViewController) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: String(localized: "OK", bundle: .core), style: .default))
        AppEnvironment.shared.router.show(alert, from: controller)
    }
}
