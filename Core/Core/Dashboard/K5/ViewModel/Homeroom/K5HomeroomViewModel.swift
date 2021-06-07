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

import SwiftUI

public class K5HomeroomViewModel: ObservableObject {
    @Published public private(set) var welcomeText = ""
    @Published public private(set) var announcements: [K5HomeroomAnnouncementViewModel] = []
    @Published public private(set) var subjectCards: [K5HomeroomSubjectCardViewModel] = []

    private let env = AppEnvironment.shared
    private lazy var cards = env.subscribe(GetDashboardCards()) { [weak self] in
        self?.dashboardCardsUpdated()
    }
    private lazy var profile = env.subscribe(GetUserProfile(userID: "self")) { [weak self] in
        self?.profileUpdated()
    }
    private var announcementsStore: Store<GetLatestAnnouncements>?
    private var refreshCompletion: (() -> Void)?
    private var forceRefresh = false

    public init() {
        cards.refresh()
        profile.refresh()
    }

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
        updateSubjectCardViewModels()
    }

    // MARK: - Subject Cards

    private func updateSubjectCardViewModels() {
        let nonHomeroomCards = cards.filter { $0.isHomeroom == false }
        subjectCards = nonHomeroomCards.map { card in
            let announcement = announcementsStore?.first { $0.contextCode == Core.Context(.course, id: card.id).canvasContextID }
            var infoLines: [K5HomeroomSubjectCardViewModel.InfoLine] = []

            if let announcementInfoLine = K5HomeroomSubjectCardViewModel.InfoLine.make(from: announcement) {
                infoLines.append(announcementInfoLine)
            }

            // FIXME: ContextColor change
            return K5HomeroomSubjectCardViewModel(courseId: card.id, imageURL: card.imageURL, name: card.shortName, color: card.contextColor?.color, infoLines: infoLines)
        }
    }

    // MARK: - Announcements

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

        performUIUpdate {
            self.finishRefresh()
            self.announcements = announcementModels
        }
    }

    private func card(for announcement: LatestAnnouncement) -> DashboardCard? {
        cards.first {
            announcement.contextCode == Core.Context(.course, id: $0.id).canvasContextID
        }
    }

    private func finishRefresh() {
        forceRefresh = false
        performUIUpdate {
            self.refreshCompletion?()
            self.refreshCompletion = nil
        }
    }
}

extension K5HomeroomViewModel: Refreshable {

    public func refresh(completion: @escaping () -> Void) {
        forceRefresh = true
        refreshCompletion = completion
        announcementsStore = nil
        cards.refresh(force: true)
        profile.refresh(force: true)
    }
}
