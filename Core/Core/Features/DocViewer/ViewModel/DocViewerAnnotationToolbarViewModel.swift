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

import Combine
import SwiftUI

class DocViewerAnnotationToolbarViewModel: ObservableObject {
    enum State: Equatable, CaseIterable {
        case saving
        case saved
        case error

        var text: String {
            switch self {
            case .saving: String(localized: "Saving...", bundle: .core)
            case .saved: String(localized: "All annotations saved.", bundle: .core)
            case .error: String(localized: "Error Saving. Tap to retry.", bundle: .core)
            }
        }

        var foregroundColor: Color {
            switch self {
            case .saved: .textSuccess
            case .error: .textDanger
            default: .textDarkest
            }
        }

        var icon: Image {
            switch self {
            case .saving: .circleArrowUpLine
            case .saved: .checkSolid
            case .error: .xSolid
            }
        }

        var isEnabled: Bool {
            self == .error
        }
    }

    // MARK: - Outputs
    @Published private(set) var isOpen = true
    @Published var saveState: State = .saved
    public let uiAnimation = (
        duration: CGFloat(0.3),
        options: UIView.AnimationOptions.curveEaseInOut
    )
    public private(set) lazy var animation = Animation.easeInOut(duration: uiAnimation.duration)

    // MARK: - Inputs
    let didTapRetry = PassthroughSubject<Void, Never>()
    let didTapCloseToggle = PassthroughSubject<Void, Never>()

    // MARK: - Private
    private var subscriptions = Set<AnyCancellable>()

    init(state: State = .saved) {
        self.saveState = state
        toggleClosedState(on: didTapCloseToggle)
    }

    private func toggleClosedState(on publisher: PassthroughSubject<Void, Never>) {
        publisher
            .sink { [weak self, animation] in
                withAnimation(animation) {
                    self?.isOpen.toggle()
                }
            }
            .store(in: &subscriptions)
    }
}
