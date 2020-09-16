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

struct SpeedGraderView: View {
    let context: Context
    let assignmentID: String
    let userID: String?

    @Environment(\.appEnvironment) var env
    @Environment(\.viewController) var viewController

    @ObservedObject var assignment: Store<GetAssignment>
    @ObservedObject var submissions: Store<GetSubmissions>

    @State var currentIndex: Int = -1

    init(context: Context, assignmentID: String, userID: String, filter: GetSubmissions.Filter?) {
        self.assignmentID = assignmentID
        self.context = context
        self.assignment = AppEnvironment.shared.subscribe(GetAssignment(courseID: context.id, assignmentID: assignmentID, include: [ .overrides ]))
        self.submissions = AppEnvironment.shared.subscribe(GetSubmissions(context: context, assignmentID: assignmentID, filter: filter))
        self.userID = userID
    }

    var body: some View {
        ZStack {
            if currentIndex >= 0 && currentIndex < submissions.count && assignment.first != nil {
                Pages(items: submissions.all, currentIndex: $currentIndex) { submission in
                    SubmissionGrader(assignment: self.assignment.first!, submission: submission)
                        .testID("SpeedGrader.submission.\(submission.id)")
                }
                    .spaceBetween(10)
                    .scaleEach { max(0.9, (1 - abs($0 * 0.5))) }
                    .edgesIgnoringSafeArea(.bottom)
            } else if !isLoading {
                VStack {
                    HStack {
                        Spacer()
                        Button("Close", action: dismiss)
                            .font(.semibold16).accentColor(Color(Brand.shared.linkColor))
                            .padding(16)
                            .identifier("SpeedGrader.emptyCloseButton")
                    }
                    EmptyPanda(
                        name: "PandaSpace",
                        title: Text("No Submissions"),
                        message: Text("It seems there aren't any valid submissions to grade.")
                    )
                }
            } else {
                CircleProgress()
                    .accessibility(label: Text("Loading"))
                    .identifier("SpeedGrader.spinner")
            }
        }
            .onAppear(perform: load)
    }

    func load() {
        guard !submissions.requested else { return }
        assignment.refresh { _ in
            guard self.assignment.first?.anonymizeStudents == true else { return }
            self.submissions.useCase.shuffled = true
            self.submissions.setScope(self.submissions.useCase.scope)
        }
        submissions.eventHandler = {
            guard self.currentIndex == -1, let current = self.findCurrentIndex() else { return }
            self.currentIndex = current
        }
        submissions.exhaust()
    }

    var isLoading: Bool {
        !assignment.requested || assignment.pending ||
        !submissions.requested || submissions.pending || submissions.hasNextPage
    }

    func findCurrentIndex() -> Int? {
        guard !isLoading, assignment.first?.anonymizeStudents == submissions.useCase.shuffled else { return nil }
        return submissions.all.firstIndex { $0.userID == userID }
    }

    func dismiss() {
        guard let controller = viewController() else { return }
        env.router.dismiss(controller)
    }
}
