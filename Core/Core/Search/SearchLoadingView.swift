//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

struct SearchLoadingView: View {
    var body: some View {
        VStack {
            Spacer()
            Image("searching-panda", bundle: .core)
            Text("Hang Tight, We're Fetching Your Results!")
                .textStyle(.heading)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            Text("We’re working hard to find the best matches for your search. This won't take long! Thank you for your patience.")
                .font(.regular16, lineHeight: .normal)
                .multilineTextAlignment(.center)
            ProgressView()
            Spacer()
        }
        .frame(maxWidth: 400)
    }
}

#Preview {
    SearchLoadingView()
}
