//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

struct SideMenuFooterView: View {
    @Environment(\.appEnvironment) private var env

    var body: some View {
        if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            HStack {
                Text(verbatim: "Degrees edX V. \(version)")
                    .padding(.leading, 10)
                    .font(.regular14)
                    .foregroundColor(.textDark)
                Spacer()
            }
            .padding()
            .frame(height: 30)
            .onTapGesture(count: 10) {
                UserDefaults.standard.set(true, forKey: "showDevMenu")
            }
        }
    }
}

#if DEBUG

struct SideMenuFooterView_Previews: PreviewProvider {
    static var previews: some View {
        SideMenuFooterView()
    }
}

#endif
