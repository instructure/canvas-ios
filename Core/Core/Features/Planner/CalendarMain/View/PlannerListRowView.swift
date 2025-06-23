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

import SwiftUI

struct PlannerListRowView: View {
    let item: Plannable

    var body: some View {
        HStack(alignment: .top) {
            tintedIcon
            VStack(alignment: .leading) {
                courseCodeText.style(.textCellTopLabel)
                Text(item.title ?? "").style(.textCellTitle)
                Text(item.dueDateText ?? "").style(.textCellSupportingText)
                if let pointsText = item.pointsText {
                    Text(pointsText).style(.textCellSupportingText)
                }
            }
        }
        .listRowBackground(Color.backgroundLightest)
        .listItemTint(itemTint)
        .alignmentGuide(.listRowSeparatorLeading, computeValue: { _ in 0 })
    }

    private var itemTint: ListItemTint? {
        guard let color = item.customColor else { return nil }
        return .preferred(Color(uiColor: color))
    }

    @ViewBuilder
    private var tintedIcon: some View {
        if let color = item.customColor {
            item.iconImage.foregroundStyle(Color(uiColor: color))
        } else {
            item.iconImage
        }
    }

    @ViewBuilder
    private var courseCodeText: some View {
        let name = item.contextNameUserFacing ?? ""
        if let color = item.customColor {
            Text(name).foregroundStyle(Color(uiColor: color))
        } else {
            Text(name)
        }
    }
}

extension Plannable {

    var rowAccessibilityID: String? {
        return "PlannerList.event.\(id)"
    }

    var customColor: UIColor? {
        return AppEnvironment.shared.app == .parent ? nil : color.ensureContrast(against: .backgroundLightest)
    }

    var dueDateText: String? {
        guard let date else { return nil }
        return DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .short)
    }

    var pointsText: String? {
        guard let pointsPossible else { return nil }
        let format = String(localized: "g_points", bundle: .core)
        return String.localizedStringWithFormat(format, pointsPossible)
    }

    var showsPointsDivider: Bool {
        return dueDateText != nil && pointsText != nil
    }

    var iconImage: Image {
        switch plannableType {
        case .assignment:
            return Image.assignmentLine
        case .quiz:
            return Image.quizLine
        case .discussion_topic:
            return Image.discussionLine
        case .announcement:
            return Image.announcementLine
        case .wiki_page:
            return Image.documentLine
        case .planner_note:
            return Image.noteLine
        case .calendar_event:
            return Image.calendarMonthLine
        case .assessment_request:
            return Image.peerReviewLine
        case .other:
            return Image.warningLine
        }
    }
}
