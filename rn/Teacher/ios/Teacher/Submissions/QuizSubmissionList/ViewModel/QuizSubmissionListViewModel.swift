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
    public let title = NSLocalizedString("Submissions", comment: "")
    public let filters = QuizSubmissionListFilter.allCases

    // MARK: - Inputs
    public let refreshDidTrigger = PassthroughSubject<() -> Void, Never>()
    public let messageUsersDidTap = PassthroughSubject<WeakViewController, Never>()
    public let submissionDidTap = PassthroughSubject<QuizSubmissionListItem, Never>()
    public let filterDidChange: CurrentValueSubject<QuizSubmissionListFilter, Never>

    // MARK: - Private
    private var subscriptions = Set<AnyCancellable>()
    private let interactor: QuizSubmissionListInteractor

    public init(router: Router, filterValue: QuizSubmissionListFilter, interactor: QuizSubmissionListInteractor) {
        self.interactor = interactor
        self.filter = filterValue
        filterDidChange = CurrentValueSubject<QuizSubmissionListFilter, Never>(filterValue)
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
            .combineLatest(interactor.createComposeUserInfo()) {viewController, userInfo in
                (viewController, userInfo)
            }
            .sink { [weak router] pelo in
                print(pelo.0)
                print(pelo.1)
              /*  router?.route(to: "/conversations/compose", userInfo: [
                            "recipients": submissions.compactMap { $0.user } .map { (user: User) -> [String: Any?] in [
                                "id": user.id,
                                "name": user.name,
                                "avatar_url": user.avatarURL,
                            ] },
                            "subject": interactor.quizTitle,
                            "contextName": course.first?.name ?? "",
                            "contextCode": context.canvasContextID,
                            "canAddRecipients": false,
                            "onlySendIndividualMessages": true,
                        ], from: self, options: .modal(embedInNav: true))
*/
            }
            .store(in: &subscriptions)
    }
}
