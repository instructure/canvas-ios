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

struct SelectEventFrequencyScreen: View, ScreenViewTrackable {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.viewController) private var viewController

    @ObservedObject private var viewModel: SelectEventFrequencyViewModel

    var screenViewTrackingParameters: ScreenViewTrackingParameters { viewModel.pageViewEvent }

    init(viewModel: SelectEventFrequencyViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        InstUI.BaseScreen(state: viewModel.state, config: viewModel.screenConfig) { geometry in
            VStack(alignment: .leading, spacing: 0) {
                ForEach(viewModel.presetViewModels) { presetVM in
                    FrequencyPresetCell(
                        title: presetVM.title,
                        isSelected: viewModel.selectedPreset == presetVM.preset,
                        action: {
                            viewModel.didTapPreset.send((presetVM.preset, viewController))
                        }
                    )
                }
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

private struct FrequencyPresetCell: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        VStack(spacing: 0) {
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
                            .opacity(isSelected ? 1 : 0)
                    }
                    .paddingStyle(set: .standardCell)
                    .contentShape(Rectangle())
                }
            )
            .buttonStyle(.plain)
            .contentShape(Rectangle())
            .accessibilityAddTraits(isSelected ? .isSelected : [])

            InstUI.Divider()
        }
    }
}

#if DEBUG

#Preview {
    SelectEventFrequencyScreen(
        viewModel: SelectEventFrequencyViewModel(
            eventDate: Date(),
            selectedFrequency: nil,
            originalPreset: nil,
            router: AppEnvironment.shared.router,
            completion: { _ in }
        )
    )
}

#endif
