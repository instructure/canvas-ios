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

public struct QuizDetailsView: View {

    @Environment(\.appEnvironment) var env
    @Environment(\.viewController) var controller

    @ObservedObject private var viewModel: QuizDetailsViewModel

    public init(viewModel: QuizDetailsViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        states
            .navigationBarStyle(.color(viewModel.courseColor))
            .navigationTitle(viewModel.title, subtitle: viewModel.subtitle)
            .compatibleNavBarItems(trailing: {
                Button(action: {
                    viewModel.editTapped(router: env.router, viewController: controller)
                }, label: {
                    Text("Edit", bundle: .core)
                        .fontWeight(.regular)
                        .foregroundColor(.textLightest)
                })
            })
            .onAppear {
                viewModel.viewDidAppear()
            }
    }

    @ViewBuilder var states: some View {
        switch viewModel.state {
        case .loading:
            ZStack { CircleProgress() }
        case .error:
            // Quiz not found, perhaps recently deleted
            Spacer().onAppear { env.router.dismiss(controller) }
        case .data(let quiz):
            ScrollView { VStack(alignment: .leading, spacing: 0) {
                /*CircleRefresh { endRefreshing in
                    self.viewModel.refresh { _ in
                        endRefreshing()
                    }
                }*/
                details(quiz: quiz)
                    .onAppear { UIAccessibility.post(notification: .screenChanged, argument: nil) }
            } }
        }
    }

    @ViewBuilder func details(quiz: Quiz) -> some View {
        Section {
            Text(quiz.title)
                .font(.heavy24).foregroundColor(.textDarkest).accessibility(identifier: "QuizDetails.name")
            HStack(spacing: 0) {
                Text(quiz.pointsPossibleText)
                    .font(.medium16).foregroundColor(.textDark)
                    .padding(.trailing, 12)
                if quiz.published {
                    Image.publishSolid.foregroundColor(.textSuccess)
                        .padding(.trailing, 4)
                    Text("Published", bundle: .core)
                        .font(.medium16).foregroundColor(.textSuccess).accessibility(identifier: "QuizDetails.published")
                } else {
                    Image.noSolid.foregroundColor(.textDark)
                        .padding(.trailing, 4)
                    Text("Unpublished", bundle: .core)
                        .font(.medium16).foregroundColor(.textDark).accessibility(identifier: "QuizDetails.unpublished")
                }
                Spacer()
            }
                .padding(.top, 2)
        }

        Divider().padding(.horizontal, 16)

        //TODO
        //AssignmentDateSection(assignment: assignment)

        Divider().padding(.horizontal, 16)
/*
        if viewModel.showSubmissions {
            SubmissionBreakdown(courseID: viewModel.courseID, assignmentID: viewModel.assignmentID, submissionTypes: assignment.submissionTypes)

            Divider().padding(.horizontal, 16)
        }
*/
        if let html = quiz.details, !html.isEmpty {
            Text("Description", bundle: .core)
                .font(.medium16).foregroundColor(.textDark)
                .padding(EdgeInsets(top: 16, leading: 16, bottom: 0, trailing: 16))
            WebView(html: html)
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

        //fix button
            Button(action: launchLTITool, label: {
                HStack {
                    Spacer()
                    Text("Preview Quiz", bundle: .core)
                        .font(.semibold16).foregroundColor(Color(Brand.shared.buttonPrimaryText))
                    Spacer()
                }
                    .frame(minHeight: 51)
            })
                .background(Color(Brand.shared.buttonPrimaryBackground))
                .cornerRadius(4)
                .padding(EdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 16))
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

    func launchLTITool() {
        viewModel.launchLTITool(router: env.router, viewController: controller)
    }
}
