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
    @Published public private(set) var scope: QuizSubmissionListScope = DefaultScope
    @Published public var isShowingScopeSelector = false
    @Published public var subTitle: String = ""
    public let title = NSLocalizedString("Submissions", comment: "")
    public let scopes = QuizSubmissionListScope.allCases

    // MARK: - Inputs
    public let refreshDidTrigger = PassthroughSubject<() -> Void, Never>()
    public let messageAllUsersDidTap = PassthroughSubject<WeakViewController, Never>()
    public let submissionDidTap = PassthroughSubject<QuizSubmissionListItem, Never>()
    public let scopeDidChange = CurrentValueSubject<QuizSubmissionListScope, Never>(DefaultScope)

    // MARK: - Private
    private var subscriptions = Set<AnyCancellable>()
    private let interactor: QuizSubmissionListInteractor
    private static let DefaultScope: QuizSubmissionListScope = .all

    public init(router: Router, interactor: QuizSubmissionListInteractor) {
        self.interactor = interactor
        // MARK: - Output
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
        // MARK: - Input
        messageAllUsersDidTap
            .sink { viewController in
                router.route(to: "conversations/compose", from: viewController)
            }
            .store(in: &subscriptions)
        // MARK: - User actions
        scopeDidChange
            .assign(to: &$scope)
        scopeDidChange
            .removeDuplicates()
            .map { interactor.setScope($0) }
            .sink()
            .store(in: &subscriptions)
    }
}
