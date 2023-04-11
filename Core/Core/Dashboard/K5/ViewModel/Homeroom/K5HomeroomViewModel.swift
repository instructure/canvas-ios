//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

public class K5HomeroomViewModel: ObservableObject {
    // MARK: - Public Reactive Properties -
    @Published public private(set) var welcomeText = ""
    @Published public private(set) var announcements: [K5HomeroomAnnouncementViewModel] = []
    @Published public private(set) var subjectCards: [K5HomeroomSubjectCardViewModel] = []
    @Published public private(set) var conferencesViewModel = DashboardConferencesViewModel()
    @Published public private(set) var invitationsViewModel = DashboardInvitationsViewModel()
    @Published public private(set) var accountAnnouncements: [AccountNotification] = []

    // MARK: - Private Variables -
    private let env = AppEnvironment.shared
    private var childViewModelChangeListener: AnyCancellable?
    // MARK: Data Sources
    private lazy var cards = env.subscribe(GetDashboardCards(showOnlyTeacherEnrollment: false)) { [weak self] in
        self?.dashboardCardsUpdated()
    }
    private lazy var profile = env.subscribe(GetUserProfile(userID: "self")) { [weak self] in
        self?.profileUpdated()
    }
    private lazy var accountAnnouncementsStore = env.subscribe(GetAccountNotifications()) { [weak self] in
        self?.accountAnnouncementsUpdated()
    }
    private var announcementsStore: Store<GetLatestAnnouncements>?
    private var dueItems: Store<GetK5HomeroomDueItemCount>?
    private var missingSubmissions: Store<GetK5HomeroomMissingSubmissionsCount>?
    // MARK: Refresh
    private var refreshCompletion: (() -> Void)?
    private var forceRefresh = false

    // MARK: - Public Interface -

    public init() {
        // Propagate changes of the underlying view model to this observable class because there's no native support for nested ObservableObjects
        childViewModelChangeListener = conferencesViewModel.objectWillChange.merge(with: invitationsViewModel.objectWillChange).sink { [weak self] _ in
            self?.objectWillChange.send()
        }

        cards.refresh()
        profile.refresh()
        accountAnnouncementsStore.exhaust()
        conferencesViewModel.refresh()
        invitationsViewModel.refresh()
    }

    // MARK: - Private Methods -

    private func profileUpdated() {
        let newWelcomeText: String

        if let userName = profile.first?.name {
            newWelcomeText = NSLocalizedString("Welcome, \(userName)!", comment: "Welcome, username!")
        } else {
            newWelcomeText = NSLocalizedString("Welcome!", comment: "")
        }

        if newWelcomeText != welcomeText {
            welcomeText = newWelcomeText
        }
    }

    private func dashboardCardsUpdated() {
        guard cards.requested, !cards.pending else { return }
        requestAnnouncements()
        requestItemsDueToday()
    }

    private func accountAnnouncementsUpdated() {
        guard accountAnnouncementsStore.requested, !accountAnnouncementsStore.pending else { return }
        accountAnnouncements = accountAnnouncementsStore.all
    }

    // MARK: Subject Cards

    private func requestItemsDueToday() {
        if dueItems != nil { return }

        let nonHomeroomCardIds = cards.filter { $0.isHomeroom == false }.map { $0.id }
        dueItems = env.subscribe(GetK5HomeroomDueItemCount(courseIds: nonHomeroomCardIds)) { [weak self] in
            guard let self = self, self.dueItems?.state != .loading else { return }
            self.requestMissingSubmissionsCount()
        }

        dueItems?.refresh(force: forceRefresh)
    }

    private func requestMissingSubmissionsCount() {
        if missingSubmissions != nil { return }

        let nonHomeroomCardIds = cards.filter { $0.isHomeroom == false }.map { $0.id }
        missingSubmissions = env.subscribe(GetK5HomeroomMissingSubmissionsCount(courseIds: nonHomeroomCardIds)) { [weak self] in
            guard let self = self, self.missingSubmissions?.state != .loading else { return }
            self.updateSubjectCardViewModels()
        }

        missingSubmissions?.exhaust(force: forceRefresh)
    }

    private func updateSubjectCardViewModels() {
        let nonHomeroomCards = cards.filter { $0.isHomeroom == false }
        subjectCards = nonHomeroomCards.compactMap { card in
            guard card.shouldShow else { return nil }
            let announcement = announcementsStore?.first { $0.contextCode == Core.Context(.course, id: card.id).canvasContextID }
            var infoLines: [K5HomeroomSubjectCardViewModel.InfoLine] = [.make(dueToday: numberOfDueTodayItems(for: card.id), missing: numberOfMissingItems(for: card.id), courseId: card.id)]

            if let announcementInfoLine = K5HomeroomSubjectCardViewModel.InfoLine.make(from: announcement, courseId: card.id) {
                infoLines.append(announcementInfoLine)
            }
            return K5HomeroomSubjectCardViewModel(courseId: card.id, imageURL: card.imageURL, name: card.shortName, color: UIColor(hexString: card.k5Color), infoLines: infoLines)
        }

        finishRefresh()
    }

    private func numberOfDueTodayItems(for courseId: String) -> Int {
        let plannerItem = dueItems?.first { $0.courseId == courseId }

        if let due = plannerItem?.due {
            return Int(due)
        } else {
            return 0
        }
    }

    private func numberOfMissingItems(for courseId: String) -> Int {
        let missingSubmission = missingSubmissions?.first { $0.courseId == courseId }

        if let due = missingSubmission?.missing {
            return Int(due)
        } else {
            return 0
        }
    }

    // MARK: Announcements

    private func requestAnnouncements() {
        if announcementsStore != nil { return }

        let courseIds = cards.map { $0.id }
        announcementsStore = env.subscribe(GetLatestAnnouncements(courseIds: courseIds)) { [weak self] in
            self?.updateAnnouncementViewModels()
        }
        announcementsStore?.refresh(force: forceRefresh)
    }

    private func updateAnnouncementViewModels() {
        let homeroomAnnouncements = announcementsStore?.filter { card(for: $0)?.isHomeroom == true } ?? []
        let announcementModels: [K5HomeroomAnnouncementViewModel] = homeroomAnnouncements.compactMap {
            guard let card = card(for: $0) else { return nil }
            return K5HomeroomAnnouncementViewModel(courseName: card.shortName, title: $0.title, htmlContent: $0.message, allAnnouncementsRoute: "/courses/\(card.id)/announcements")
        }

        announcements = announcementModels
    }

    // MARK: Misc

    private func card(for announcement: LatestAnnouncement) -> DashboardCard? {
        cards.first { announcement.contextCode == Core.Context(.course, id: $0.id).canvasContextID }
    }

    private func finishRefresh() {
        forceRefresh = false
        performUIUpdate {
            self.refreshCompletion?()
            self.refreshCompletion = nil
        }
    }
}

// MARK: - Refresh Trigger -

extension K5HomeroomViewModel: Refreshable {

    @available(*, renamed: "refresh()")
    public func refresh(completion: @escaping () -> Void) {
        Task {
            await refresh()
            completion()
        }
    }

    public func refresh() async {
        forceRefresh = true
        return await withCheckedContinuation { continuation in
            refreshCompletion = {
                continuation.resume()
            }
            announcementsStore = nil
            missingSubmissions = nil
            dueItems = nil
            cards.refresh(force: true)
            profile.refresh(force: true)
            accountAnnouncementsStore.exhaust(force: true)
            conferencesViewModel.refresh(force: true)
            invitationsViewModel.refresh()
        }
    }
}
