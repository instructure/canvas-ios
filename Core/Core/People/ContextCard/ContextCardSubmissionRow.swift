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
    private let gradient = LinearGradient(gradient: Gradient(colors: [Color(hexString: "#008EE2")!, Color(hexString: "#00C1F3")!]), startPoint: .leading, endPoint: .trailing)
    private let submission: Submission

    var body: some View {
        Button(action: { /*route to */}, label: {
            HStack(alignment: .top, spacing: 0) {
                Icon.assignmentLine
                    .padding(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 12))
                VStack(alignment: .leading, spacing: 8) {
                    Text("Beginning of the Biological Existence of Mankind in the Jungles of South Beginning of the Biological Existence of Mankind in the Jungles of South")
                        .font(.semibold16).foregroundColor(.textDarkest)
                        .lineLimit(2)
                    Text(submission.status.text)
                        .font(.semibold14).foregroundColor(.textDark)
                    progressView(progress: 0.66, label: Text(GradeFormatter().string(from: submission) ?? ""))
                }
            }
        })
        .padding(16)
    }

    init(submission: Submission) {
        self.submission = submission
    }

    private func progressView(progress: CGFloat, label: Text) -> some View {
        HStack {
            GeometryReader { proxy in
                HStack(spacing: 0) {
                    let gradientWidth = proxy.size.width * progress
                    Rectangle()
                        .fill(gradient)
                        .frame(width: gradientWidth)
                    Rectangle()
                        .fill(Color.backgroundLight)
                        .frame(width: proxy.size.width - gradientWidth)

                }
            }.frame(height: 18)
            label.foregroundColor(.textDark).font(.semibold14)
        }
    }
}

#if DEBUG
struct ContextCardSubmissionRow_Previews: PreviewProvider {
    static let env = PreviewEnvironment()
    static let context = env.globalDatabase.viewContext

    static var previews: some View {
        let submission = Submission(context: context)
        submission.submittedAt = Date()
        return ContextCardSubmissionRow(submission: submission).previewLayout(.sizeThatFits)
    }
}
#endif
