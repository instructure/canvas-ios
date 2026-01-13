//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

import Core
import HorizonUI
import SwiftUI

struct ReportBugView: View {
    private enum FocusedInput {
        case subject
        case description
    }
    // MARK: - Propertites a11y

    @AccessibilityFocusState private var focusedTopicSelection: Bool?

    // MARK: - Private variables

    @FocusState private var focusedInput: FocusedInput?
    @Environment(\.viewController) private var viewController
    @State private var isTopicListFocused: Bool = false

    @State var viewModel: ReportBugViewModel

    var body: some View {
        InstUI.BaseScreen(
            state: viewModel.state,
            config: .init(
                refreshable: false,
                scrollBounce: .basedOnSize,
                loaderBackgroundColor: .huiColors.surface.pageSecondary
            )
        ) { proxy in
            VStack(spacing: .huiSpaces.space16) {
                subTitleTextView
                    .padding(.bottom, .huiSpaces.space8)

                topicTextView
                listTopicView
                    .padding(.bottom, .huiSpaces.space8)

                subjectTextView
                subjectTextField

                descriptionTextView
                descriptionTextArea(proxy: proxy)
            }
        }
        .safeAreaInset(edge: .top) {
            VStack(spacing: .huiSpaces.space16) {
                headerView
                divider
            }
            .background(Color.huiColors.surface.pageSecondary)
        }
        .safeAreaInset(edge: .bottom) {
            if focusedInput == nil {
                footer
            }
        }
        .dismissKeyboardOnTap()
        .huiToast(
            viewModel: .init(
                text: viewModel.errorMessage,
                style: .error
            ),
            isPresented: $viewModel.isShowError
        )
    }

    private var headerView: some View {
        HStack(spacing: .zero) {
            Text("Report a problem")
                .huiTypography(.h3)
                .foregroundStyle(Color.huiColors.text.title)
                .accessibilityAddTraits(.isHeader)
                .padding(.horizontal, .huiSpaces.space24)
            Spacer()

            HorizonUI.IconButton(Image.huiIcons.close, type: .white, isSmall: false) {
                viewModel.dimiss(viewController: viewController)
            }
            .accessibilityLabel(String(localized: "Close"))
            .accessibilityHint(String(localized: "Dismisses the report a problem screen"))
        }
    }

    private var divider: some View {
        Divider()
            .background(Color.huiColors.lineAndBorders.containerStroke)
            .accessibilityHidden(true)
            .padding(.bottom, .huiSpaces.space8)
    }

    private var subTitleTextView: some View {
        Text("File a ticket for a personal response from our support team.")
            .frame(maxWidth: .infinity, alignment: .leading)
            .multilineTextAlignment(.leading)
            .foregroundStyle(Color.huiColors.text.body)
            .huiTypography(.p1)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, .huiSpaces.space24)
    }

    private var topicTextView: some View {
        VStack(spacing: .huiSpaces.space8) {
            Text("Topic*")
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(Color.huiColors.text.body)
                .huiTypography(.labelLargeBold)
                .padding(.horizontal, .huiSpaces.space24)
                .accessibilityHidden(true)
        }
    }

    private var listTopicView: some View {
        HorizonUI.SingleSelect(
            selection: $viewModel.selectedTopic,
            focused: $isTopicListFocused,
            isSearchable: false,
            label: nil,
            options: viewModel.listTopics,
            zIndex: 102,
            borderOpacity: 1
        )
        .accessibilityFocused($focusedTopicSelection, equals: true)
        .accessibilityLabel(String(localized: "Topic, required"))
        .accessibilityHint(String(localized: "Select the topic that best describes your issue"))
        .accessibilityValue(viewModel.selectedTopic.isEmpty ? String(localized: "No topic selected") : viewModel.selectedTopic)
        .padding(.horizontal, .huiSpaces.space24)
        .onChange(of: isTopicListFocused) { _, newValue in
            if newValue == false {
                focusedTopicSelection = true
            }
        }
    }

    private var subjectTextView: some View {
        Text("Subject*")
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(Color.huiColors.text.body)
            .huiTypography(.labelLargeBold)
            .padding(.horizontal, .huiSpaces.space24)
            .accessibilityHidden(true)
    }

    private var subjectTextField: some View {
        HorizonUI.TextInput($viewModel.subject)
            .accessibilityLabel(String(localized: "Subject, required"))
            .accessibilityHint(String(localized: "Enter a brief summary of your issue"))
            .padding(.horizontal, .huiSpaces.space24)
            .padding(.bottom, .huiSpaces.space8)
            .focused($focusedInput, equals: .subject)
    }

    private var descriptionTextView: some View {
        Text("Description*")
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(Color.huiColors.text.body)
            .huiTypography(.labelLargeBold)
            .padding(.horizontal, .huiSpaces.space24)
            .accessibilityHidden(true)
    }

    private func descriptionTextArea(proxy: GeometryProxy) -> some View {
        TextArea(text: $viewModel.description, proxy: proxy)
            .focused($focusedInput, equals: .description)
            .accessibilityLabel(String(localized: "Description, required"))
            .accessibilityHint(String(localized: "Provide detailed information about your issue"))
            .padding(.horizontal, .huiSpaces.space24)
    }

    private var footer: some View {
        VStack(alignment: .leading, spacing: .huiSpaces.space12) {
            divider
            HStack {
                HorizonUI.PrimaryButton(String(localized: "Cancel"), type: .white) {
                    viewModel.dimiss(viewController: viewController)
                }
                .accessibilityLabel(String(localized: "Close"))
                Spacer()
                HorizonUI.PrimaryButton(String("Submit ticket"), type: .institution) {
                    viewModel.submit(viewController: viewController)
                }
                .disabled(!viewModel.isSubmitEnabled)
                .accessibilityLabel(String(localized: "Submit ticket"))
                .accessibilityHint(
                    viewModel.isSubmitEnabled
                    ? String(localized: "Submits your bug report")
                    : String(localized: "Fill in all required fields to enable submission")
                )
            }
            .padding(.horizontal, .huiSpaces.space24)
            .padding(.bottom, .huiSpaces.space12)
        }
    }
}

#Preview {
    ReportBugView(
        viewModel: ReportBugViewModel(
            api: AppEnvironment.shared.api,
            baseURL: "https://career.com",
            router: AppEnvironment.shared.router
        )
    )
}
