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
    @State var viewModel: ConferenceCardViewModel
    @StateObject private var offlineModeViewModel = OfflineModeViewModel(interactor: OfflineModeAssembly.make())

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
        PrimaryButton(isAvailable: !$offlineModeViewModel.isOffline, action: joinConference) {
            Text("Join", bundle: .student)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.pillButtonBrandFilled)
        .identifier("Conference.\(viewModel.id).joinButton")
    }

    private func joinConference() {
        if viewModel.joinURL != nil {
            viewModel.join()
        } else {
            env.router.route(to: viewModel.joinRoute, from: controller, options: .modal())
        }
    }

    private var dismissButton: some View {
        PrimaryButton(isAvailable: !$offlineModeViewModel.isOffline, action: viewModel.dismiss) {
            Text("Dismiss", bundle: .student)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.pillButtonDefaultOutlined)
        .identifier("Conference.\(viewModel.id).dismissButton")
    }
}

#if DEBUG

#Preview {
    ScrollView {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(verbatim: "With Join URL")
                ConferenceCardView(
                    viewModel: ConferenceCardViewModel(
                        id: "1",
                        title: "Weekly Team Standup",
                        contextName: "Introduction to Computer Science",
                        context: Context(.course, id: "1"),
                        joinURL: URL(string: "https://example.com/conference/join"),
                        environment: .shared,
                        snackBarViewModel: SnackBarViewModel(),
                        onDismiss: { _ in }
                    )
                )
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(verbatim: "Without Join URL")
                ConferenceCardView(
                    viewModel: ConferenceCardViewModel(
                        id: "2",
                        title: "Office Hours",
                        contextName: "Mobile Development Group",
                        context: Context(.group, id: "group1"),
                        joinURL: nil,
                        environment: .shared,
                        snackBarViewModel: SnackBarViewModel(),
                        onDismiss: { _ in }
                    )
                )
            }
        }
        .padding()
    }
}

#endif
