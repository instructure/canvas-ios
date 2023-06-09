//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

public struct DashboardSettingsView: View {
    @ObservedObject private var viewModel: DashboardSettingsViewModel
    private let horizontalPadding: CGFloat = 16
    private let verticalPadding: CGFloat = 24

    public init(viewModel: DashboardSettingsViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                header(label: Text("Display As", bundle: .core))
                HStack(spacing: 0) {
                    Spacer()
                    gridButton
                    Spacer()
                    listButton
                    Spacer()
                }
                .padding(EdgeInsets(top: 32, leading: 16, bottom: 24, trailing: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.borderMedium, lineWidth: 0.5)
                )
                .padding(.bottom, 32)
                header(label: Text("Options", bundle: .core))
                separator
                if viewModel.isGradesSwitchVisible {
                    toggle(text: Text("Show Grades", bundle: .core),
                           isOn: $viewModel.showGrades,
                           a11yID: "DashboardSettings.Switch.Grades")
                    .accessibilityIdentifier("DashboardSettings.showGradesToggle")
                    separator
                }
                if viewModel.isColorOverlaySwitchVisible {
                    toggle(text: Text("Color Overlay", bundle: .core),
                           isOn: $viewModel.colorOverlay,
                           a11yID: "DashboardSettings.Switch.ColorOverlay")
                }
                separator
                Spacer()
            }
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
        }
        .background(Color.backgroundLightest.ignoresSafeArea())
        .navigationBarStyle(.modalLight)
        .navigationTitle(Text("Dashboard Settings", bundle: .core))
    }

    private func header(label: Text) -> some View {
        label
            .font(.semibold14)
            .foregroundColor(.textDark)
            .accessibility(addTraits: .isHeader)
            .padding(.bottom, 8)
    }

    private var separator: some View {
        Color.borderMedium
            .frame(height: 0.5)
            .padding(.horizontal, -horizontalPadding)
    }

    private func toggle(text: Text, isOn: Binding<Bool>, a11yID: String) -> some View {
        Toggle(isOn: isOn) {
            text
                .font(.semibold16)
                .foregroundColor(.textDarkest)
        }
        .toggleStyle(SwitchToggleStyle(tint: Color(Brand.shared.primary)))
        .padding(.vertical, 8)
        .testID(a11yID, info: ["selected": isOn.wrappedValue])
    }

    private var gridButton: some View {
        layoutButton(label: Text("Grid", bundle: .core),
                     icon: .dashboardLayoutGrid,
                     isSelected: viewModel.layout == .grid,
                     action: { viewModel.setLayout.send(.grid) })
    }

    private var listButton: some View {
        layoutButton(label: Text("List", bundle: .core),
                     icon: .dashboardLayoutList,
                     isSelected: viewModel.layout == .list,
                     action: { viewModel.setLayout.send(.list) })
    }

    private func layoutButton(label: Text,
                              icon: Image,
                              isSelected: Bool,
                              action: @escaping () -> Void)
    -> some View {
        Button {
            action()
        } label: {
            VStack(spacing: 3) {
                icon
                label
                    .padding(.top, 8)
                    .padding(.bottom, 10)
                    .font(.regular14)
                (isSelected ? Image.publishSolid : Image.emptyLine)
                    .foregroundColor(Color(Brand.shared.primary))
            }
            .foregroundColor(.textDarkest)
            .accessibilityHidden(true)
        }
        .accessibilityLabel(label)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#if DEBUG

struct DashboardSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        let interactor1 = DashboardSettingsInteractorPreview()
        let viewModel1 = DashboardSettingsViewModel(interactor: interactor1)
        DashboardSettingsView(viewModel: viewModel1)
            .frame(width: 400)
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Both Switches")

        let interactor2 = DashboardSettingsInteractorPreview(isGradesSwitchVisible: false)
        let viewModel2 = DashboardSettingsViewModel(interactor: interactor2)
        DashboardSettingsView(viewModel: viewModel2)
            .frame(width: 400)
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Color Switch Only")
    }
}

#endif
