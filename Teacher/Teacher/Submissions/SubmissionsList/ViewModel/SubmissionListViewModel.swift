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

    let screenConfig = InstUI.BaseScreenConfig(refreshable: false)
    @Published private(set) var state: InstUI.ScreenState = .loading

    @Published var searchText: String = ""
    @Published var statusFilters: Set<SubmissionStatusFilter>
    @Published var sectionFilters: Set<String>
    @Published var differentiationTagFilters: Set<String>
    @Published var sortMode: SubmissionsSortMode = .studentSortableName
    @Published var scoreBasedFilters: Set<GetSubmissions.Filter.Score> = []

    @Published var assignment: Assignment?
    @Published var course: Course?
    @Published var courseSections: [CourseSection] = []
    @Published var sections: [SubmissionListSection] = []
    @Published var differentiationTags: [CDUserGroup] = []

    let interactor: SubmissionListInteractor
    private let scheduler: AnySchedulerOf<DispatchQueue>
    private let env: AppEnvironment
    private let differentiationTagsSortComparator: (CDUserGroup, CDUserGroup) -> Bool
    private var subscriptions = Set<AnyCancellable>()

    init(
        interactor: SubmissionListInteractor,
        filter: GetSubmissions.Filter?,
        env: AppEnvironment,
        scheduler: AnySchedulerOf<DispatchQueue> = .main,
        differentiationTagsSortComparator: @escaping (CDUserGroup, CDUserGroup) -> Bool = DifferentiationTagsSortStrategy.sort
    ) {
        self.interactor = interactor
        self.statusFilters = Set(filter?.statuses ?? [])
        self.sectionFilters = Set(filter?.sections.map(\.sectionID) ?? [])
        self.differentiationTagFilters = Set(filter?.differentiationTags.map(\.tagID) ?? [])
        self.env = env
        self.scheduler = scheduler
        self.differentiationTagsSortComparator = differentiationTagsSortComparator

        setupBindings()
    }

    // MARK: Privates

    private func setupBindings() {
        interactor.assignment.assign(to: &$assignment)
        interactor.course.assign(to: &$course)
        interactor.courseSections.assign(to: &$courseSections)
        interactor.differentiationTags
            .map { [differentiationTagsSortComparator] tags in
                tags.sorted(by: differentiationTagsSortComparator)
            }
            .assign(to: &$differentiationTags)

        if statusFilters.isEmpty {
            self.statusFilters = Set(SubmissionStatusFilter.allCasesForCourse(interactor.context.id))
        }

        $courseSections
            .filter({ $0.isNotEmpty })
            .first()
            .sink { [weak self] loadedSections in
                guard let self else { return }

                if sectionFilters.isEmpty {
                    sectionFilters = Set(loadedSections.map(\.id))
                }
            }
            .store(in: &subscriptions)

        Publishers.CombineLatest3(
            interactor.submissions.receive(on: scheduler),
            interactor.assigneeGroups.receive(on: scheduler),
            $searchText.throttle(for: 1, scheduler: scheduler, latest: true)
        )
        .map({ [weak self] (list, groups, searchText) in
            let searchTerm = searchText.lowercased()
            var curatedList: [Submission] = list

            if groups.isNotEmpty {
                curatedList.forEach { submission in
                    if submission.groupID == nil,
                       let foundGroup = groups.first(where: { $0.containsUser(submission.userID) }) {
                        submission.fetchedGroup = foundGroup.asSubmissionFetchedGroup
                    }
                }
            }

            if searchTerm.isNotEmpty {
                curatedList = curatedList.filter { $0.user?.nameContains(searchTerm) ?? false }
            }

            return curatedList.toSectionedItems(assignment: self?.assignment)
        })
        .assign(to: &$sections)

        interactor
            .submissions
            .receive(on: scheduler)
            .map({ $0.isEmpty ? .empty : .data })
            .assign(to: &$state)

        Publishers
            .CombineLatest4($statusFilters, $scoreBasedFilters, $sectionFilters, $differentiationTagFilters)
            .combineLatest($sortMode)
            .sink { [weak self] _ in
                guard let self else { return }
                interactor.applyPreference(selectedPreference)
            }
            .store(in: &subscriptions)
    }

    private var assignmentRoute: String {
        "/\(interactor.context.pathComponent)/assignments/\(interactor.assignmentID)"
    }

    // MARK: Exposed To View

    var isFilterActive: Bool {
        if !hasStatusesFilterDefaultSelection { return true }
        if !hasSectionsFilterDefaultSelection { return true }
        if hasDifferentiationTagFilter { return true}
        return false
    }

    private var hasStatusesFilterDefaultSelection: Bool {
        statusFilters.isEmpty || statusFilters.isAllCasesForCourseIncluded(interactor.context.id)
    }

    private var hasSectionsFilterDefaultSelection: Bool {
        let defaultSectionsList = Set(courseSections.map(\.id))
        return sectionFilters.isEmpty || sectionFilters == defaultSectionsList
    }

    private var hasDifferentiationTagFilter: Bool {
	    differentiationTagFilters.isNotEmpty && differentiationTagFilters.count < differentiationTags.count
    }

    private var selectedPreference: SubmissionListPreference {
        SubmissionListPreference(
            filter: SubmissionsFilter(
                statuses: hasStatusesFilterDefaultSelection ? [] : statusFilters,
                score: scoreBasedFilters,
                sections: hasSectionsFilterDefaultSelection ? [] : sectionFilters,
                differentiationTags: hasDifferentiationTagFilter ? differentiationTagFilters : []
            ).nilIfEmpty,
            sortMode: sortMode
        )
    }

    func refresh(_ completion: @escaping () -> Void) {
        interactor
            .refresh()
            .receive(on: scheduler)
            .sink {
                completion()
            }
            .store(in: &self.subscriptions)
    }

    func messageUsers(from controller: WeakViewController) {
        guard let subject = assignment?.name else { return }

        let recipients = sections
            .flatMap { section in
                section.items.compactMap { $0.userAsRecipient }
            }

        let recipientContext = RecipientContext(
            name: course?.name ?? "",
            context: interactor.context
        )

        let composeMessageOptions = ComposeMessageOptions(
            disabledFields: .init(
                contextDisabled: true,
                individualDisabled: true
            ),
            fieldsContents: .init(
                selectedContext: recipientContext,
                selectedRecipients: recipients,
                subjectText: subject,
                individualSend: true
            )
        )

        var composeURL = URLComponents()
        composeURL.host = env.apiHost
        composeURL.path = "/conversations/compose"
        composeURL.queryItems = composeMessageOptions.queryItems

        env.router.route(
            to: composeURL,
            from: controller.value,
            options: .modal(embedInNav: true)
        )
    }

    func openPostPolicy(from controller: WeakViewController) {
        env.router.route(
            to: assignmentRoute + "/post_policy",
            from: controller,
            options: .modal(embedInNav: true, addDoneButton: true)
        )
    }

    func showFilterScreen(from controller: WeakViewController) {
        let filterVC = CoreHostingController(
            SubmissionsFilterScreen(listViewModel: self),
            env: env
        )
        env.router.show(filterVC, from: controller, options: .modal(embedInNav: true))
    }

    func didTapSubmissionRow(_ submission: SubmissionListItem, from controller: WeakViewController) {
        let queryItems = selectedPreference.query
        env.router.route(
            to: (assignmentRoute + "/submissions/\(submission.originalUserID)").asURLPathWithQuery(queryItems),
            from: controller.value,
            options: .modal(.fullScreen, isDismissable: false, embedInNav: true)
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
