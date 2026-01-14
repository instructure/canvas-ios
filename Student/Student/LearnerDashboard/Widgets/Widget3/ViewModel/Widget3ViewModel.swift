//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

@Observable
final class Widget3ViewModel: LearnerWidgetViewModel {
    typealias ViewType = Widget3View

    let config: WidgetConfig
    var id: LearnerDashboardWidgetIdentifier { config.id }
    let isFullWidth = false
    let isEditable = false
    var state: InstUI.ScreenState = .data
    private var subscriptions = Set<AnyCancellable>()

    init(config: WidgetConfig) {
        self.config = config
    }

    func makeView() -> Widget3View {
        Widget3View(viewModel: self)
    }

    func refresh() {
        state = .loading
        refresh(ignoreCache: true)
            .sink()
            .store(in: &subscriptions)
    }

    func refresh(ignoreCache: Bool) -> AnyPublisher<Void, Never> {
        Just(())
            .delay(for: 2, scheduler: RunLoop.main)
            .map { [weak self] in
                self?.state = .error
            }
            .eraseToAnyPublisher()
    }
}
