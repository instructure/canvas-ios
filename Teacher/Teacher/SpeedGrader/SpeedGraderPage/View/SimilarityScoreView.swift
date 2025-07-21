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
import Core

struct SimilarityScoreView: View {
    let status: String
    let score: Double
    let url: URL?

    init?(_ submission: Submission, file: File?) {
        if submission.type == .online_upload, let file = file, let status = file.similarityStatus {
            self.status = status
            self.score = file.similarityScore
            self.url = file.similarityURL
        } else if submission.type == .online_text_entry, let status = submission.similarityStatus {
            self.status = status
            self.score = submission.similarityScore
            self.url = submission.similarityURL
        } else {
            return nil
        }
    }

    var body: some View {
        let content = HStack(spacing: 0) {
            Text("Similarity Score", bundle: .teacher)
                .font(.semibold14).foregroundColor(.textDarkest)
            Spacer()
            switch status {
            case "scored":
                Text(NumberFormatter.localizedString(from: NSNumber(value: score / 100), number: .percent))
                    .font(.semibold16).foregroundColor(.textLightest.variantForLightMode)
                    .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                    .background(
                        score >= 75 ? Color.textDanger :
                        score >= 50 ? Color.textMasquerade :
                        score >= 25 ? Color.textWarning :
                        score >= 1 ? Color.textSuccess :
                        Color.textInfo
                    )
                    .cornerRadius(4)
            case "pending":
                Image.clockLine
                    .size(18).foregroundColor(.textLightest.variantForLightMode)
                    .padding(4).background(Color.backgroundDark).cornerRadius(4)
                    .accessibility(label: Text("Pending", bundle: .teacher))
            default:
                Image.warningLine
                    .size(18).foregroundColor(.textLightest.variantForLightMode)
                    .padding(4).background(Color.backgroundDanger).cornerRadius(4)
                    .accessibility(label: Text("Error", bundle: .teacher))
            }
            if url != nil {
                Spacer().frame(width: 8)
                InstUI.DisclosureIndicator()
            }
        }
            .padding(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
        VStack(spacing: 0) {
            if let url = url {
                Button(action: { Router.open(url: .parse(url)) }, label: { content })
            } else {
                content
            }
            Divider()
        }
    }
}
