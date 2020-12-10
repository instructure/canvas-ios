//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

struct ContextCardSubmissionRow: View {
    var body: some View {
        Button(action: { /*route to */}, label: {
            HStack(alignment: .top, spacing: 0) {
                Icon.assignmentLine
                    .padding(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 12))
                VStack(alignment: .leading, spacing: 8) {
                    Text("Beginning of the Biological Existence of Mankind in the Jungles of South Beginning of the Biological Existence of Mankind in the Jungles of South")
                        .font(.semibold16).foregroundColor(.textDarkest)
                        .lineLimit(2)
                    Text("Submitted")
                        .font(.semibold14).foregroundColor(.textDark)
                    progressView
                }
            }
        })
        .padding(16)
    }
}

var progressView: some View {
    HStack {
        Rectangle()
            .fill(Color.blue)
            .frame(height: 18)
        Text("66/100")
    }
}

#if DEBUG
struct ContextCardSubmissionRow_Previews: PreviewProvider {
    static var previews: some View {
        ContextCardSubmissionRow()
    }
}
#endif
