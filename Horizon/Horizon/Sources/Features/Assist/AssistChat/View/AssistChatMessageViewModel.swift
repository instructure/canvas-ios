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

import Foundation
import HorizonUI
import SwiftUI

struct AssistChatMessageViewModel: Identifiable, Equatable {
    typealias OnFeedbackChange = (Bool?) -> Void
    typealias OnTap = () -> Void
    typealias OnTapChipOption = (AssistChipOption) -> Void
    typealias OnTapCitation = (AssistChatMessage.Citation) -> Void

    enum Style {
        case white
        case semitransparent
        case semitransparentDark
        case transparent
    }

    let id: String
    let content: String
    let style: Style
    let isLoading: Bool
    let chipOptions: [AssistChipOption]
    let onFeedbackChange: OnFeedbackChange?
    let onTap: OnTap?
    let onTapCitation: OnTapCitation?
    let onTapChipOption: OnTapChipOption?
    let citations: [AssistChatMessage.Citation]

    init(
        id: String = UUID().uuidString,
        content: String = "",
        style: Style = .white,
        isLoading: Bool = false,
        chipOptions: [AssistChipOption] = [],
        citations: [AssistChatMessage.Citation] = [],
        onFeedbackChange: OnFeedbackChange? = nil,
        onTapChipOption: OnTapChipOption? = nil,
        onTapCitation: OnTapCitation? = nil,
        onTap: OnTap? = nil
    ) {
        self.id = id
        self.content = content
        self.onFeedbackChange = onFeedbackChange
        self.style = style
        self.isLoading = isLoading
        self.chipOptions = chipOptions
        self.citations = citations
        self.onTapChipOption = onTapChipOption
        self.onTapCitation = onTapCitation
        self.onTap = onTap
    }

    /// For when it's just a loading spinner
    init() {
        self.id = UUID().uuidString
        self.isLoading = true
        self.content = ""
        self.onFeedbackChange = nil
        self.style = .transparent
        self.citations = []
        self.chipOptions = []
        self.onTapChipOption = nil
        self.onTapCitation = nil
        self.onTap = nil
    }

    static func == (lhs: AssistChatMessageViewModel, rhs: AssistChatMessageViewModel) -> Bool {
        return lhs.id == rhs.id
    }

    var alignment: Alignment {
        switch style {
        case .white, .semitransparentDark:
            return .trailing
        default:
            return .center
        }
    }

    var backgroundColor: Color {
        switch style {
        case .white:
            return .huiColors.surface.cardPrimary
        case .semitransparent:
            return .huiColors.surface.cardPrimary.opacity(0.1)
        case .semitransparentDark:
            return .huiColors.surface.trueBlack.opacity(0.1)
        case .transparent:
            return .clear
        }
    }

    var cornerRadius: CGFloat {
        switch style {
        case .transparent:
            return 0
        default:
            return HorizonUI.CornerRadius.level3.attributes.radius
        }
    }

    var foregroundColor: Color {
        switch style {
        case .white:
            return Color.huiColors.text.body
        default:
            return Color.huiColors.text.surfaceColored
        }
    }

    var maxWidth: CGFloat? {
        switch style {
        case .white, .semitransparentDark:
            return nil
        default:
            return .infinity
        }
    }

    var padding: CGFloat {
        switch style {
        case .transparent:
            return 0
        default:
            return .huiSpaces.space16
        }
    }
}
