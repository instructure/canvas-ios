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
    @State var viewModel: CourseInvitationCardViewModel
    @StateObject private var offlineModeViewModel = OfflineModeViewModel(interactor: OfflineModeAssembly.make())

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
                acceptButton
                declineButton
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
        PrimaryButton(isAvailable: !$offlineModeViewModel.isOffline, action: viewModel.accept) {
            ZStack {
                if viewModel.isAccepting {
                    ProgressView()
                        .progressViewStyle(.indeterminateCircle(size: 16, lineWidth: 2, color: .textLightest))
                } else {
                    Text("Accept", bundle: .student)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.pillButtonBrandFilled)
        .identifier("CourseInvitation.\(viewModel.id).acceptButton")
    }

    private var declineButton: some View {
        PrimaryButton(isAvailable: !$offlineModeViewModel.isOffline, action: viewModel.decline) {
            ZStack {
                if viewModel.isDeclining {
                    ProgressView()
                        .progressViewStyle(.indeterminateCircle(size: 16, lineWidth: 2, color: .textDarkest))
                } else {
                    Text("Decline", bundle: .student)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.pillButtonDefaultOutlined)
        .identifier("CourseInvitation.\(viewModel.id).rejectButton")
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
