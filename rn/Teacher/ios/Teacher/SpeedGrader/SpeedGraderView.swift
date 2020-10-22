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
    @Environment(\.viewController) var controller

    @ObservedObject var assignment: Store<GetAssignment>
    @ObservedObject var submissions: Store<GetSubmissions>

    @State var currentIndex: Int = -1
    @State var isPagingEnabled = true

    init(context: Context, assignmentID: String, userID: String, filter: [GetSubmissions.Filter]) {
        self.assignmentID = assignmentID
        self.context = context
        self.assignment = AppEnvironment.shared.subscribe(GetAssignment(courseID: context.id, assignmentID: assignmentID, include: [ .overrides ]))
        self.submissions = AppEnvironment.shared.subscribe(GetSubmissions(context: context, assignmentID: assignmentID, filter: filter))
        self.userID = userID == "speedgrader" ? nil : userID
    }

    var body: some View {
        ZStack {
            if currentIndex >= 0 && currentIndex < submissions.count && assignment.first != nil {
                GeometryReader { geometry in
                    Pages(items: submissions.all, currentIndex: $currentIndex) { submission in
                        SubmissionGrader(
                            assignment: self.assignment.first!,
                            submission: submission,
                            isPagingEnabled: $isPagingEnabled,
                            bottomInset: geometry.safeAreaInsets.bottom
                        )
                            .testID("SpeedGrader.submission.\(submission.id)")
                    }
                        .spaceBetween(10)
                        .scaleEach { max(0.9, (1 - abs($0 * 0.5))) }
                        .pan(isEnabled: isPagingEnabled)
                        .background(Color.backgroundMedium)
                        .edgesIgnoringSafeArea(.bottom)
                }
            } else if !isLoading {
                VStack {
                    HStack {
                        Spacer()
                        Button("Close", action: dismiss)
                            .font(.semibold16).accentColor(Color(Brand.shared.linkColor))
                            .padding(16)
                            .identifier("SpeedGrader.emptyCloseButton")
                    }
                    EmptyPanda(.Space,
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
            .avoidKeyboardArea()
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
        return submissions.all.firstIndex { userID == nil || $0.userID == userID }
    }

    func dismiss() {
        env.router.dismiss(controller)
    }
}
