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
///
struct ContextCardSubmissionsView: View {
    private var submitted = 0
    private var late = 0
    private var missing = 0

    init(submissions: [Submission]) {
        for submission in submissions {
            switch submission.status {
            case .submitted:
                submitted += 1
            case .late:
                late += 1
                submitted += 1
            case .missing:
                missing += 1
            case .notSubmitted:
                break
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Submissions", bundle: .core)
                .font(.semibold14)
                .foregroundColor(.textDark)
            HStack {
                ContextCardBoxView(title: Text("\(submitted)"), subTitle: Text("Submitted", bundle: .core))
                    .accessibility(label: Text("\(submitted) submitted", bundle: .core))
                    .identifier("ContextCard.submissionsTotalLabel")
                ContextCardBoxView(title: Text("\(late)"), subTitle: Text("Late", bundle: .core))
                    .accessibility(label: Text("\(late) late", bundle: .core))
                    .identifier("ContextCard.submissionsLateLabel")
                ContextCardBoxView(title: Text("\(missing)"), subTitle: Text("Missing", bundle: .core))
                    .accessibility(label: Text("\(missing) missing", bundle: .core))
                    .identifier("ContextCard.submissionsMissingLabel")
            }
        }.padding(.horizontal, 16).padding(.vertical, 8)
    }
}

#if DEBUG
struct ContextCardSubmissionsView_Previews: PreviewProvider {
    static let env = PreviewEnvironment()
    static let context = env.globalDatabase.viewContext

    static var submissions: [Submission] {
        let submission = Submission(context: context)
        submission.submittedAt = Date()
        let late = Submission(context: context)
        late.late = true
        let missing = Submission(context: context)
        missing.missing = true
        return [submission, late, missing]
    }

    static var previews: some View {
        return ContextCardSubmissionsView(submissions: submissions).previewLayout(.sizeThatFits)
    }
}
#endif
