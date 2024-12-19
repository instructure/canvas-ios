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

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @StateObject private var viewModel: SingleSelectionViewModel

    private let title: String?
    private let accessibilityIdentifier: String?

    public init(
        title: String?,
        accessibilityIdentifier: String? = nil,
        allOptions: [OptionItem],
        selectedOption: CurrentValueSubject<OptionItem?, Never>
    ) {
        self.title = title
        self.accessibilityIdentifier = accessibilityIdentifier

        self._viewModel = StateObject(wrappedValue: .init(
            allOptions: allOptions,
            selectedOption: selectedOption
        ))
    }

    public init(
        title: String?,
        accessibilityIdentifier: String? = nil,
        options: SingleSelectionOptions
    ) {
        self.init(
            title: title,
            accessibilityIdentifier: accessibilityIdentifier,
            allOptions: options.all,
            selectedOption: options.selected
        )
    }

    // TODO: remove
    public init(
        title: String?,
        accessibilityIdentifier: String? = nil,
        options: [OptionItem],
        selectedOption: CurrentValueSubject<OptionItem?, Never>
    ) {
        self.init(
            title: title,
            accessibilityIdentifier: accessibilityIdentifier,
            allOptions: options,
            selectedOption: selectedOption
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
                InstUI.ListSectionHeader(title: title)
            }
        }
    }

    @ViewBuilder
    private func optionCell(with item: OptionItem) -> some View {
        InstUI.RadioButtonCell(
            title: item.title,
            value: item,
            selectedValue: selectionBinding,
            color: item.color,
            dividerStyle: viewModel.dividerStyle(for: item)
        )
        .accessibilityIdentifier(accessibilityIdentifier(for: item))
    }

    private var selectionBinding: Binding<OptionItem?> {
        Binding {
            viewModel.selectedOption.value
        } set: { selectedValue in
            viewModel.selectedOption.send(selectedValue)
        }
    }

    private func accessibilityIdentifier(for item: OptionItem) -> String {
        [accessibilityIdentifier ?? "", item.id]
            .compactMap { $0 }
            .joined(separator: ".")
    }
}
