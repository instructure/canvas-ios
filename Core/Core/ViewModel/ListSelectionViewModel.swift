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

import Combine
import SwiftUI

/**
 This class can be used to keep track of a list's selected cell which we want to get a selection indicator even after the user released its finger.
 When the view appears the selection is set back to the default selection if the split view in in split mode.
 */
public class ListSelectionViewModel: ObservableObject {
    @Published public private(set) var selectedIndex: Int?
    public var selectedIndexPublisher: AnyPublisher<Int?, Never> { selectedCellIndexChanged.removeDuplicates().eraseToAnyPublisher() }
    /** A split view's state should be binded here. Use `SplitViewModeObserver`. */
    public let isSplitViewCollapsed = CurrentValueSubject<Bool, Never>(false)

    private let selectedCellIndexChanged = CurrentValueSubject<Int?, Never>(nil)
    private let defaultSelection: Int?
    private var subscriptions = Set<AnyCancellable>()

    public init(defaultSelection: Int?) {
        self.defaultSelection = defaultSelection
        bindInternalStateToPublishedProperty()
        bindSplitViewStateToInternalState()
        selectedCellIndexChanged.send(defaultSelection)
    }

    public func cellTapped(at index: Int) {
        selectedCellIndexChanged.send(index)
    }

    public func viewDidAppear() {
        let newSelection = isSplitViewCollapsed.value ? nil : defaultSelection
        selectedCellIndexChanged.send(newSelection)
    }

    private func bindInternalStateToPublishedProperty() {
        selectedCellIndexChanged
            .assign(to: &$selectedIndex)
    }

    private func bindSplitViewStateToInternalState() {
        isSplitViewCollapsed
            .map { [weak self] in $0 ? nil : self?.defaultSelection }
            .subscribe(selectedCellIndexChanged)
            .store(in: &subscriptions)
    }
}
