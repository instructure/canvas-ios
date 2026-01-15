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
final class Widget1ViewModel: LearnerWidgetViewModel {
    typealias ViewType = Widget1View

    var text = WidgetPlaceholderData.long(1)
    let config: WidgetConfig
    var id: LearnerDashboardWidgetIdentifier { config.id }
    let isFullWidth = false
    let isEditable = false
    var state: InstUI.ScreenState = .loading

    var layoutIdentifier: AnyHashable {
        struct Identifier: Hashable {
            let state: InstUI.ScreenState
            let textCount: Int
        }
        return AnyHashable(Identifier(state: state, textCount: text.count))
    }

    private var timerCancellable: AnyCancellable?

    init(config: WidgetConfig) {
        self.config = config
        startTextTimer()
    }

    private func startTextTimer() {
        timerCancellable = Timer.publish(every: 2, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                var newText: String
                repeat {
                    newText = WidgetPlaceholderData.long(Int.random(in: 1...4))
                } while newText.count == self.text.count
                self.text = newText
            }
    }

    func makeView() -> Widget1View {
        Widget1View(viewModel: self)
    }

    func refresh(ignoreCache: Bool) -> AnyPublisher<Void, Never> {
        Just(())
            .delay(for: 3, scheduler: RunLoop.main)
            .map { [weak self] in
                self?.state = .data
                return ()
            }
            .eraseToAnyPublisher()
    }
}
