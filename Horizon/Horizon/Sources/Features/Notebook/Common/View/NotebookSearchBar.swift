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

struct NotebookSearchBar: View {

    @Binding var term: String

    var body: some View {
        ZStack(alignment: .leading) {
            TextField("",
                  text: $term,
                  prompt: Text(String(localized: "Search", bundle: .horizon))
                )
                .frame(height: 48)
                .padding(.leading, 48)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 32))
                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 1, y: 2)
            Image(systemName: "magnifyingglass")
                .foregroundColor(.textDarkest)
                .padding(.leading, 16)
        }
    }
}