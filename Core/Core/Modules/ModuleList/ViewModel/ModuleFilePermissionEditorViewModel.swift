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

class ModuleFilePermissionEditorViewModel: ObservableObject {
    // Outputs
    @Published public private(set) var isLoading = false
    @Published public private(set) var isScheduleDateSectionVisible = false
    @Published public private(set) var selectedAvailability: FileAvailability = .publish
    @Published public private(set) var selectedVisibility: FileVisibility = .inheritCourse
    @Published public private(set) var availableFrom: Date?
    @Published public private(set) var availableUntil: Date?
    public let defaultAvailableDate = Date().startOfDay()

    // Inputs
    public let cancelDidPress = PassthroughSubject<UIViewController, Never>()
    public let doneDidPress = PassthroughSubject<UIViewController, Never>()
    public let availabilityDidSelect = PassthroughSubject<FileAvailability, Never>()
    public let visibilityDidSelect = PassthroughSubject<FileVisibility, Never>()
    public let availableFromDidSelect = PassthroughSubject<Date?, Never>()
    public let availableUntilDidSelect = PassthroughSubject<Date?, Never>()

    private let router: Router
    private var subscriptions = Set<AnyCancellable>()

    init(router: Router) {
        self.router = router
        availabilityDidSelect
            .assign(to: &$selectedAvailability)
        availabilityDidSelect
            .map { $0 == .scheduleAvailability }
            .assign(to: &$isScheduleDateSectionVisible)
        visibilityDidSelect
            .assign(to: &$selectedVisibility)
        availableFromDidSelect
            .assign(to: &$availableFrom)
        availableUntilDidSelect
            .assign(to: &$availableUntil)
    }
}
