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

/**
 One to-do item in the schedule list.
 */
public class K5ScheduleEntryViewModel: ObservableObject, Identifiable {
    @Published public var leading: RowLeading

    public let icon: Image

    public let title: String
    @Published public private(set) var subtitle: SubtitleViewModel?
    public let labels: [LabelViewModel]

    public let score: String?
    public let dueText: String

    public var isTappable: Bool { route != nil }
    private let route: URL?
    private let apiService: PlannerOverrideUpdater?

    public init(leading: RowLeading,
                icon: Image,
                title: String,
                subtitle: SubtitleViewModel?,
                labels: [LabelViewModel],
                score: String?,
                dueText: String,
                route: URL?,
                apiService: PlannerOverrideUpdater? = nil) {
        self.leading = leading
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.labels = labels
        self.score = score
        self.dueText = dueText
        self.route = route
        self.apiService = apiService
        updateSubtitle()
    }

    public func checkboxTapped() {
        guard case .checkbox(let isChecked) = leading else {
            return
        }

        let newState = !isChecked
        leading = .checkbox(isChecked: newState)
        updateSubtitle()

        apiService?.markAsComplete(isComplete: newState) { [weak self] succeeded in
            if !succeeded {
                // Update failed, revert UI to original state
                performUIUpdate {
                    self?.leading = .checkbox(isChecked: isChecked)
                    self?.updateSubtitle()
                }
            }
        }
    }

    public func itemTapped(router: Router, viewController: WeakViewController) {
        guard let route = route else { return }
        // Any non-modal routing will put the view into the master view of the split view so we use modal to work this around
        router.route(to: route, from: viewController, options: .modal(isDismissable: false, embedInNav: true, addDoneButton: true))
    }

    private func updateSubtitle() {
        guard case .checkbox(let isChecked) = leading else { return }
        subtitle = isChecked ? SubtitleViewModel(text: String(localized: "You've marked it as done.", bundle: .core), color: .textDark, font: .regular12) : nil
    }
}

extension K5ScheduleEntryViewModel {
    public enum RowLeading: Equatable {
        case checkbox(isChecked: Bool)
        case warning
    }

    public class LabelViewModel: Identifiable {
        public let text: String
        public let color: Color

        public init(text: String, color: Color) {
            self.text = text
            self.color = color
        }
    }

    public class SubtitleViewModel: LabelViewModel {
        public let font: Font

        public init(text: String, color: Color, font: Font) {
            self.font = font
            super.init(text: text, color: color)
        }
    }
}
