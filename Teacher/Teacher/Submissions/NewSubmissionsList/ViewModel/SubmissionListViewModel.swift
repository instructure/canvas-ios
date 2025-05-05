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

class SubmissionListViewModel: ObservableObject {

    enum ViewState: Equatable {
        case loading
        case data
        case empty
        case error
    }

    @Published private(set) var state: ViewState = .loading

    @Published var searchText: String = ""
    @Published var filterMode: SubmissionFilterMode = .all

    @Published var assignment: Assignment?
    @Published var course: Course?
    @Published var sections: [SubmissionSection] = []

    private let interactor: SubmissionListInteractor
    private let env: AppEnvironment
    private var subscriptions = Set<AnyCancellable>()

    init(interactor: SubmissionListInteractor, env: AppEnvironment) {
        self.interactor = interactor
        self.env = env
        setupBindings()
    }

    // MARK: Privates

    private func setupBindings() {
        interactor.assignment.assign(to: &$assignment)
        interactor.course.assign(to: &$course)

        Publishers.CombineLatest(
            interactor.submissions,
            $searchText.debounce(for: 0.5, scheduler: DispatchQueue.main),
        )
        .receive(on: DispatchQueue.main)
        .map({ (list, searchText) in

            let searchTerm = searchText.lowercased()
            let filtered = searchTerm.isNotEmpty ? list.filter { $0.user?.nameContains(searchTerm) ?? false } : list

            let submitted = filtered.filter { $0.workflowState == .submitted }
            let unsubmitted = filtered.filter { $0.workflowState == .unsubmitted }
            let graded = filtered.filter { $0.isGraded }

            return [
                SubmissionSection(title: "Submitted", submissions: submitted),
                SubmissionSection(title: "Not Submitted", submissions: unsubmitted),
                SubmissionSection(title: "Graded", submissions: graded)
            ]
            .filter({ $0.rows.isNotEmpty })
        })
        .assign(to: &$sections)

        interactor
            .submissions
            .receive(on: DispatchQueue.main)
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
                .receive(on: DispatchQueue.main)
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
                section.rows.compactMap { $0.submission.user }
            }
            .map { Recipient(id: $0.id, name: $0.name, avatarURL: $0.avatarURL) }

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

    func didTapSubmissionRow(_ submission: Submission, from controller: WeakViewController) {
        let query = filterMode == .all ? "" : "?filter=\(filterMode.filters.map { $0.rawValue }.joined(separator: ","))"
        env.router.route(
            to: assignmentRoute + "/submissions/\(submission.userID)\(query)",
            from: controller.value,
            options: .modal(.fullScreen, isDismissable: false)
        )
    }
}

// MARK: - Section Model

struct SubmissionSection: Identifiable {
    struct Row: Identifiable {
        let index: Int
        let submission: Submission

        var id: Int { index }
    }

    let title: String
    var rows: [Row]
    var isCollapsed: Bool

    var id: String { title }

    init(title: String, submissions: [Submission], isCollapsed: Bool = false) {
        self.title = title
        self.rows = submissions
            .enumerated()
            .map({ Row(index: $0.offset, submission: $0.element) })
        self.isCollapsed = isCollapsed
    }
}

extension User {

    func nameContains(_ text: String) -> Bool {
        let props = [name, shortName, sortableName].map { $0.lowercased() }
        return props.contains(where: { $0.contains(text.lowercased()) })
    }
}
