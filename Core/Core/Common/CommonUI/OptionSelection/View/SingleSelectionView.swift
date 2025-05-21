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

import Combine
import SwiftUI

public struct SingleSelectionView: View {

    public enum Style {
        case radioButton
        case trailingCheckmark
    }

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @StateObject private var viewModel: SingleSelectionViewModel

    private let accessibilityIdentifier: String?
    private let style: Style

    public init(
        title: String?,
        accessibilityIdentifier: String? = nil,
        allOptions: [OptionItem],
        selectedOption: CurrentValueSubject<OptionItem?, Never>,
        style: Style = .radioButton
    ) {
        self.accessibilityIdentifier = accessibilityIdentifier
        self.style = style

        self._viewModel = StateObject(wrappedValue: .init(
            title: title,
            allOptions: allOptions,
            selectedOption: selectedOption
        ))
    }

    public init(
        title: String?,
        accessibilityIdentifier: String? = nil,
        options: SingleSelectionOptions,
        style: Style = .radioButton
    ) {
        self.init(
            title: title,
            accessibilityIdentifier: accessibilityIdentifier,
            allOptions: options.all,
            selectedOption: options.selected,
            style: style
        )
    }

    @ViewBuilder
    public var body: some View {
        LazyVStack(spacing: 0) {
            Section {
                ForEach(viewModel.allOptions) { item in
                    optionCell(with: item)
                        .accessibilityIdentifier(accessibilityIdentifier(for: item))
                }
            } header: {
                InstUI.ListSectionHeader(title: viewModel.title, itemCount: viewModel.optionCount)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(viewModel.listLevelAccessibilityLabel)
    }

    @ViewBuilder
    private func optionCell(with item: OptionItem) -> some View {
        switch style {
        case .radioButton:
            InstUI.RadioButtonCell(
                title: item.title,
                value: item,
                selectedValue: selectionBinding,
                color: item.color,
                dividerStyle: viewModel.dividerStyle(for: item)
            )
        case .trailingCheckmark:
            InstUI.TrailingCheckmarkCell(
                title: item.title,
                subtitle: item.subtitle,
                value: item,
                selectedValue: selectionBinding,
                color: item.color,
                dividerStyle: viewModel.dividerStyle(for: item)
            )
        }
    }

    private var selectionBinding: Binding<OptionItem?> {
        Binding {
            viewModel.selectedOption.value
        } set: { selectedValue in
            viewModel.selectedOption.send(selectedValue)
        }
    }

    private func accessibilityIdentifier(for item: OptionItem) -> String {
        [accessibilityIdentifier, item.id].joined(separator: ".")
    }
}

#if DEBUG

#Preview {
    VStack(spacing: 0) {
        InstUI.Divider()
        SingleSelectionView(
            title: "Radio group",
            accessibilityIdentifier: nil,
            allOptions: [
                .make(id: "1", title: "Option 1"),
                .make(id: "2", title: "Option 2"),
                .make(id: "3", title: "Option 3")
            ],
            selectedOption: .init(nil)
        )
        SingleSelectionView(
            title: "Radio group with colors",
            accessibilityIdentifier: nil,
            allOptions: [
                .make(id: "A", title: "Option A", color: .textDanger),
                .make(id: "B", title: "Option B", color: .textSuccess),
                .make(id: "C", title: "Option C", color: .textInfo)
            ],
            selectedOption: .init(nil)
        )
        SingleSelectionView(
            title: "Item picker",
            accessibilityIdentifier: nil,
            allOptions: [
                .make(id: "A", title: "Option A", color: .textDanger),
                .make(id: "B", title: "Option B", color: .textSuccess),
                .make(id: "C", title: "Option C", color: .textInfo)
            ],
            selectedOption: .init(nil),
            style: .trailingCheckmark
        )
    }
}

#endif
