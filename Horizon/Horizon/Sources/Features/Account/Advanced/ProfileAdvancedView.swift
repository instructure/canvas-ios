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
import Observation
import SwiftUI

struct ProfileAdvancedView: View {

    let viewModel: ProfileAdvancedViewModel

    @State var timeZone: String = ""

    @State var open: Bool = false

    @FocusState var focused: Bool

    let rowItems = [
        "UTC-12:00: Baker Island, Howland Island",
        "UTC-11:00: American Samoa, Niue, Midway Atoll",
        "UTC-10:00: Hawaii-Aleutian Time (Hawaii), Cook Islands, Tahiti",
        "UTC-09:30: Marquesas Islands",
        "UTC-09:00: Alaska Time, Gambier Islands",
        "UTC-08:00: Pacific Time (US & Canada), Clipperton Island",
        "UTC-07:00: Mountain Time (US & Canada), Chihuahua, Mazatlan",
        "UTC-06:00: Central Time (US & Canada), Mexico City, Tegucigalpa",
        "UTC-05:00: Eastern Time (US & Canada), Bogota, Lima",
        "UTC-04:00: Atlantic Time (Canada), Caracas, La Paz",
        "UTC-03:30: Newfoundland Time",
        "UTC-03:00: Argentina, Brazil (Brasilia), Greenland",
        "UTC-02:00: South Georgia/Sandwich Islands",
        "UTC-01:00: Azores, Cape Verde",
        "UTC+00:00: Greenwich Mean Time (GMT), London, Casablanca",
        "UTC+01:00: Central European Time (CET), West Africa Time (WAT)",
        "UTC+02:00: Eastern European Time (EET), Central Africa Time (CAT)",
        "UTC+03:00: Moscow Time, East Africa Time (EAT), Arabian Time",
        "UTC+03:30: Iran Standard Time (IRST)",
        "UTC+04:00: Gulf Standard Time (GST), Samara Time",
        "UTC+04:30: Afghanistan Time (AFT)",
        "UTC+05:00: Pakistan Time (PKT), Yekaterinburg Time",
        "UTC+05:30: Indian Standard Time (IST), Sri Lanka Time",
        "UTC+05:45: Nepal Time (NPT)",
        "UTC+06:00: Bangladesh Time (BST), Bhutan Time",
        "UTC+06:30: Cocos Islands, Myanmar Time (MMT)",
        "UTC+07:00: Indochina Time (ICT), Krasnoyarsk Time",
        "UTC+08:00: China Standard Time (CST), Australian Western Time (AWT), Singapore Time",
        "UTC+08:45: Australian Central Western Time",
        "UTC+09:00: Japan Standard Time (JST), Korea Standard Time (KST), Yakutsk Time",
        "UTC+09:30: Australian Central Time (ACST)",
        "UTC+10:00: Australian Eastern Time (AEST), Vladivostok Time",
        "UTC+10:30: Lord Howe Island",
        "UTC+11:00: Solomon Islands, Magadan Time",
        "UTC+12:00: Fiji, New Zealand Standard Time (NZST), Kamchatka Time",
        "UTC+12:45: Chatham Islands",
        "UTC+13:00: Tonga, Phoenix Islands Time",
        "UTC+14:00: Line Islands"
    ]

    @State var displayedItems: [String] = []

    init(viewModel: ProfileAdvancedViewModel = ProfileAdvancedViewModel()) {
        self.viewModel = viewModel
        displayedItems = rowItems
    }

    var body: some View {
        ZStack(alignment: .top) {
            HorizonUI.TextInput(
                $timeZone,
                trailing: Image.huiIcons.chevronRight.rotationEffect(.degrees(open ? -90 : 90)).animation(
                    .easeInOut, value: open),
                focused: _focused
            )
            .onChange(of: focused) { _, newValue in
                displayedItems = rowItems
                open = newValue
            }
            .onChange(of: timeZone) { _, _ in
                if timeZone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    displayedItems = rowItems
                    return
                }

                if rowItems.first(where: { $0 == timeZone }) != nil {
                    focused = false
                    return
                }

                displayedItems = rowItems.filter { $0.lowercased().contains(timeZone.lowercased()) }

                if displayedItems.isEmpty {
                    displayedItems = rowItems
                }
            }
            ScrollView {
                VStack(spacing: .zero) {
                    ForEach(displayedItems, id: \.self) { item in
                        rowItem(item)
                    }
                }
                .background(Color.huiColors.surface.pageSecondary)
                .padding(.vertical, .huiSpaces.primitives.xxSmall)
                .padding(.horizontal, 5)
            }
            .cornerRadius(24)
            .shadow(radius: 3)
            .frame(maxWidth: .infinity, maxHeight: 500, alignment: .leading)
            .opacity(open ? 1 : 0)
            .animation(.easeInOut, value: open)
            .padding(.top, 50)
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding(.vertical, 25)
        .padding(.horizontal, .huiSpaces.primitives.small)
    }

    private func rowItem(_ text: String) -> some View {
        Text(text)
            .padding(.horizontal, .huiSpaces.primitives.small)
            .padding(.vertical, .huiSpaces.primitives.xSmall)
            .background(Color.huiColors.surface.pageSecondary)
            .huiTypography(.p1)
            .frame(maxWidth: .infinity, alignment: .leading)
            .onTapGesture {
                timeZone = text
                focused = false
            }
    }

}

#Preview {
    VStack {
        ProfileAdvancedView()
    }.frame(maxHeight: .infinity, alignment: .top)
}
