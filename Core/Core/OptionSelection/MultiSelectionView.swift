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

    private let title: String?
    private let accessibilityIdentifier: String?
    private let hasSelectAllButton: Bool

    public init(
        title: String?,
        accessibilityIdentifier: String? = nil,
        hasSelectAllButton: Bool = false,
        options: [OptionItem],
        selectedOptions: CurrentValueSubject<Set<OptionItem>, Never>
    ) {
        self.title = title
        self.accessibilityIdentifier = accessibilityIdentifier
        self.hasSelectAllButton = hasSelectAllButton

        self._viewModel = StateObject(wrappedValue: .init(
            options: options,
            selectedOptions: selectedOptions
        ))
    }

    @ViewBuilder
    public var body: some View {
        LazyVStack(spacing: 0) {
            Section {
                ForEach(viewModel.options) { item in
                    optionCell(with: item)
                }
            } header: {
                InstUI.ListSectionHeader(title: title)
            }
        }
    }

    @ViewBuilder
    private func optionCell(with item: OptionItem) -> some View {
        InstUI.CheckboxCell(
            title: item.title,
            subtitle: item.subtitle,
            isSelected: selectionBinding(for: item),
            color: item.color,
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
        [accessibilityIdentifier ?? "", item.id]
            .compactMap { $0 }
            .joined(separator: ".")
    }
}
