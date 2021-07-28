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

public class K5ScheduleEntryViewModel: ObservableObject {
    @Published public var leading: RowLeading

    public let icon: Image

    public let title: String
    public let subtitle: SubtitleViewModel?
    public let labels: [LabelViewModel]

    public let score: String?
    public let dueText: String

    private let checkboxChanged: ((_ isSelected: Bool) -> Void)?
    private let action: () -> Void

    public init(leading: RowLeading, icon: Image, title: String, subtitle: SubtitleViewModel?, labels: [LabelViewModel], score: String?, dueText: String,
                checkboxChanged: ((_ isSelected: Bool) -> Void)?,
                action: @escaping () -> Void) {
        self.leading = leading
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.labels = labels
        self.score = score
        self.dueText = dueText
        self.checkboxChanged = checkboxChanged
        self.action = action
    }

    public func checkboxTapped() {
        guard case RowLeading.checkbox(let isChecked) = leading else {
            return
        }

        leading = .checkbox(isChecked: !isChecked)
        checkboxChanged?(!isChecked)
    }

    public func actionTriggered() {
        action()
    }
}

extension K5ScheduleEntryViewModel {
    public enum RowLeading: Equatable {
        case checkbox(isChecked: Bool)
        case warning
    }

    public class LabelViewModel {
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
