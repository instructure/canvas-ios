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

import HorizonUI
import SwiftUI

struct InboxMessageView: View {
    let viewModel: InboxMessageModel
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading) {
            if viewModel.isNew || !viewModel.dateString.isEmpty {
                HStack(alignment: .top) {
                    Text(viewModel.dateString)
                        .huiTypography(.p2)
                        .padding(.bottom, .huiSpaces.space8)

                    Spacer()

                    if viewModel.isNew {
                        newIndicatorBadge
                    }
                }
            }

            HStack(alignment: .top, spacing: .huiSpaces.space8) {
                if viewModel.isAnnouncement {
                    HorizonUI.icons.announcement
                        .renderingMode(.template)
                        .foregroundStyle(HorizonUI.colors.icon.default)
                }
                VStack(alignment: .leading) {
                    Text(viewModel.title)
                        .lineLimit(1)
                        .huiTypography(viewModel.isNew ? .labelMediumBold : .p2)

                    Text(viewModel.subtitle)
                        .lineLimit(1)
                        .huiTypography(viewModel.isNew ? .labelMediumBold : .p2)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, .huiSpaces.space16)
        .padding(.bottom, .huiSpaces.space12)
        .padding(.leading, .huiSpaces.space16)
        .padding(.trailing, .huiSpaces.space12)
        .background(HorizonUI.colors.surface.pageSecondary)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityAddTraits(.isButton)
        .contentShape(.rect)
        .onTapGesture {
            onTap()
        }
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(HorizonUI.colors.lineAndBorders.lineStroke),
            alignment: .bottom
        )
    }

    var newIndicatorBadge: some View {
        HStack {}
            .frame(width: HorizonUI.spaces.space8, height: HorizonUI.spaces.space8)
            .background(HorizonUI.colors.surface.institution)
            .clipShape(Circle())
    }

    private var accessibilityLabel: String {
        var parts: [String] = []

        if viewModel.isNew {
            parts.append(String(localized: "New message"))
        }

        if !viewModel.dateString.isEmpty {
            parts.append(String(format: String(localized: "Date %@"), viewModel.dateString))
        }

        if viewModel.isAnnouncement {
            parts.append(viewModel.title)
            parts.append(String(format: String(localized: "Subject %@"), viewModel.subtitle))
        } else {
            parts.append(String(format: String(localized: "Subject %@"), viewModel.title))
            parts.append(String(format: String(localized: "Sender %@"), viewModel.subtitle))
        }

        return parts.joined(separator: ", ")
    }
}
