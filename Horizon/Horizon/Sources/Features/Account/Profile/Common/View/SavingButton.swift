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

struct SavingButton: View {
    @Binding private var isLoading: Bool
    @Binding private var isDisabled: Bool
    private let onSave: () -> Void

    init(isLoading: Binding<Bool>, isDisabled: Binding<Bool>, onSave: @escaping () -> Void) {
        _isLoading = isLoading
        _isDisabled = isDisabled
        self.onSave = onSave
    }

    var body: some View {
        ZStack {
            HorizonUI.PrimaryButton(
                String(localized: "Save Changes", bundle: .horizon),
                type: .black,
                fillsWidth: true
            ) {
                onSave()
            }
            .opacity(isLoading ? 0.25 : 1.0)
            .animation(.easeInOut, value: isLoading)
            .disabled(isDisabled)

            HorizonUI.Spinner(size: .xSmall)
                .opacity(isLoading ? 1.0 : 0.0)
                .animation(.easeInOut, value: isLoading)
        }
        .frame(maxWidth: .infinity)
    }
}
