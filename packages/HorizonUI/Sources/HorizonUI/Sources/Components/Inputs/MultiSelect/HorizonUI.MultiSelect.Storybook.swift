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

import SwiftUI

extension HorizonUI.MultiSelect {
    struct Storybook: View {

        @State var focused = false
        @State var selections: [HorizonUI.MultiSelect.Option] = []
        @State var textInput = ""
        @State var loading = false

        var body: some View {
            HorizonUI.MultiSelect(
                selections: $selections,
                focused: $focused,
                label: "Label",
                textInput: $textInput,
                options: Array(1 ... 20).map {
                    Option(id: "Option \($0)", label: "Option \($0)")
                },
                loading: $loading
            )
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.horizontal, .huiSpaces.space36)
        }
    }
}

#Preview {
    HorizonUI.MultiSelect.Storybook()
}
