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

struct AssignmentDateSection: View {
    @ObservedObject var assignment: Assignment

    @Environment(\.appEnvironment) var env
    @Environment(\.viewController) var controller

    var body: some View {
        Button(action: route, label: { HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Icon.calendarClockLine
                    Text("Due", bundle: .core)
                        .font(.medium16)
                    Spacer()
                }
                    .foregroundColor(.textDark)
                if assignment.allDates.count > 1 {
                    Text("Multiple Due Dates", bundle: .core)
                } else {
                    let first = assignment.allDates.first
                    if let dueAt = assignment.dueAt ?? first?.dueAt {
                        Line(Text("Due:", bundle: .core), Text(dueAt.dateTimeString))
                    } else {
                        Line(Text("Due:", bundle: .core), Text(verbatim: "--"))
                            .accessibility(label: Text("No due date set.", bundle: .core))
                    }

                    Line(Text("For:", bundle: .core), first?.base == true
                        ? Text("Everyone", bundle: .core)
                        : Text(first?.title ?? "-")
                    )

                    let lockAt = first?.lockAt ?? assignment.lockAt
                    if let to = lockAt, to < Clock.now {
                        Line(Text("Availability:", bundle: .core), Text("Closed", bundle: .core))
                    } else {
                        if let from = first?.unlockAt ?? assignment.unlockAt {
                            Line(Text("Available From:", bundle: .core), Text(from.dateTimeString))
                        } else {
                            Line(Text("Available From:", bundle: .core), Text(verbatim: "--"))
                                .accessibility(label: Text("No available from date set.", bundle: .core))
                        }

                        if let to = lockAt {
                            Line(Text("Available Until:", bundle: .core), Text(to.dateTimeString))
                        } else {
                            Line(Text("Available Until:", bundle: .core), Text(verbatim: "--"))
                                .accessibility(label: Text("No available until date set.", bundle: .core))
                        }
                    }
                }
            }
                .font(.regular16).foregroundColor(.textDarkest)
                .padding(16)
            DisclosureIndicator().padding(.trailing, 16)
        } })
            .accessibility(hint: Text("Due Dates, Double tap for details.", bundle: .core))
    }

    @ViewBuilder
    func Line(_ title: Text, _ value: Text) -> some View {
        HStack(spacing: 4) {
            title.font(.semibold16)
            value
        }
    }

    func route() {
        env.router.route(to: "courses/\(assignment.courseID)/assignments/\(assignment.id)/due_dates", from: controller)
    }
}
