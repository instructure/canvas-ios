//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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
import SwiftUI

struct CourseInvitationCardView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.offlineMode) private var offlineMode

    @State var viewModel: CourseInvitationCardViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 2) {
                Text("You have been invited", bundle: .student)
                    .font(.regular14, lineHeight: .fit)
                    .foregroundStyle(.textDark)

                Text(viewModel.displayName)
                    .font(.medium16, lineHeight: .fit)
                    .foregroundStyle(.textDarkest)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .paddingStyle(set: .standardCell)
            .multilineTextAlignment(.leading)

            HStack(spacing: InstUI.Styles.Padding.cellAccessoryPadding.rawValue) {
                declineButton
                acceptButton
            }
            .paddingStyle(.horizontal, .standard)
            .paddingStyle(.bottom, .standard)
            .disabled(viewModel.isProcessing)
            .animation(.dashboardWidget, value: viewModel.isProcessing)
        }
        .elevation(.cardLarge, background: .backgroundLightest)
        .disabled(viewModel.isProcessing)
        .errorAlert(
            isPresented: $viewModel.isShowingErrorAlert,
            presenting: viewModel.errorAlert
        )
        .accessibilityElement(children: .combine)
    }

    private var acceptButton: some View {
        PrimaryButton(isAvailable: offlineMode.isAppOnline, action: viewModel.accept) {
            ZStack {
                if viewModel.isAccepting {
                    PillContentProgressView(size: .height24, color: .textLightest)
                } else {
                    InstUI.PillContent(
                        title: String(localized: "Accept", bundle: .student),
                        size: .height24,
                        isTextBold: true
                    )
                }
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.pillTintFilled)
        .identifier("CourseInvitation.\(viewModel.id).acceptButton")
    }

    private var declineButton: some View {
        PrimaryButton(isAvailable: offlineMode.isAppOnline, action: viewModel.decline) {
            ZStack {
                if viewModel.isDeclining {
                    PillContentProgressView(size: .height24, color: .textDarkest)
                } else {
                    InstUI.PillContent(
                        title: String(localized: "Decline", bundle: .student),
                        size: .height24
                    )
                }
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.pillDefaultOutlined)
        .identifier("CourseInvitation.\(viewModel.id).rejectButton")
    }
}

private struct PillContentProgressView: View {
    @ScaledMetric private var uiScale: CGFloat = 1

    let size: InstUI.PillContent.SizeConfig
    let color: Color

    var body: some View {
        ProgressView()
            .progressViewStyle(.indeterminateCircle(
                size: size.iconSize * uiScale.iconScale,
                lineWidth: 2 * uiScale.iconScale,
                color: color
            ))
            .frame(minHeight: size.height * uiScale)
    }
}

#if DEBUG

private struct CourseInvitationCardPreviewContainer: View {
    let acceptBehavior: CoursesInteractorMock.MockBehavior
    let declineBehavior: CoursesInteractorMock.MockBehavior
    let isOffline: Bool

    init(
        acceptBehavior: CoursesInteractorMock.MockBehavior = .success,
        declineBehavior: CoursesInteractorMock.MockBehavior = .success,
        isOffline: Bool = false
    ) {
        self.acceptBehavior = acceptBehavior
        self.declineBehavior = declineBehavior
        self.isOffline = isOffline
    }

    var body: some View {
        let coursesInteractor = CoursesInteractorMock()
        coursesInteractor.acceptBehavior = acceptBehavior
        coursesInteractor.declineBehavior = declineBehavior
        coursesInteractor.acceptDeclineDelay = 2
        let viewModel = CourseInvitationCardViewModel(
            id: "1",
            courseId: "course1",
            courseName: "Introduction to Computer Science",
            sectionName: "Section 01",
            interactor: coursesInteractor,
            snackBarViewModel: SnackBarViewModel(),
            onDismiss: { _ in }
        )
        return CourseInvitationCardView(viewModel: viewModel)
            .padding()
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(verbatim: "Success")
                CourseInvitationCardPreviewContainer()
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(verbatim: "Failure")
                CourseInvitationCardPreviewContainer(
                    acceptBehavior: .failure(NSError(domain: "TestError", code: 1)),
                    declineBehavior: .failure(NSError(domain: "TestError", code: 2))
                )
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(verbatim: "Offline")
                CourseInvitationCardPreviewContainer(isOffline: true)
            }
        }
        .padding()
    }
}

#endif
