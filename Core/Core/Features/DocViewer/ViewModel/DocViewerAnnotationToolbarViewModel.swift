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

    // MARK: - Outputs

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

        var isTapToRetryActionEnabled: Bool {
            self == .error
        }
    }

    @Published private(set) var isOpen: Bool
    @Published var saveState: State = .saved
    var a11yValue: String {
        isOpen ? String(localized: "Open", bundle: .core)
               : String(localized: "Closed", bundle: .core)
    }
    var a11yHint: String {
        isOpen ? String(localized: "Double tap to close toolbar", bundle: .core)
               : String(localized: "Double tap to open toolbar", bundle: .core)
    }
    let uiAnimation = (
        duration: CGFloat(0.3),
        options: UIView.AnimationOptions.curveEaseInOut
    )
    private(set) lazy var animation = Animation.easeInOut(duration: uiAnimation.duration)

    // MARK: - Inputs

    var annotationProvider: DocViewerAnnotationProvider?
    let didTapRetry = PassthroughSubject<Void, Never>()
    let didTapCloseToggle = PassthroughSubject<Void, Never>()

    // MARK: - Private

    private var subscriptions = Set<AnyCancellable>()
    private var userDefaults: SessionDefaults?

    init(
        state: State = .saved,
        userDefaults: SessionDefaults? = AppEnvironment.shared.userDefaults
    ) {
        self.saveState = state
        self.isOpen = userDefaults?.isSpeedGraderAnnotationToolbarVisible ?? true
        self.userDefaults = userDefaults
        toggleClosedState(on: didTapCloseToggle)
        retryAnnotationUpload(on: didTapRetry)
    }

    private func toggleClosedState(on publisher: PassthroughSubject<Void, Never>) {
        publisher
            .sink { [weak self, animation] in
                guard let self else { return }
                self.userDefaults?.isSpeedGraderAnnotationToolbarVisible = !self.isOpen

                withAnimation(animation) {
                    self.isOpen.toggle()
                }
            }
            .store(in: &subscriptions)
    }

    private func retryAnnotationUpload(on publisher: PassthroughSubject<Void, Never>) {
        publisher
            .sink { [weak self] in
                self?.annotationProvider?.retryFailedRequest()
            }
            .store(in: &subscriptions)
    }
}
