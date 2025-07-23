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

import Core
import Combine
import CombineSchedulers
import SwiftUI

class SpeedGraderPickerViewModel: ObservableObject {

    let allOptions: [OptionItem]
    @Published private(set) var selectedOption: OptionItem?
    let didSelectOption: PassthroughSubject<OptionItem?, Never>

    @Published private(set) var isSaving: Bool = false

    private let scheduler: AnySchedulerOf<DispatchQueue>
    private var subscriptions = Set<AnyCancellable>()

    init(
        allOptions: [OptionItem],
        selectedOption: CurrentValueSubject<OptionItem?, Never>,
        didSelectOption: PassthroughSubject<OptionItem?, Never>,
        isSaving: CurrentValueSubject<Bool, Never>,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.allOptions = allOptions
        self.selectedOption = selectedOption.value
        self.didSelectOption = didSelectOption
        self.scheduler = scheduler

        selectedOption
            .removeDuplicates()
            .receive(on: scheduler)
            .assign(to: \.selectedOption, on: self, ownership: .weak)
            .store(in: &subscriptions)

        isSaving
            .receive(on: scheduler)
            .assign(to: \.isSaving, on: self, ownership: .weak)
            .store(in: &subscriptions)
    }
}
