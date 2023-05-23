//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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
import CombineExt
import Foundation

class CourseSyncSettingsViewModel: ObservableObject {

    // MARK: - Input
    public let syncFrequencyDidTap = PassthroughRelay<WeakViewController>()

    // MARK: - Private
    private var subscriptions = Set<AnyCancellable>()

    public init() {
        handleSyncFrequencyTap()
    }

    private func handleSyncFrequencyTap() {
        let pickerItems = ItemPickerSection(items: [
            .init(title: NSLocalizedString("Daily", comment: "")),
            .init(title: NSLocalizedString("Weekly", comment: "")),
        ])

        syncFrequencyDidTap
            .map { sourceController in
                let picker = ItemPickerViewController.create(title: NSLocalizedString("Sync Frequency", comment: ""),
                                                             sections: [pickerItems],
                                                             selected: IndexPath(row: 0, section: 0)) { indexPath in
                    // Update selection
                }

                return (picker: picker, source: sourceController)
            }
            .sink {
                $0.source.value.show($0.picker, sender: self)
            }
            .store(in: &subscriptions)
    }
}
