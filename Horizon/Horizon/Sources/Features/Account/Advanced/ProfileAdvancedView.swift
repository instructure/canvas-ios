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

struct ProfileAdvancedView: View {

    @Bindable private var viewModel: ProfileAdvancedViewModel
    @State private var focused: Bool = false

    init(viewModel: ProfileAdvancedViewModel = ProfileAdvancedViewModel()) {
        self.viewModel = viewModel
    }

    var body: some View {
        ProfileBody(String(localized: "Advanced", bundle: .horizon)) {
            HorizonUI.SingleSelect(
                label: String(localized: "Time Zone", bundle: .horizon),
                selection: $viewModel.timeZone,
                options: viewModel.timeZones,
                disabled: viewModel.isSelectDisabled,
                focused: $focused
            )
            SavingButton(
                title: String(localized: "Save Changes", bundle: .horizon),
                isLoading: $viewModel.isLoading,
                isDisabled: $viewModel.isSaveDisabled,
                onSave: viewModel.save
            )
        }
        .onTapGesture {
            print("On Tap")
            focused = false
        }
    }
}

#Preview {
    VStack {
        ProfileAdvancedView()
    }.frame(maxHeight: .infinity, alignment: .top)
}
