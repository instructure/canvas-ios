//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

extension View {

    /**
     On iOS 17 there's a default content margin added by the system to the widget based on
     the environment it's shown so in this case we don't need to add any extra paddings. Below
     iOS 17 we add a default `padding()`.
     */
    @available(iOSApplicationExtension,
               obsoleted: 17.0,
               message: "Use the system provided content margin (delete this method and don't add anything in its place.).")
    func compatibleContentMargins() -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            return self
        } else {
            return padding()
        }
    }
}

