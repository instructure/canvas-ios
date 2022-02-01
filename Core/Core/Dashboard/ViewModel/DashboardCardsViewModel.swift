//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

import Combine
import SwiftUI

class DashboardCardsViewModel: ObservableObject {
    public enum ViewModelState<T: Equatable>: Equatable {
        case loading
        case empty
        case data(T)
        case error(String)
    }

    @Published public private(set) var state = ViewModelState<[DashboardCard]>.loading
    private let env = AppEnvironment.shared
    private lazy var cards: Store<GetDashboardCards> = env.subscribe(GetDashboardCards()) { [weak self] in
        self?.update()
    }
    /**
     We need to observe courses because those contain the enrollment state of the dashboard card. Since courses get refreshed from
     ``DashboardInvitationsViewModel`` in ``DashboardCardView`` we just subscribe to the changes but don't request them here from the API. */
    private lazy var courses: Store<LocalUseCase<Course>> = env.subscribe(scope: .all(orderBy: #keyPath(Course.id))) { [weak self] in
        self?.update()
    }
    private let showOnlyTeacherEnrollment: Bool
    private var needsRefresh = false
    private var subscriptions = Set<AnyCancellable>()
    private var enrollmentsRequest: APITask?
    /** This dictionary contains the user's section IDs within courses referenced by their IDs. */
    private var sectionIDsByCourseIDs: [String: String] = [:]

    public init(showOnlyTeacherEnrollment: Bool) {
        self.showOnlyTeacherEnrollment = showOnlyTeacherEnrollment
        courses.refresh() // we just refresh to create the lazy variable
        NotificationCenter.default.publisher(for: .favoritesDidChange)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.favoritesDidChange() }
            .store(in: &subscriptions)
    }

    public func refresh(onComplete: (() -> Void)? = nil) {
        needsRefresh = false
        cards.refresh(force: true) { [weak self] _ in
            onComplete?()

            guard let self = self else { return }
            if self.needsRefresh { self.refresh() }
        }

        refreshEnrollments()
    }

    private func refreshEnrollments() {
        guard enrollmentsRequest == nil else { return }

        let request = GetEnrollmentsRequest(context: .currentUser, types: [Role.student.rawValue], states: [.active])
        enrollmentsRequest = env.api.makeRequest(request) { [weak self] enrollments, _, _ in
            performUIUpdate {
                self?.enrollmentsRequest = nil
                self?.extractSectionInfo(from: enrollments ?? [])
                self?.update()
            }
        }
    }

    private func extractSectionInfo(from enrollments: [APIEnrollment]) {
        sectionIDsByCourseIDs = enrollments.reduce(into: [:]) { dictionary, enrollment in
            guard let courseId = enrollment.course_id?.value, let sectionId = enrollment.course_section_id?.value else {
                return
            }
            dictionary[courseId] = sectionId
        }
    }

    private func favoritesDidChange() {
        if cards.pending {
            needsRefresh = true
        } else {
            refresh()
        }
    }

    private func update() {
        guard cards.requested, !cards.pending, enrollmentsRequest == nil else { return }

        guard cards.state != .error else {
            state = .error(cards.error?.localizedDescription ?? "")
            return
        }

        let cards = filteredCards()
        state = cards.isEmpty ? .empty : .data(cards)
    }

    private func filteredCards() -> [DashboardCard] {
        var filteredCards = cards.all.filter { $0.shouldShow && isSectionActive(for: $0) }

        if showOnlyTeacherEnrollment {
            filteredCards = filteredCards.filter { $0.isTeacherEnrollment }
        }

        return filteredCards
    }

    private func isSectionActive(for card: DashboardCard) -> Bool {
        let courseId = card.id

        guard let sectionId = sectionIDsByCourseIDs[courseId],
              let course = courses.all.first(where: { $0.id == courseId }),
              let section = course.sections.first(where: { $0.id == sectionId }),
              let sectionEndDate = section.endAt
        else { return true }

        return Clock.now < sectionEndDate
    }
}
