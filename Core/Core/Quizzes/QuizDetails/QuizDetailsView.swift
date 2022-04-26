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
            .navBarItems(trailing: {
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
        case .data(let quiz, let assignment):
            ScrollView { VStack(alignment: .leading, spacing: 0) {
                /*CircleRefresh { endRefreshing in
                    self.viewModel.refresh { _ in
                        endRefreshing()
                    }
                }*/
                details(quiz: quiz, assignment: assignment)
                    .onAppear { UIAccessibility.post(notification: .screenChanged, argument: nil) }
            } }
        }
    }

    @ViewBuilder func details(quiz: Quiz, assignment: Assignment) -> some View {
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

        AssignmentDateSection(assignment: assignment)

        Divider().padding(.horizontal, 16)

        if viewModel.showSubmissions {
            SubmissionBreakdown(courseID: viewModel.courseID, assignmentID: assignment.id, submissionTypes: assignment.submissionTypes)

            Divider().padding(.horizontal, 16)
        }

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

        Divider().padding(.horizontal, 16)

        VStack(alignment: .leading, spacing: 4) {
            Line(Text("Quiz Type:", bundle: .core), Text(quiz.quizType.sectionTitle))
            //TODO
            Line(Text("Assignment Group:", bundle: .core), Text("TODO"))
            if let assignmentGroup = assignment.assignmentGroup?.name {
                Line(Text("Assignment Group:", bundle: .core), Text(assignmentGroup))
            }
            let shuffleAnswers = quiz.shuffleAnswers ? Text("Yes") : Text("No")
            Line(Text("Shuffle Answers:", bundle: .core), shuffleAnswers)

            let timeLimitText = quiz.timeLimit != nil ? "\(Int(quiz.timeLimit!)) Minutes" : "No time Limit"
            Line(Text("Time Limit:", bundle: .core), Text(timeLimitText))

            Line(Text("Allowed Attempts:", bundle: .core), Text(quiz.allowedAttemptsText))
            //TODO
            if let hideResults = quiz.hideResults {
                Line(Text("View Responses:", bundle: .core), Text(hideResults.text))
            }
            //TODO
            //Line(Text("Show Correct Answers:", bundle: .core), Text(quiz.???))

            let oneQuestionAtATime = quiz.oneQuestionAtATime ? Text("Yes") : Text("No")
            Line(Text("One Question at a Time:", bundle: .core), oneQuestionAtATime)
            let lockQuestionsAfterAnswering = quiz.oneQuestionAtATime == true && quiz.cantGoBack ? Text("Yes") : Text("No")
            //TODO cantgoBack
            Line(Text("Lock Questions After Answering:", bundle: .core), lockQuestionsAfterAnswering)
            //TODO
            //Line(Text("Score to Keep:", bundle: .core), Text(quiz.sco))
            if let accessCode = quiz.accessCode {
                Line(Text("Access Code:", bundle: .core), Text(accessCode))
            }
        }
        .font(.regular16).foregroundColor(.textDarkest)
        .padding(16)

        Spacer()
        
        //fix button
            Button(action: previewQuiz, label: {
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

    @ViewBuilder
    func Line(_ title: Text, _ value: Text) -> some View {
        HStack(spacing: 4) {
            title.font(.semibold16)
            value
        }
    }

    func previewQuiz() {
        viewModel.launchPreview(router: env.router, viewController: controller)
    }
}
