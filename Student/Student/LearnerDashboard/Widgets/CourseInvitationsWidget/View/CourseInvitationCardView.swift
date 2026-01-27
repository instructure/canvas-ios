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
    @State var viewModel: CourseInvitationCardViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 2) {
                Text("You have been invited", bundle: .student)
                    .font(.regular14, lineHeight: .fit)
                    .foregroundColor(.textDark)

                Text(viewModel.displayName)
                    .font(.medium16, lineHeight: .fit)
                    .foregroundColor(.textDarkest)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .paddingStyle(set: .standardCell)

            HStack(spacing: InstUI.Styles.Padding.cellAccessoryPadding.rawValue) {
                acceptButton
                declineButton
            }
            .paddingStyle(.horizontal, .standard)
            .paddingStyle(.bottom, .standard)
        }
        .elevation(.cardLarge, background: .backgroundLightest)
        .disabled(viewModel.isProcessing)
        .alert(item: $viewModel.error) { error in
            Alert(title: Text(error.title), message: Text(error.message))
        }
    }

    private var acceptButton: some View {
        Button(action: { viewModel.accept() }) {
            if viewModel.isLoadingAccept {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .textLightest))
                    .frame(maxWidth: .infinity)
                    .frame(height: 24)
            } else {
                buttonText("Accept", fontName: .semibold12, color: .textLightest)
            }
        }
        .disabled(viewModel.isProcessing)
        .background(Color.brandPrimary)
        .cornerRadius(100)
        .identifier("CourseInvitation.\(viewModel.id).acceptButton")
    }

    private var declineButton: some View {
        Button(action: { viewModel.decline() }) {
            if viewModel.isLoadingDecline {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .textDarkest))
                    .frame(maxWidth: .infinity)
                    .frame(height: 24)
            } else {
                buttonText("Decline", fontName: .regular12, color: .textDarkest)
            }
        }
        .disabled(viewModel.isProcessing)
        .background(Color.backgroundLightest)
        .cornerRadius(100)
        .overlay(
            RoundedRectangle(cornerRadius: 100)
                .stroke(Color.borderMedium, lineWidth: 0.5)
        )
        .identifier("CourseInvitation.\(viewModel.id).rejectButton")
    }

    private func buttonText(_ key: LocalizedStringKey, fontName: UIFont.Name, color: Color) -> some View {
        Text(key, bundle: .student)
            .font(fontName, lineHeight: .fit)
            .foregroundColor(color)
            .frame(maxWidth: .infinity)
            .frame(height: 24)
            .contentShape(Rectangle())
    }
}

#if DEBUG

#Preview {
    let offlineModeInteractor = OfflineModeInteractorLive(isOfflineModeEnabledForApp: false)
    let coursesInteractor = CoursesInteractorLive()
    let viewModel = CourseInvitationCardViewModel(
        id: "1",
        courseId: "course1",
        courseName: "Introduction to Computer Science",
        sectionName: "Section 01",
        interactor: coursesInteractor,
        offlineModeInteractor: offlineModeInteractor,
        onDismiss: { _ in }
    )

    CourseInvitationCardView(viewModel: viewModel)
        .padding()
}

#endif
