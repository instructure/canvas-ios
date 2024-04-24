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

public struct CalendarFilterScreen: View, ScreenViewTrackable {
    public var screenViewTrackingParameters: ScreenViewTrackingParameters { viewModel.pageViewEvent }

    @ObservedObject private var viewModel: CalendarFilterViewModel

    public init(viewModel: CalendarFilterViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        InstUI.BaseScreen(
            state: viewModel.state,
            refreshAction: viewModel.refresh
        ) { _ in
            VStack(spacing: 0) {
                if let filter = viewModel.userFilter {
                    InstUI.CheckBoxCell(
                        name: filter.name,
                        isSelected: selectionBinding(context: filter.context),
                        color: filter.color
                    )
                }

                if !viewModel.courseFilters.isEmpty {
                    InstUI.ListSectionHeader(name: String(localized: "Courses"))

                    ForEach(viewModel.courseFilters) { filter in
                        InstUI.CheckBoxCell(
                            name: filter.name,
                            isSelected: selectionBinding(context: filter.context),
                            color: filter.color
                        )
                    }
                }

                if !viewModel.groupFilters.isEmpty {
                    InstUI.ListSectionHeader(name: String(localized: "Groups"))

                    ForEach(viewModel.groupFilters) { filter in
                        InstUI.CheckBoxCell(
                            name: filter.name,
                            isSelected: selectionBinding(context: filter.context),
                            color: filter.color
                        )
                    }
                }
            }
        }
        .navigationTitle(viewModel.pageTitle)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.didTapRightNavButton.send()
                } label: {
                    Text(viewModel.rightNavButtonTitle)
                }
            }
        }
    }

    private func selectionBinding(context: Context) -> Binding<Bool> {
        Binding {
            viewModel.selectedContexts.contains(context)
        } set: { newValue in
            viewModel.didToggleSelection.send((context, isSelected: newValue))
        }
    }
}

extension InstUI {

    public struct ListSectionHeader: View {
        private let name: String

        public init(name: String) {
            self.name = name
        }

        public var body: some View {
            VStack(spacing: 0) {
                Text(name)
                    .font(.semibold14)
                    .foregroundStyle(Color.textDark)
                    .paddingStyle(.all, .standard)
                    .frame(maxWidth: .infinity, alignment: .leading)
                InstUI.Divider()
            }
            .background(Color.backgroundLight)
        }
    }
}

extension InstUI {

    public struct CheckBoxCell: View {
        private let name: String
        @Binding private var isSelected: Bool
        private let color: Color

        public init(name: String, isSelected: Binding<Bool>, color: Color) {
            self.name = name
            self._isSelected = isSelected
            self.color = color
        }

        public var body: some View {
            VStack(spacing: 0) {
                Button {
                    isSelected.toggle()
                } label: {
                    HStack(spacing: 18) {
                        InstUI.CheckBox(
                            isSelected: isSelected,
                            color: color
                        )
                        .animation(.default, value: isSelected)
                        Text(name)
                            .font(.regular16, lineHeight: .fit)
                            .multilineTextAlignment(.leading)
                            .foregroundStyle(Color.textDarkest)
                            .frame(maxWidth: .infinity,
                                   alignment: .leading)

                    }
                    .padding(.leading, 22)
                    .paddingStyle(.trailing, .standard)
                    .paddingStyle(.top, .cellTop)
                    .paddingStyle(.bottom, .cellBottom)

                }
                InstUI.Divider()
            }
        }
    }
}

extension InstUI {

    public struct CheckBox: View {
        @ScaledMetric private var uiScale: CGFloat = 1
        private let isSelected: Bool
        private let color: Color

        public init(
            isSelected: Bool,
            color: Color
        ) {
            self.isSelected = isSelected
            self.color = color
        }

        public var body: some View {
            let image: Image = isSelected ? .checkboxSelected : .checkbox
            return image
                .size(uiScale.iconScale * 24)
                .foregroundStyle(color)
        }
    }
}

#if DEBUG

#Preview {
    PlannerAssembly.makeFilterScreenPreview()
}

#endif
