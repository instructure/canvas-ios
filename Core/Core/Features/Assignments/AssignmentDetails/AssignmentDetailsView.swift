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

    public init(env: AppEnvironment, courseID: String, assignmentID: String) {
        self.assignmentID = assignmentID
        self.courseID = courseID

        assignment = env.subscribe(GetAssignment(courseID: courseID, assignmentID: assignmentID))
        course = env.subscribe(GetCourse(courseID: courseID))

        screenViewTrackingParameters = ScreenViewTrackingParameters(
            eventName: "/courses/\(courseID)/assignments/\(assignmentID)"
        )
    }

    public var body: some View {
        states
            .background(Color.backgroundLightest)
            .navigationBarTitleView(
                title: String(localized: "Assignment Details", bundle: .core),
                subtitle: course.first?.name
            )
            .rightBarButtonItems(editButton)
            .navigationBarStyle(.color(course.first?.color))
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
            if let discussionUrl = assignment.discussionTopic?.htmlURL {
                Button {
                    env.router.route(to: discussionUrl, from: controller)
                } label: {
                    Text("View Discussion", bundle: .core)
                }
                .frame(maxWidth: .infinity, minHeight: 50)
                .background(Color(Brand.shared.buttonPrimaryBackground))
                .font(.semibold16)
                .foregroundColor(Color(Brand.shared.buttonPrimaryText))
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
                .accessibilityAddTraits(.isHeader)
            HStack(spacing: 0) {
                Text(assignment.pointsPossibleText)
                    .font(.medium16).foregroundColor(.textDark).accessibility(identifier: "AssignmentDetails.points")
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

        DateSection(viewModel: AssignmentDateSectionViewModel(assignment: assignment)).accessibility(identifier: "AssignmentDetails.due")

        Divider().padding(.horizontal, 16)

        let types = Section(label: Text("Submission Types", bundle: .core)) {
            Text(ListFormatter.localizedString(
                from: assignment.submissionTypesWithQuizLTIMapping.map { $0.localizedString },
                conjunction: .or
            ))
                .font(.regular16).foregroundColor(.textDarkest)
                .multilineTextAlignment(.leading)
                .accessibility(identifier: "AssignmentDetails.submissionTypes")
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
            WebView(html: html, baseURL: URL.Directories.documents, canToggleTheme: true)
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
                    Text(assignment.openLtiButtonTitle)
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

    /**
     This method returns a static edit button that checks permissions when tapped. Returning an empty array here doesn't work
     because when this view is embedded into a `ModuleItemSequenceViewController` bar button updates don't get synced
     so no matter if the `isTeacherEnrollment` turns to true the change won't propagate via KVO in `UIViewControllerExtensions.syncNavigationBar`
     */
    private func editButton() -> [UIBarButtonItemWithCompletion] {
        [
            UIBarButtonItemWithCompletion(title: String(localized: "Edit", bundle: .core)) { [_isTeacherEnrollment] in
                if _isTeacherEnrollment.wrappedValue {
                    env.router.route(to: "courses/\(courseID)/assignments/\(assignmentID)/edit",
                                     from: controller,
                                     options: .modal(isDismissable: false, embedInNav: true))
                } else {
                    let alert = UIAlertController(title: String(localized: "Error", bundle: .core),
                                                  message: String(localized: "You are not authorized to perform this action", bundle: .core),
                                                  preferredStyle: .alert)
                    alert.addAction(AlertAction(String(localized: "OK", bundle: .core), style: .default))
                    env.router.show(alert, from: controller, options: .modal())
                }
            }
        ]
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
            isQuizLTI: assignment.first?.isQuizLTI,
            assignmentID: assignmentID,
            from: controller.value
        )
    }
}

private extension Assignment {
    var openLtiButtonTitle: String {
        if isQuizLTI {
            String(localized: "Open the Quiz", bundle: .core)
        } else {
            String(localized: "Launch External Tool", bundle: .core)
        }
    }
}
