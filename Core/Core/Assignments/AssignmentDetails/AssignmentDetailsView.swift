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

/// Currently only suitable for Teacher app
public struct AssignmentDetailsView: View, ScreenViewTrackable {
    let assignmentID: String
    let courseID: String

    @ObservedObject var assignment: Store<GetAssignment>
    @ObservedObject var course: Store<GetCourse>
    @State private var isTeacherEnrollment: Bool = false
    @State private var isLocked: Bool = true

    @Environment(\.appEnvironment) var env
    @Environment(\.viewController) var controller

    public let screenViewTrackingParameters: ScreenViewTrackingParameters

    public init(courseID: String, assignmentID: String) {
        self.assignmentID = assignmentID
        self.courseID = courseID

        assignment = AppEnvironment.shared.subscribe(GetAssignment(courseID: courseID, assignmentID: assignmentID))
        course = AppEnvironment.shared.subscribe(GetCourse(courseID: courseID))

        screenViewTrackingParameters = ScreenViewTrackingParameters(
            eventName: "/courses/\(courseID)/assignments/\(assignmentID)"
        )
    }

    public var body: some View {
        states
            .background(Color.backgroundLightest)
            .navigationBarStyle(.color(course.first?.color))
            .navigationTitle(NSLocalizedString("Assignment Details", comment: ""), subtitle: course.first?.name)
            .navigationBarItems(trailing: isTeacherEnrollment ? editButton : nil)
            .onAppear {
                refreshAssignments()
                refreshCourses()
            }
    }

    @ViewBuilder var states: some View {
        if let assignment = assignment.first {
            RefreshableScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    details(assignment: assignment)
                        .onAppear { UIAccessibility.post(notification: .screenChanged, argument: nil) }
                }
            }
            refreshAction: { endRefreshing in
                self.assignment.refresh(force: true) { _ in
                    endRefreshing()
                }
            }
        } else if assignment.state == .loading {
            ZStack {
                ProgressView()
                    .progressViewStyle(.indeterminateCircle())
            }
        } else /* Assignment not found, perhaps recently deleted */ {
            Spacer().onAppear { env.router.dismiss(controller) }
        }
    }

    @ViewBuilder func details(assignment: Assignment) -> some View {
        Section {
            Text(assignment.name)
                .font(.heavy24).foregroundColor(.textDarkest).accessibility(identifier: "AssignmentDetails.name")
            HStack(spacing: 0) {
                Text(assignment.pointsPossibleText)
                    .font(.medium16).foregroundColor(.textDark)
                    .padding(.trailing, 12)
                HStack {
                    if assignment.published {
                        Image.publishSolid.foregroundColor(.textSuccess)
                            .padding(.trailing, 4)
                        Text("Published", bundle: .core)
                            .font(.medium16).foregroundColor(.textSuccess).accessibility(identifier: "AssignmentDetails.published")
                    } else {
                        Image.noSolid.foregroundColor(.textDark)
                            .padding(.trailing, 4)
                        Text("Unpublished", bundle: .core)
                            .font(.medium16).foregroundColor(.textDark).accessibility(identifier: "AssignmentDetails.unpublished")
                    }
                }
                    .accessibilityElement(children: .combine)
                Spacer()
            }
                .padding(.top, 2)
        }

        Divider().padding(.horizontal, 16)

        DateSection(viewModel: AssignmentDateSectionViewModel(assignment: assignment))

        Divider().padding(.horizontal, 16)

        let types = Section(label: Text("Submission Types", bundle: .core)) {
            Text(ListFormatter.localizedString(
                from: assignment.submissionTypes.map { $0.localizedString },
                conjunction: .or
            ))
                .font(.regular16).foregroundColor(.textDarkest)
                .multilineTextAlignment(.leading)
        }
        if assignment.isLTIAssignment {
            Button(action: launchLTITool, label: { HStack {
                types
                Spacer()
                DisclosureIndicator().padding(.trailing, 16)
            } }).disableWithOpacity(isLocked)
        } else {
            types
        }

        Divider().padding(.horizontal, 16)

        if isTeacherEnrollment {
            let viewModel = AssignmentSubmissionBreakdownViewModel(courseID: courseID, assignmentID: assignmentID, submissionTypes: assignment.submissionTypes)
            SubmissionBreakdown(viewModel: viewModel)
            Divider().padding(.horizontal, 16)
        }

        if let html = assignment.details, !html.isEmpty {
            Text("Description", bundle: .core)
                .font(.medium16).foregroundColor(.textDark)
                .padding(EdgeInsets(top: 16, leading: 16, bottom: 0, trailing: 16))
            WebView(html: html, canToggleTheme: true)
                .frameToFit()
        } else {
            Section(label: Text("Description", bundle: .core)) {
                HStack {
                    Text("Help your students with this assignment by adding instructions.", bundle: .core)
                        .font(.regular14).foregroundColor(.textDark)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                }
                    .padding(.horizontal, 12).padding(.vertical, 8)
                    .background(Color.backgroundLight)
                    .cornerRadius(3)
                    .padding(.top, 4)
            }
        }

        if assignment.isLTIAssignment {
            Button(action: launchLTITool, label: {
                HStack {
                    Spacer()
                    Text("Launch External Tool", bundle: .core)
                        .font(.semibold16).foregroundColor(Color(Brand.shared.buttonPrimaryText))
                    Spacer()
                }
                    .frame(minHeight: 51)
            })
                .background(Color(Brand.shared.buttonPrimaryBackground))
                .cornerRadius(4)
                .padding(EdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 16))
                .disableWithOpacity(isLocked)
        }
    }

    struct Section<Label: View, Content: View>: View {
        let content: Content
        let label: Label?

        init(label: Label?, @ViewBuilder content: () -> Content) {
            self.content = content()
            self.label = label
        }

        init(@ViewBuilder content: () -> Content) where Label == Text {
            self.content = content()
            self.label = nil
        }

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                label?
                    .font(.medium16).foregroundColor(.textDark)
                    .padding(.bottom, 4)
                content
            }
                .padding(16)
        }
    }

    private func rightButtonItems() -> [UIBarButtonItemWithCompletion] {
        guard isTeacherEnrollment else { return [] }
        return [
            UIBarButtonItemWithCompletion(title: NSLocalizedString("Edit", comment: ""), actionHandler: {
                env.router.route(to: "courses/\(courseID)/assignments/\(assignmentID)/edit",
                                 from: controller,
                                 options: .modal(isDismissable: false, embedInNav: true))
            }),
        ]
    }

    @ViewBuilder
    private var editButton: some View {
        Button {
            env.router.route(to: "courses/\(courseID)/assignments/\(assignmentID)/edit",
                             from: controller,
                             options: .modal(isDismissable: false, embedInNav: true))
        } label: {
            Text("Edit", bundle: .core)
                .font(.regular17)
                .foregroundColor(.textLightest)
        }
        .accessibility(label: Text("Edit Assignment", bundle: .core))
    }

    private func refreshAssignments() {
        assignment.refresh { _ in
            isLocked = assignment.first?.lockedForUser ?? false
        }
    }

    private func refreshCourses() {
        course.refresh { _ in
            isTeacherEnrollment = course.first?.enrollments?.contains(where: { ($0.isTeacher  || $0.isTA) && $0.state == .active }) == true
        }
    }

    func launchLTITool() {
        LTITools.launch(
            context: "course_\(courseID)",
            id: assignment.first?.externalToolContentID,
            url: nil,
            launchType: "assessment",
            assignmentID: assignmentID,
            from: controller.value
        )
    }
}
