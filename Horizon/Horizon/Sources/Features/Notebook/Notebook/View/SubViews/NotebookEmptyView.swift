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

struct NotebookEmptyView: View {
    var body: some View {
        VStack(spacing: .huiSpaces.space8) {
            Text("Start capturing your notes")
                .foregroundStyle(Color.huiColors.text.body)
                .huiTypography(.h2)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("Your notes from learning materials will appear here. Highlight key ideas, reflections, or questions as you learn—they'll all be saved in your Notebook for easy review later.")
                .foregroundStyle(Color.huiColors.text.dataPoint)
                .huiTypography(.p1)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    NotebookEmptyView()
}
