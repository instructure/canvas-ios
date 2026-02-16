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

import Combine
import Core
import SwiftUI
import UIKit

@Observable
final class GlobalAnnouncementDetailsViewModel {

    let id: String
    let title: String
    let date: String?
    let message: String
    let baseUrl: URL?

    private let interactor: GlobalAnnouncementsWidgetInteractor
    private let router: Router

    private var subscriptions = Set<AnyCancellable>()

    init(
        item: GlobalAnnouncementsWidgetItem,
        interactor: GlobalAnnouncementsWidgetInteractor,
        environment: AppEnvironment
    ) {
        self.id = item.id
        self.title = item.title
        self.date = item.startDate?.dateTimeString
        self.message = item.message
        self.baseUrl = environment.currentSession?.baseURL

        self.interactor = interactor
        self.router = environment.router
    }

    func didTapDelete(from controller: WeakViewController) {
        interactor.deleteAnnouncement(id: id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.router.dismiss(controller)
            }
            .store(in: &subscriptions)
    }
}
