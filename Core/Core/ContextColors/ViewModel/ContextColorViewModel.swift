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

public class ContextColorViewModel: ObservableObject {
    @Published public private(set) var color: UIColor = UIColor.defaultContextColor

    private let interactor: ContextColorsInteractor
    private let context: Context
    private let callback: ((UIColor) -> Void)?
    private var subscriptions = Set<AnyCancellable>()

    public init(
        _ context: Context,
        interactor: ContextColorsInteractor = ContextColorsInteractorLive(),
        callback: ((UIColor) -> Void)? = nil
    ) {
        self.interactor = interactor
        self.context = context
        self.callback = callback
        
        interactor
            .observeContextColor(context)
            .sink { [weak self] color in
                self?.color = color
                self?.callback?(color)
            }
            .store(in: &subscriptions)
    }

    public func refresh() {
        interactor
            .refresh()
            .sink()
            .store(in: &subscriptions)
    }
}
