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
import UIKit
import Combine
import CombineSchedulers

class SubmissionListViewModel: ObservableObject {

    enum ViewState: Equatable {
        case loading
        case data
        case empty
        case error
    }

    @Published private(set) var state: ViewState = .loading

    @Published var searchText: String = ""
    @Published var filterMode: SubmissionFilterMode

    @Published var assignment: Assignment?
    @Published var course: Course?
    @Published var sections: [SubmissionListSection] = []

    private let interactor: SubmissionListInteractor
    private let scheduler: AnySchedulerOf<DispatchQueue>
    private let env: AppEnvironment
    private var subscriptions = Set<AnyCancellable>()

    init(interactor: SubmissionListInteractor, filterMode: SubmissionFilterMode, env: AppEnvironment, scheduler: AnySchedulerOf<DispatchQueue> = .main) {
        self.interactor = interactor
        self.filterMode = filterMode
        self.env = env
        self.scheduler = scheduler
        setupBindings()
    }

    // MARK: Privates

    private func setupBindings() {
        interactor.assignment.assign(to: &$assignment)
        interactor.course.assign(to: &$course)

        Publishers.CombineLatest(
            interactor.submissions.receive(on: scheduler),
            $searchText.throttle(for: 0.5, scheduler: scheduler, latest: true)
        )
        .map({ (list, searchText) in

            let searchTerm = searchText.lowercased()
            var curatedItems = list
                .enumerated()
                .map { [weak self] offset, sub in
                    let item = SubmissionListItem(
                        submission: sub,
                        assignment: self?.assignment,
                        order: offset + 1
                    )
                    return (item, sub)
                }

            if searchTerm.isNotEmpty {
                curatedItems = curatedItems.filter { $0.1.user?.nameContains(searchTerm) ?? false }
            }

            return SubmissionListSection.Kind
                .allCases
                .map { kind in
                    let items = curatedItems
                        .filter { kind.filter($0.1) }
                        .map { $0.0 }
                    return SubmissionListSection(kind: kind, items: items)
                }
                .filter({ $0.items.isNotEmpty })
        })
        .assign(to: &$sections)

        interactor
            .submissions
            .receive(on: scheduler)
            .map({ $0.isEmpty ? ViewState.empty : ViewState.data })
            .assign(to: &$state)

        $filterMode
            .sink { [weak self] mode in
                self?.interactor.applyFilters(mode.filters)
            }
            .store(in: &subscriptions)
    }

    private var assignmentRoute: String {
        "/\(interactor.context.pathComponent)/assignments/\(interactor.assignmentID)"
    }

    // MARK: Exposed To View

    func refresh() async {

        await withCheckedContinuation { [weak self] continuation in
            guard let self else { return continuation.resume() }

            interactor
                .refresh()
                .receive(on: scheduler)
                .sink {
                    continuation.resume()
                }
                .store(in: &self.subscriptions)
        }
    }

    func messageUsers(from controller: WeakViewController) {
        guard var subject = assignment?.name else { return }

        if filterMode != .all {
            subject = "\(filterMode.title) - \(subject)"
        }

        let recipients = sections
            .flatMap { section in
                section.items.compactMap { $0.user?.asRecipient }
            }

        let recipientContext = RecipientContext(
            name: course?.name ?? "",
            context: interactor.context
        )

        let composeMessageOptions = ComposeMessageOptions(
            disabledFields: .init(contextDisabled: true, recipientsDisabled: true, individualDisabled: true),
            fieldsContents: .init(
                selectedContext: recipientContext,
                selectedRecipients: recipients,
                subjectText: subject,
                individualSend: true
            )
        )

        env.router.route(
            to: URLComponents.parse("/conversations/compose", queryItems: composeMessageOptions.queryItems),
            from: controller.value,
            options: .modal(embedInNav: true)
        )
    }

    func openPostPolicy(from controller: WeakViewController) {
        env.router.route(
            to: assignmentRoute + "/post_policy",
            from: controller,
            options: .modal(embedInNav: true)
        )
    }

    func didTapSubmissionRow(_ submission: SubmissionListItem, from controller: WeakViewController) {
        let query = filterMode == .all ? "" : "?filter=\(filterMode.filters.map { $0.rawValue }.joined(separator: ","))"
        env.router.route(
            to: assignmentRoute + "/submissions/\(submission.originalUserID)\(query)",
            from: controller.value,
            options: .modal(.fullScreen, isDismissable: false)
        )
    }
}

// MARK: - Utils

private extension User {
    func nameContains(_ text: String) -> Bool {
        let props = [name, shortName, sortableName].map { $0.lowercased() }
        return props.contains(where: { $0.contains(text.lowercased()) })
    }
}
