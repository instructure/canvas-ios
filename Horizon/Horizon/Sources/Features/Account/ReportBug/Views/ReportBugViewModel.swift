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
import CombineSchedulers
import Observation
import Foundation

@Observable
final class ReportBugViewModel {
    // MARK: - Inputs / Outputs

    var isShowError = false
    var selectedTopic: String = "" { didSet { checkValidity() } }
    var subject: String = "" { didSet { checkValidity() } }
    var description: String = "" { didSet { checkValidity() } }

    // MARK: - Outputs

    private(set) var isSubmitEnabled = false
    private(set) var state: InstUI.ScreenState = .loading
    private(set) var errorMessage = ""
    var listTopics: [String] = [
        String(localized: "Suggestion or comment", bundle: .horizon),
        String(localized: "General help", bundle: .horizon),
        String(localized: "Minor issue", bundle: .horizon),
        String(localized: "Urgent issue", bundle: .horizon),
        String(localized: "Critical system error", bundle: .horizon)
    ]

    // MARK: - Private Variables

    private var subscriptions = Set<AnyCancellable>()
    private var userEmail = ""

    // MARK: - Dependencies

    private let api: API
    private let router: Router
    private let baseURL: String
    private let scheduler: AnySchedulerOf<DispatchQueue>

    // MARK: - Init

    init(
        getUserInteractor: GetUserInteractor = GetUserInteractorLive(),
        api: API,
        baseURL: String,
        router: Router,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.api = api
        self.baseURL = baseURL
        self.router = router
        self.scheduler = scheduler
        getUserInteractor
            .getUser()
            .receive(on: scheduler)
            .sinkFailureOrValue { [weak self] error in
                self?.state = .data
                self?.errorMessage = error.localizedDescription
                self?.isShowError = true
        } receiveValue: { [weak self] user in
            self?.userEmail = user.email.defaultToEmpty
            self?.state = .data
        }
        .store(in: &subscriptions)
    }

    // MARK: - Actions

    func submit(viewController: WeakViewController) {
        state = .loading
        api.makeRequest(
            ReportBugRequest(
                subject: subject,
                topic: selectedTopic,
                description: description,
                email: userEmail,
                url: baseURL
            )
        )
        .receive(on: scheduler)
        .sinkFailureOrValue { [weak self] error in
            self?.state = .data
            self?.errorMessage = error.localizedDescription
            self?.isShowError = true
        } receiveValue: { [weak self] _ in
            self?.state = .data
            self?.dimiss(viewController: viewController)
        }
        .store(in: &subscriptions)
    }

    func dimiss(viewController: WeakViewController) {
        router.dismiss(viewController)
    }

    // MARK: - Private Functions

    private func checkValidity() {
        isSubmitEnabled = selectedTopic.trimmedEmptyLines.isNotEmpty &&
        subject.trimmedEmptyLines.isNotEmpty &&
        description.trimmedEmptyLines.isNotEmpty
    }
}
