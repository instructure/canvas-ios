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
import SwiftUI

struct ConferenceCardView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.appEnvironment) private var env
    @Environment(\.viewController) private var controller
    @Environment(\.offlineMode) private var offlineMode

    @State var viewModel: ConferenceCardViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Conference is ongoing", bundle: .student)
                    .font(.regular14, lineHeight: .fit)
                    .foregroundStyle(.textDark)

                Text(viewModel.title)
                    .font(.medium16, lineHeight: .fit)
                    .foregroundStyle(.textDarkest)

                Text(viewModel.contextName)
                    .font(.regular14, lineHeight: .fit)
                    .foregroundStyle(.textDark)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .paddingStyle(set: .standardCell)
            .multilineTextAlignment(.leading)

            HStack(spacing: InstUI.Styles.Padding.cellAccessoryPadding.rawValue) {
                dismissButton
                joinButton
            }
            .paddingStyle(.horizontal, .standard)
            .paddingStyle(.bottom, .standard)
        }
        .elevation(.cardLarge, background: .backgroundLightest)
        .accessibilityElement(children: .combine)
    }

    private var joinButton: some View {
        PrimaryButton(
            isAvailable: offlineMode.isAppOnline,
            action: { viewModel.didTapJoin(controller: controller) }
        ) {
            InstUI.PillContent(
                title: String(localized: "Join", bundle: .student),
                size: .height24,
                isTextBold: true
            )
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.pillTintFilled)
        .identifier("Conference.\(viewModel.id).joinButton")
    }

    private var dismissButton: some View {
        PrimaryButton(
            isAvailable: offlineMode.isAppOnline,
            action: { viewModel.didTapDismiss() }
        ) {
            InstUI.PillContent(
                title: String(localized: "Dismiss", bundle: .student),
                size: .height24
            )
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.pillDefaultOutlined)
        .identifier("Conference.\(viewModel.id).dismissButton")
    }
}

#if DEBUG

#Preview {
    PreviewContainer {
        ConferenceCardView(
            viewModel: ConferenceCardViewModel(
                model: .make(
                    id: "conf1",
                    title: "Computer Science Lecture",
                    contextName: "Introduction to Computer Science"
                ),
                snackBarViewModel: SnackBarViewModel(),
                environment: PreviewEnvironment(),
                onDismiss: { _ in }
            )
        )
    }
}

#endif
