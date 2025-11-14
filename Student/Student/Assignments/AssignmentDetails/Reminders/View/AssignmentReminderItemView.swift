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

import Core
import SwiftUI

struct AssignmentReminderItemView: View {
    @ScaledMetric private var uiScale: CGFloat = 1

    public let viewModel: AssignmentReminderItem
    public let deleteDidTap: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            InstUI.Divider()
            HStack(spacing: 0) {
                bellIcon
                titleView
                Spacer(minLength: 0)
                deleteButton
            }
            .foregroundStyle(Color.textDarkest)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityAction {
            deleteDidTap()
        }
        .accessibilityLabel(Text("Reminder", bundle: .student) + Text(verbatim: ",\(viewModel.title)"))
        .accessibilityHint(Text("Activate to delete", bundle: .student))
    }

    private var bellIcon: some View {
        Image.unmutedLine
            .resizable()
            .frame(width: uiScale.iconScale * 24,
                   height: uiScale.iconScale * 24)
            .padding(.top, 14)
            .padding(.bottom, 16)
            .padding(.leading, 6)
            .padding(.trailing, 18)
    }

    private var titleView: some View {
        Text(viewModel.title)
            .font(.regular16)
            .padding(.top, 12)
            .padding(.bottom, 14)
    }

    private var deleteButton: some View {
        Button {
            deleteDidTap()
        } label: {
            Image.xLine
                .resizable()
                .frame(width: uiScale.iconScale * 24,
                       height: uiScale.iconScale * 24)
                // To increase the tap area
                .padding(.vertical, 16)
                .padding(.leading, 16)
        }
    }
}

#if DEBUG

struct AssignmentReminderItemView_Previews: PreviewProvider {

    static var previews: some View {
        VStack(spacing: 0) {
            AssignmentReminderItemView(viewModel: AssignmentReminderItem(title: "1 hour before"),
                                       deleteDidTap: {})
            AssignmentReminderItemView(viewModel: AssignmentReminderItem(title: "1 week before"),
                                       deleteDidTap: {})
        }
    }
}

#endif
