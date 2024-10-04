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

import Core
import SwiftUI

struct ContentDetailsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 4) {
                Image(systemName: "document")
                    .resizable()
                    .renderingMode(.template)
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(Color.textDarkest)
                    .frame(width: 14, height: 14)
                Text(verbatim: "Reading Material")
                    .foregroundColor(.textDarkest)
                    .font(.regular12)
                Spacer()
                Image(systemName: "timer")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundStyle(Color.textDarkest)
                    .frame(width: 14, height: 14)
                Text(verbatim: "20 mins")
                    .foregroundColor(.textDarkest)
                    .font(.regular12)
            }
            Text(verbatim: "Biology Certificate")
                .foregroundColor(.textDark)
                .font(.regular12)
                .padding(.top, 2)
            ContentProgressBar(
                progress: 0.30
            )
            .padding(.top, 12)

            HStack(spacing: 0) {
                Text(verbatim: "Not Started")
                Spacer()
                Text(verbatim: "Due 12/01/2024")
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .frame(maxHeight: .infinity)
        .navigationTitle("Content Details")
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

#Preview {
    ContentDetailsView()
}
