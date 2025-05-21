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

public struct MultiSelectionView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @StateObject private var viewModel: MultiSelectionViewModel

    private let accessibilityIdentifier: String?
    private let hasAllSelectionButton: Bool

    public init(
        title: String?,
        accessibilityIdentifier: String? = nil,
        hasAllSelectionButton: Bool = false,
        allOptions: [OptionItem],
        selectedOptions: CurrentValueSubject<Set<OptionItem>, Never>
    ) {
        self.accessibilityIdentifier = accessibilityIdentifier
        self.hasAllSelectionButton = hasAllSelectionButton

        self._viewModel = StateObject(wrappedValue: .init(
            title: title,
            allOptions: allOptions,
            selectedOptions: selectedOptions
        ))
    }

    public init(
        title: String?,
        accessibilityIdentifier: String? = nil,
        hasAllSelectionButton: Bool = false,
        options: MultiSelectionOptions
    ) {
        self.init(
            title: title,
            accessibilityIdentifier: accessibilityIdentifier,
            hasAllSelectionButton: hasAllSelectionButton,
            allOptions: options.all,
            selectedOptions: options.selected
        )
    }

    @ViewBuilder
    public var body: some View {
        LazyVStack(spacing: 0) {
            Section {
                ForEach(viewModel.allOptions) { item in
                    optionCell(with: item)
                }
            } header: {
                if hasAllSelectionButton {
                    InstUI.ListSectionHeader(
                        title: viewModel.title,
                        itemCount: viewModel.optionCount,
                        buttonLabel: Text(viewModel.allSelectionButtonTitle),
                        buttonAction: { viewModel.didTapAllSelectionButton.send() }
                    )
                } else {
                    InstUI.ListSectionHeader(title: viewModel.title, itemCount: viewModel.optionCount)
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(viewModel.listLevelAccessibilityLabel)
    }

    @ViewBuilder
    private func optionCell(with item: OptionItem) -> some View {
        InstUI.CheckboxCell(
            title: item.title,
            subtitle: item.subtitle,
            isSelected: selectionBinding(for: item),
            color: item.color,
            accessoryView: { item.accessoryIcon?.foregroundStyle(item.color) },
            dividerStyle: viewModel.dividerStyle(for: item)
        )
        .accessibilityIdentifier(accessibilityIdentifier(for: item))
    }

    private func selectionBinding(for item: OptionItem) -> Binding<Bool> {
        Binding {
            viewModel.isOptionSelected(item)
        } set: { newValue in
            viewModel.didToggleSelection.send((option: item, isSelected: newValue))
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
        MultiSelectionView(
            title: "Section 1 title",
            accessibilityIdentifier: nil,
            allOptions: [
                .make(id: "1", title: "Option 1"),
                .make(id: "2", title: "Option 2"),
                .make(id: "3", title: "Option 3")
            ],
            selectedOptions: .init([])
        )
        MultiSelectionView(
            title: "Section 2 title",
            accessibilityIdentifier: nil,
            hasAllSelectionButton: true,
            allOptions: [
                .make(id: "A", title: "Option A", color: .textDanger),
                .make(id: "B", title: "Option B", color: .textSuccess),
                .make(id: "C", title: "Option C", color: .textInfo)
            ],
            selectedOptions: .init([])
        )
    }
}

#endif
