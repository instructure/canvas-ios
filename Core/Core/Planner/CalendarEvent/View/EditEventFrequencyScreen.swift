//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

struct EditEventFrequencyScreen: View, ScreenViewTrackable {
    @Environment(\.viewController) private var viewController

    @ObservedObject private var viewModel: EditEventFrequencyViewModel

    var screenViewTrackingParameters: ScreenViewTrackingParameters { viewModel.pageViewEvent }

    init(viewModel: EditEventFrequencyViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        InstUI.BaseScreen(state: viewModel.state, config: viewModel.screenConfig) { geometry in
            VStack(alignment: .leading, spacing: 0) {
                ForEach(viewModel.frequencyChoices) { choice in
                    ChoiceButton(
                        title: choice.title,
                        selected: viewModel.selection == choice.preset) {
                            viewModel.selection = choice.preset
                        }
                    InstUI.Divider()
                }

                ChoiceButton(
                    title: String(localized: "Custom", bundle: .core),
                    selected: viewModel.selection.isCustom) {
                        viewModel.didSelectCustomFrequency.send(viewController)
                    }
                InstUI.Divider()

                Spacer()
            }
            .frame(minHeight: geometry.size.height)
        }
        .navigationTitle(viewModel.pageTitle)
        .onDisappear {
            viewModel.didTapBack.send()
        }
    }
}

struct ChoiceButton: View {
    let title: String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(
            action: action,
            label: {
                HStack {
                    Text(title)
                        .font(.regular14, lineHeight: .fit)
                        .foregroundStyle(Color.textDarkest)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer()
                    InstUI.Icons.Checkmark()
                        .foregroundStyle(Color.textDarkest)
                        .layoutPriority(1)
                        .opacity(selected ? 1 : 0)
                }
                .paddingStyle(set: .standardCell)
                .contentShape(Rectangle())
            })
        .buttonStyle(.plain)
        .contentShape(Rectangle())
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}

#if DEBUG

#Preview {
    EditEventFrequencyScreen(
        viewModel: EditEventFrequencyViewModel(
            eventDate: Date(),
            selectedFrequency: nil,
            originalPreset: nil,
            router: AppEnvironment.shared.router,
            completion: { _ in }
        )
    )
}

#endif
