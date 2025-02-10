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

    @Bindable var viewModel: ProfileAdvancedViewModel

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

    init(viewModel: ProfileAdvancedViewModel = ProfileAdvancedViewModel()) {
        self.viewModel = viewModel
    }

    var body: some View {
        ProfileBody(String(localized: "Profile", bundle: .horizon)) {
            ZStack {
                HorizonUI.SingleSelect(
                    label: String(localized: "Time Zone", bundle: .horizon),
                    selection: $viewModel.timeZone,
                    options: rowItems
                ) {
                    SavingButton(
                        isLoading: $viewModel.isLoading,
                        isDisabled: $viewModel.isSaveDisabled,
                        onSave: viewModel.save
                    )
                }
            }
            .padding(.horizontal, .huiSpaces.primitives.large)
        }
    }
}

#Preview {
    VStack {
        ProfileAdvancedView()
    }.frame(maxHeight: .infinity, alignment: .top)
}
