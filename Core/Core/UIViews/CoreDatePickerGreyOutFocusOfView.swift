//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

public struct CoreDatePickerGreyOutFocusOfView: View {
    @State public var opacitySetter: CGFloat = 0.5

    @Environment(\.presentationMode) var presentationMode

    var greyView: some View {
        Rectangle()
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            .background(Color.clear)
            .opacity(opacitySetter)
            .ignoresSafeArea()
    }

    public var body: some View {
        greyView
    }
}

struct CoreDatePickerGreyOutFocusOfView_Previews: PreviewProvider {
    static var previews: some View {
        CoreDatePickerGreyOutFocusOfView()
    }
}
