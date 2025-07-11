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

import Observation
import SwiftUI

extension HorizonUI.TextArea {
    struct Storybook: View {

        @State var emptyTextInput: String = ""

        var body: some View {
            ScrollView {
                VStack(spacing: 32) {
                    HorizonUI.TextArea(
                        .constant(""),
                        label: "This is an empty text input",
                        helperText: "This is helper text",
                        placeholder: "This is placeholder text"
                    )
                }
                .padding(24)
            }
        }
    }
}

#Preview {
    HorizonUI.TextInput.Storybook()
}
