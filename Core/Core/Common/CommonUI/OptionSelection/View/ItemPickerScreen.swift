//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

public struct ItemPickerScreen: View {

    private let pageTitle: String
    private let identifierGroup: String?

    private let allOptions: [OptionItem]
    private let selectedOption: CurrentValueSubject<OptionItem?, Never>

    private let didSelectOption: ((OptionItem) -> Void)?

    public init(
        pageTitle: String,
        identifierGroup: String? = nil,
        allOptions: [OptionItem],
        selectedOption: CurrentValueSubject<OptionItem?, Never>
    ) {
        self.pageTitle = pageTitle
        self.identifierGroup = identifierGroup
        self.allOptions = allOptions
        self.selectedOption = selectedOption
        self.didSelectOption = nil
    }

    public init(
        pageTitle: String,
        identifierGroup: String? = nil,
        allOptions: [OptionItem],
        initialOptionId: String?,
        didSelectOption: @escaping (OptionItem) -> Void
    ) {
        self.pageTitle = pageTitle
        self.identifierGroup = identifierGroup
        self.allOptions = allOptions
        self.selectedOption = .init(allOptions.option(with: initialOptionId))
        self.didSelectOption = didSelectOption
    }

    public init(
        pageTitle: String,
        identifierGroup: String? = nil,
        options: SingleSelectionOptions
    ) {
        self.init(
            pageTitle: pageTitle,
            identifierGroup: identifierGroup,
            allOptions: options.all,
            selectedOption: options.selected
        )
    }

    public var body: some View {
        InstUI.BaseScreen(state: .data, config: .init(refreshable: false, scrollBounce: .automatic)) { _ in
            SingleSelectionView(
                title: nil,
                identifierGroup: identifierGroup,
                allOptions: allOptions,
                selectedOption: selectedOption,
                style: .trailingCheckmark
            )
        }
        .navigationBarTitleView(pageTitle)
        .navigationBarStyle(.modal)
        .onReceive(selectedOption.dropFirst().compactMap(\.self)) { option in
            didSelectOption?(option)
        }
    }
}
