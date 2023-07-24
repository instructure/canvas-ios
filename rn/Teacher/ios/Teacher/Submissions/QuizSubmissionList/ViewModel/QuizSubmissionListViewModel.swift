//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

class QuizSubmissionListViewModel: ObservableObject {
    // MARK: - Outputs
    @Published public private(set) var state: StoreState = .loading
    @Published public private(set) var submissions: [QuizSubmissionListItemViewModel] = []
    @Published public private(set) var filter: QuizSubmissionListFilter
    @Published public var isShowingFilterSelector = false
    @Published public var subTitle: String = ""
    @Published public var showError: Bool = false
    @Published public var courseID: String = ""
    @Published public var quizID: String = ""

    public let title = NSLocalizedString("Submissions", comment: "")
    public let filters = QuizSubmissionListFilter.allCases

    // MARK: - Inputs
    public let refreshDidTrigger = PassthroughSubject<() -> Void, Never>()
    public let messageUsersDidTap = PassthroughSubject<WeakViewController, Never>()
    public let filterDidChange: CurrentValueSubject<QuizSubmissionListFilter, Never>

    // MARK: - Private
    private var subscriptions = Set<AnyCancellable>()
    private let interactor: QuizSubmissionListInteractor

    public init(router: Router, filterValue: QuizSubmissionListFilter, interactor: QuizSubmissionListInteractor) {
        self.interactor = interactor
        self.filter = filterValue
        self.courseID = interactor.courseID
        self.quizID = interactor.quizID

        filterDidChange = CurrentValueSubject<QuizSubmissionListFilter, Never>(filterValue)

        setupOutputBindings()
        setupInputBindings(router: router)
    }

    public func submissionDidTap() {
        showError = true
    }

    private func setupOutputBindings() {
        interactor.state
            .assign(to: &$state)
        interactor.submissions
            .map { submissions in
                submissions.map {
                    QuizSubmissionListItemViewModel(item: $0)
                }
            }
            .assign(to: &$submissions)
        interactor.quizTitle
            .assign(to: &$subTitle)
    }

    private func setupInputBindings(router: Router) {
        let interactor = self.interactor
        subscribeToMessageUsersTapEvents(router: router)
        refreshDidTrigger
            .delay(for: .seconds(1), scheduler: RunLoop.main)
            .flatMap { refreshCompletion in
                interactor
                    .refresh()
                    .receive(on: DispatchQueue.main)
                    .handleEvents(receiveOutput: { refreshCompletion() })
            }
            .sink()
            .store(in: &subscriptions)
        filterDidChange
            .assign(to: &$filter)
        filterDidChange
            .removeDuplicates()
            .map { interactor.setFilter($0) }
            .sink()
            .store(in: &subscriptions)
    }

    private func subscribeToMessageUsersTapEvents(router: Router) {
        messageUsersDidTap
            .flatMap { [interactor] viewController in
                interactor
                    .createMessageUserInfo()
                    .map { (viewController, $0) }
            }
            .sink { [router] in
                router.route(to: "/conversations/compose",
                             userInfo: $0.1,
                             from: $0.0,
                             options: .modal(embedInNav: true))
            }
            .store(in: &subscriptions)
    }
}
