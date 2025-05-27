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

struct HorizonInboxView: View {

    @State private var messagesFilterSelection: String = "All Messages"
    @State private var filterByPersonSelection: String = ""
    @State private var isMessagesFilterFocused: Bool = false
    @State private var isFilterByPersonFocused: Bool = false

    var body: some View {
//        GeometryReader { geometry in
        VStack {
            topBar
            ScrollView {
                VStack(alignment: .leading, spacing: HorizonUI.spaces.space16) {
                    HorizonUI.SingleSelect(
                        selection: $messagesFilterSelection,
                        focused: $isMessagesFilterFocused,
                        label: nil,
                        options: [
                            String(localized: "All Messages", bundle: .horizon),
                            String(localized: "Announcements", bundle: .horizon),
                            String(localized: "Unread", bundle: .horizon),
                            String(localized: "Sent", bundle: .horizon)
                        ],
                        zIndex: 102
                    )
                    .padding(.horizontal, .huiSpaces.space16)

                    HorizonUI.SingleSelect(
                        selection: $filterByPersonSelection,
                        focused: $isFilterByPersonFocused,
                        label: nil,
                        options: [
                            "I",
                            "Just",
                            "Realized",
                            "I",
                            "Have",
                            "No",
                            "Options"
                        ],
                        placeholder: String(localized: "Filter by person", bundle: .horizon)
                    )
                    .padding(.horizontal, .huiSpaces.space16)

                    VStack {
                        MessageRow(date: "Today", subject: "Welcome to Canvas!", names: "John Doe, Jane Smith")
                        MessageRow(date: "Today", subject: "Welcome to Canvas!", names: "John Doe, Jane Smith")
                        MessageRow(date: "Today", subject: "Welcome to Canvas!", names: "John Doe, Jane Smith")
                        MessageRow(date: "Today", subject: "Welcome to Canvas!", names: "John Doe, Jane Smith")
                        MessageRow(date: "Today", subject: "Welcome to Canvas!", names: "John Doe, Jane Smith")
                        MessageRow(date: "Today", subject: "Welcome to Canvas!", names: "John Doe, Jane Smith")
                        MessageRow(date: "Today", subject: "Welcome to Canvas!", names: "John Doe, Jane Smith")
                        MessageRow(date: "Today", subject: "Welcome to Canvas!", names: "John Doe, Jane Smith")
                        MessageRow(date: "Today", subject: "Welcome to Canvas!", names: "John Doe, Jane Smith")
                        MessageRow(date: "Today", subject: "Welcome to Canvas!", names: "John Doe, Jane Smith")
                        MessageRow(date: "Today", subject: "Welcome to Canvas!", names: "John Doe, Jane Smith")
                    }
                    .frame(maxHeight: .infinity, alignment: .top)
                    .frame(maxWidth: .infinity)
                    .background(HorizonUI.colors.surface.pageSecondary)
                    .clipShape(
                        .rect(
                            topLeadingRadius: 32,
                            bottomLeadingRadius: 0,
                            bottomTrailingRadius: 0,
                            topTrailingRadius: 32
                        )
                    )
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(HorizonUI.colors.surface.pagePrimary)
        .navigationBarHidden(true)
    }

    var topBar: some View {
        HStack {
            HorizonBackButton { _ in }
            Spacer()
            HorizonUI.PrimaryButton(
                String(localized: "Create message", bundle: .horizon),
                type: .institution,
                leading: HorizonUI.icons.editSquare
            ) { }
        }
        .padding(.horizontal, .huiSpaces.space16)
    }
}

struct MessageRow: View {
    var date: String
    var subject: String
    var names: String

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Text(date)
                    .huiTypography(.p2)
                    .padding(.bottom, .huiSpaces.space8)
                Spacer()
                HStack {}
                    .frame(width: HorizonUI.spaces.space8, height: HorizonUI.spaces.space8)
                    .background(HorizonUI.colors.surface.institution)
                    .clipShape(Circle())
            }

            Text(subject)
                .huiTypography(.labelMediumBold)
            Text(names)
                .huiTypography(.labelMediumBold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, .huiSpaces.space16)
        .padding(.bottom, .huiSpaces.space12)
        .padding(.leading, .huiSpaces.space16)
        .padding(.trailing, .huiSpaces.space12)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(HorizonUI.colors.lineAndBorders.lineStroke),
            alignment: .bottom
        )
    }
}

#Preview {
    HorizonInboxView()
}
