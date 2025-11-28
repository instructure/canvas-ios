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

    private let identifierGroup: String?
    private let style: Style

    public init(
        title: String?,
        identifierGroup: String? = nil,
        allOptions: [OptionItem],
        selectedOption: CurrentValueSubject<OptionItem?, Never>,
        style: Style = .radioButton
    ) {
        self.identifierGroup = identifierGroup
        self.style = style

        self._viewModel = StateObject(wrappedValue: .init(
            title: title,
            allOptions: allOptions,
            selectedOption: selectedOption
        ))
    }

    public init(
        title: String?,
        identifierGroup: String? = nil,
        options: SingleSelectionOptions,
        style: Style = .radioButton
    ) {
        self.init(
            title: title,
            identifierGroup: identifierGroup,
            allOptions: options.all,
            selectedOption: options.selected,
            style: style
        )
    }

    /// This init allows for separated did select notifications.
    /// This is useful if we want to avoid `selectedOption` to publish when it gets a value from outside.
    /// When a value is selected `selectOption` won't publish, only `didSelectOption` will.
    public init(
        title: String?,
        identifierGroup: String? = nil,
        allOptions: [OptionItem],
        selectOption: CurrentValueSubject<OptionItem?, Never>,
        didSelectOption: PassthroughSubject<OptionItem?, Never>,
        style: Style = .radioButton
    ) {
        self.identifierGroup = identifierGroup
        self.style = style

        self._viewModel = StateObject(wrappedValue: .init(
            title: title,
            allOptions: allOptions,
            selectedOption: selectOption,
            didSelectOption: didSelectOption
        ))
    }

    public var body: some View {
        VStack(spacing: 0) {
            Section {
                ForEach(viewModel.allOptions) { item in
                    optionCell(with: item)
                        .identifier(identifierGroup, item.id)
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
                headerTitle: item.headerTitle,
                subtitle: item.subtitle,
                value: item,
                selectedValue: selectionBinding,
                dividerStyle: viewModel.dividerStyle(for: item)
            )
            .customTint(item.color)
        case .trailingCheckmark:
            InstUI.TrailingCheckmarkCell(
                title: item.title,
                headerTitle: item.headerTitle,
                subtitle: item.subtitle,
                value: item,
                selectedValue: selectionBinding,
                dividerStyle: viewModel.dividerStyle(for: item)
            )
            .customTint(item.color)
        }
    }

    private var selectionBinding: Binding<OptionItem?> {
        Binding {
            viewModel.selectedOption
        } set: {
            if let didSelectOption = viewModel.didSelectOption {
                didSelectOption.send($0)
            } else {
                viewModel.selectedOptionSubject.send($0)
            }
        }
    }
}

#if DEBUG

#Preview {
    VStack(spacing: 0) {
        InstUI.Divider()
        SingleSelectionView(
            title: "Radio group",
            allOptions: [
                .make(id: "1", title: "Option 1"),
                .make(id: "2", title: "Option 2"),
                .make(id: "3", title: "Option 3")
            ],
            selectedOption: .init(nil)
        )
        SingleSelectionView(
            title: "Radio group with colors",
            allOptions: [
                .make(id: "A", title: "Option A", headerTitle: "Header", subtitle: "Subtitle", color: .textDanger),
                .make(id: "B", title: "Option B", color: .textSuccess),
                .make(id: "C", title: "Option C", color: .textInfo)
            ],
            selectedOption: .init(nil)
        )
        .tint(.green)
        SingleSelectionView(
            title: "Item picker",
            allOptions: [
                .make(id: "A", title: "Option A", headerTitle: "Header", subtitle: "Subtitle", color: .textDanger),
                .make(id: "B", title: "Option B", color: .textSuccess),
                .make(id: "C", title: "Option C", color: .textInfo)
            ],
            selectedOption: .init(.make(id: "B")),
            style: .trailingCheckmark
        )
    }
}

#endif
