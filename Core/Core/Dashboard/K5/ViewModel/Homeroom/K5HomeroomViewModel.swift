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

class K5HomeroomViewModel: ObservableObject {
    @Published private(set) var announcements: [K5HomeroomAnnouncementViewModel] = []

    private let env = AppEnvironment.shared
    private lazy var cards = env.subscribe(GetDashboardCards()) { [weak self] in
        self?.dashboardCardsUpdated()
    }
    private var refreshCompletion: (() -> Void)?

    public init() {
        cards.refresh()
    }

    private func dashboardCardsUpdated() {
        guard cards.requested, !cards.pending else {
            return
        }

        requestAnnouncements()
    }

    private func requestAnnouncements() {
        let courseContextCodes = cards.map { Core.Context(.course, id: $0.id).canvasContextID }
        env.api.makeRequest(GetAllAnnouncementsRequest(contextCodes: courseContextCodes, activeOnly: true)) { [weak self] announcements, _, _ in
            guard let announcements = announcements else {
                self?.finishRefresh()
                return
            }
            self?.updateAnnouncementViewModels(from: announcements)
        }
    }

    private func card(for announcement: APIDiscussionTopic) -> DashboardCard? {
        cards.first {
            announcement.context_code == Core.Context(.course, id: $0.id).canvasContextID
        }
    }

    private func updateAnnouncementViewModels(from announcements: [APIDiscussionTopic]) {
        let homeroomAnnouncements = announcements.filter { card(for: $0)?.isHomeroom == true }
        let announcementModels: [K5HomeroomAnnouncementViewModel] = homeroomAnnouncements.compactMap {
            guard let message = $0.message, let card = card(for: $0) else { return nil }
            return K5HomeroomAnnouncementViewModel(courseName: card.shortName, title: $0.title ?? NSLocalizedString("Announcement", comment: ""), htmlContent: message, allAnnouncementsRoute: "/courses/\(card.id)/announcements")
        }

        performUIUpdate {
            self.finishRefresh()
            self.announcements = announcementModels
        }
    }

    private func finishRefresh() {
        performUIUpdate {
            self.refreshCompletion?()
            self.refreshCompletion = nil
        }
    }
}

extension K5HomeroomViewModel: Refreshable {

    func refresh(completion: @escaping () -> Void) {
        refreshCompletion = completion
        cards.refresh(force: true)
    }
}
