//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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
import Foundation
import SwiftUI

@Observable
final class GlobalAnnouncementCardViewModel: Identifiable, Equatable {

    let title: String
    let iconType: AccountNotificationIcon
    let date: String?
    let a11yLabel: String

    // Including the whole model to ensure any change triggers a view update.
    // Using only `model.id` would make the ForEach ignore a title change upon a refresh.
    var id: GlobalAnnouncementsWidgetItem { model }

    private let model: GlobalAnnouncementsWidgetItem
    private let router: Router
    private let onCardTap: (WeakViewController) -> Void

    init(
        model: GlobalAnnouncementsWidgetItem,
        router: Router,
        onCardTap: @escaping (WeakViewController) -> Void
    ) {
        self.model = model

        self.title = model.title
        self.iconType = model.icon
        self.date = model.startDate?.dateTimeString

        self.a11yLabel = [
            String(localized: "Global Announcement", bundle: .student),
            iconType.a11yLabel,
            date,
            title
        ].accessibilityJoined()

        self.router = router
        self.onCardTap = onCardTap
    }

    func didTapCard(from controller: WeakViewController) {
        onCardTap(controller)
    }

    static func == (lhs: GlobalAnnouncementCardViewModel, rhs: GlobalAnnouncementCardViewModel) -> Bool {
        lhs.model == rhs.model
    }
}

private extension AccountNotificationIcon {
    var a11yLabel: String {
        switch self {
        case .calendar: String(localized: "Calendar", bundle: .student)
        case .information: String(localized: "Information", bundle: .student)
        case .question: String(localized: "Question", bundle: .student)
        case .warning: String(localized: "Warning", bundle: .student)
        case .error: String(localized: "Error", bundle: .student)
        }
    }
}
