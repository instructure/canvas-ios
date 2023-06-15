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

public struct QuizDetailsView<ViewModel: QuizDetailsViewModelProtocol>: View {
    @Environment(\.appEnvironment) var env
    @Environment(\.viewController) var controller

    @ObservedObject private var viewModel: ViewModel

    public init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        states
            .background(Color.backgroundLightest)
            .navigationBarStyle(.color(viewModel.courseColor))
            .navigationTitle(viewModel.title, subtitle: viewModel.subtitle)
            .rightBarButtonItems {
                [
                    UIBarButtonItemWithCompletion(
                        title: NSLocalizedString("Edit", comment: ""),
                        actionHandler: {
                            viewModel.editTapped(router: env.router, viewController: controller)
                        }
                    ),
                ]
            }
            .onAppear {
                viewModel.viewDidAppear()
            }
    }

    @ViewBuilder var states: some View {
        switch viewModel.state {
        case .loading:
            ZStack {
                ProgressView()
                    .progressViewStyle(.indeterminateCircle())
            }
        case .error:
            // Quiz not found, perhaps recently deleted
            Spacer().onAppear { env.router.dismiss(controller) }
        case .ready:
            RefreshableScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    details()
                        .onAppear { UIAccessibility.post(notification: .screenChanged, argument: nil) }
                }
            }
            refreshAction: { onComplete in
                viewModel.refresh(completion: onComplete)
            }
        }
    }

    @ViewBuilder func details() -> some View {
        QuizDetailsSection {
            Text(viewModel.quizTitle)
                .font(.heavy24).foregroundColor(.textDarkest).accessibility(identifier: "QuizDetails.name")
            HStack(spacing: 0) {
                Text(viewModel.pointsPossibleText)
                    .font(.medium16).foregroundColor(.textDark)
                    .padding(.trailing, 12)
                HStack {
                    if viewModel.published {
                        Image.publishSolid.foregroundColor(.textSuccess)
                            .padding(.trailing, 4)
                        Text("Published", bundle: .core)
                            .font(.medium16).foregroundColor(.textSuccess)
                    } else {
                        Image.noSolid.foregroundColor(.textDark)
                            .padding(.trailing, 4)
                        Text("Unpublished", bundle: .core)
                            .font(.medium16).foregroundColor(.textDark).accessibility(identifier: "QuizDetails.unpublished")
                    }
                }
                    .accessibilityElement(children: .combine)
                Spacer()
            }
                .padding(.top, 2)
        }

        Divider().padding(.horizontal, 16)

        if let assDateSectionViewModel = viewModel.assignmentDateSectionViewModel {
            DateSection(viewModel: assDateSectionViewModel)
            Divider().padding(.horizontal, 16)
        } else if let quizDateSectionViewModel = viewModel.quizDateSectionViewModel {
            DateSection(viewModel: quizDateSectionViewModel)
            Divider().padding(.horizontal, 16)
        }

        if viewModel.showSubmissions {
            if let assViewModel = viewModel.assignmentSubmissionBreakdownViewModel {
                SubmissionBreakdown(viewModel: assViewModel)
            } else if let quizViewModel = viewModel.quizSubmissionBreakdownViewModel {
                SubmissionBreakdown(viewModel: quizViewModel)
            }
            Divider().padding(.horizontal, 16)
        }

        if let html = viewModel.quizDetailsHTML, !html.isEmpty {
            Text("Description", bundle: .core)
                .font(.medium16).foregroundColor(.textDark)
                .padding(EdgeInsets(top: 16, leading: 16, bottom: 0, trailing: 16))
            WebView(html: html, canToggleTheme: true)
                .frameToFit()
        } else {
            QuizDetailsSection(label: Text("Description", bundle: .core)) {
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

        quizAttributes()

        Spacer()

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

    @ViewBuilder
    func quizAttributes() -> some View {
        VStack(alignment: .leading, spacing: 4) {
            let attributes = viewModel.attributes
            ForEach(attributes) { attribute in
                HStack(spacing: 4) {
                    Text(attribute.id).font(.semibold16)
                    Text(attribute.value)
                }
                .accessibilityElement(children: .combine)
            }
        }
        .font(.regular16).foregroundColor(.textDarkest)
        .padding(16)
    }

    func previewQuiz() {
        viewModel.previewTapped(router: env.router, viewController: controller)
    }
}

struct QuizDetailsSection<Label: View, Content: View>: View {
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

#if DEBUG

struct QuizDetails_Previews: PreviewProvider {
    static var previews: some View {
        let quizAttributes: [QuizAttribute] = [
            QuizAttribute("Quiz Type:", "Graded Quiz"),
            QuizAttribute("Time Limit:", "30 minutes"),
        ]
        let viewModel = QuizDetailsViewModelPreview(
            state: .ready,
            courseColor: .red,
            title: "Title",
            subtitle: "Subtitle",
            quizTitle: "Quiz Title",
            pointsPossibleText: "10 pts",
            published: true,
            quizDetailsHTML: "This is the description",
            attributes: quizAttributes
        )
        QuizDetailsView(viewModel: viewModel)
            .preferredColorScheme(.light)
            .previewLayout(.sizeThatFits)
        QuizDetailsView(viewModel: viewModel)
            .preferredColorScheme(.dark)
            .previewLayout(.sizeThatFits)
    }
}

#endif
