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

public struct OptionItem: Equatable, Identifiable {
    public static let allId = "_this_is_an_unlikely_id_preserved_for_the_all_option_"

    public let id: String
    public let title: String
    public let subtitle: String?
    public let color: Color
    public let accessoryIcon: Image?

    public init(
        id: String,
        title: String,
        subtitle: String? = nil,
        color: Color = Color(uiColor: Brand.shared.primary),
        accessoryIcon: Image? = nil
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.color = color
        self.accessoryIcon = accessoryIcon
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}

public struct OptionsSectionView: View {

    public enum SelectionType {
        case single
        case multi
    }

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @StateObject private var viewModel: OptionsSectionSingleSelectionViewModel

    private let title: String?
    private let options: [OptionItem]
    private let selectionType: SelectionType
    private let hasSelectAllButton: Bool

    public init(
        title: String?,
        options: [OptionItem],
        selectionType: SelectionType,
        hasSelectAllButton: Bool = false,
        selectedOption: CurrentValueSubject<OptionItem?, Never>
    ) {
        self.title = title
        self.options = options
        self.selectionType = selectionType
        self.hasSelectAllButton = hasSelectAllButton

        self._viewModel = StateObject(wrappedValue: .init(selectedOption: selectedOption))
    }

    @ViewBuilder
    public var body: some View {
        LazyVStack(spacing: 0) {
            Section {
                ForEach(options) { item in
                    itemCell(with: item)
                }
            } header: {
                InstUI.ListSectionHeader(title: title)
            }
        }
    }

    private var selectionBinding: Binding<OptionItem?> {
        Binding {
            viewModel.selectedOption.value
        } set: { selectedValue in
            viewModel.selectedOption.send(selectedValue)
        }
    }

    @ViewBuilder
    private func itemCell(with item: OptionItem) -> some View {
        if selectionType == .single {
            InstUI.RadioButtonCell(
                title: item.title,
                value: item,
                selectedValue: selectionBinding,
                color: item.color,
                dividerStyle: item.id == options.last?.id ? .full : .padded
            )
        } else {
            InstUI.CheckboxCell(
                title: item.title,
                isSelected: .constant(false),
                color: item.color
            )
        }
    }
}

final class OptionsSectionSingleSelectionViewModel: ObservableObject {

    let selectedOption: CurrentValueSubject<OptionItem?, Never>

    private var subscriptions = Set<AnyCancellable>()

    init(selectedOption: CurrentValueSubject<OptionItem?, Never>) {
        self.selectedOption = selectedOption

        selectedOption
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &subscriptions)
    }
}
