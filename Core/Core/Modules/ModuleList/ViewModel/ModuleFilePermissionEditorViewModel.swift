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
    enum State {
        case loading
        case error
        case data
    }
    // Outputs
    @Published public private(set) var state: State = .loading
    @Published public private(set) var isUploading = false
    @Published public private(set) var isDoneButtonActive = true
    @Published public private(set) var isScheduleDateSectionVisible = false
    @Published public private(set) var selectedAvailability: FileAvailability = .published
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

    private typealias Permission = ModulePublishInteractor.FilePermission
    private typealias Context = ModulePublishInteractor.FileContext
    private let router: Router
    private let fileId: String
    private let moduleId: String
    private let moduleItemId: String
    private let courseId: String
    private var subscriptions = Set<AnyCancellable>()

    init(
        fileId: String,
        moduleId: String,
        moduleItemId: String,
        courseId: String,
        interactor: ModulePublishInteractor,
        router: Router
    ) {
        self.fileId = fileId
        self.moduleId = moduleId
        self.moduleItemId = moduleItemId
        self.courseId = courseId
        self.router = router
        availabilityDidSelect
            .assign(to: &$selectedAvailability)
        availabilityDidSelect
            .map { $0 == .scheduledAvailability }
            .assign(to: &$isScheduleDateSectionVisible)
        visibilityDidSelect
            .assign(to: &$selectedVisibility)
        availableFromDidSelect
            .assign(to: &$availableFrom)
        availableUntilDidSelect
            .assign(to: &$availableUntil)
        cancelDidPress
            .sink { [weak router] editor in
                router?.dismiss(editor)
            }
            .store(in: &subscriptions)
        doneDidPress
            .mapToValue(true)
            .assign(to: &$isUploading)
        doneDidPress
            .mapToValue(false)
            .assign(to: &$isDoneButtonActive)
        doneDidPress
            .compactMap { [weak self] host -> (UIViewController, Context, Permission)? in
                guard let self else { return nil }
                return (
                    host,
                    Context(
                        fileId: fileId,
                        moduleId: moduleId,
                        moduleItemId: moduleItemId,
                        courseId: courseId
                    ),
                    Permission(
                        unlockAt: (selectedAvailability == .scheduledAvailability ? availableFrom : nil),
                        lockAt: (selectedAvailability == .scheduledAvailability ? availableUntil : nil),
                        availability: selectedAvailability,
                        visibility: selectedVisibility
                    )
                )
            }
            .flatMap { [interactor] data in
                return interactor
                    .changeFilePublishState(
                        fileContext: data.1,
                        filePermissions: data.2
                    )
                    .map { data.0 }
                    .mapToResult()
            }
            .receive(on: RunLoop.main)
            .sink { [weak self] result in
                guard let self else { return }

                switch result {
                case .failure:
                    isUploading = false
                    isDoneButtonActive = true
                case .success(let host):
                    router.dismiss(host)
                }
            }
            .store(in: &subscriptions)

        interactor
            .getFilePermission(
                fileContext: .init(
                    fileId: fileId,
                    moduleId: moduleId,
                    moduleItemId: moduleItemId,
                    courseId: courseId
                )
            )
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    self?.state = .data
                case .failure:
                    self?.state = .error
                }
            }, receiveValue: { [weak self] filePermission in
                if filePermission.availability == .scheduledAvailability {
                    self?.availableFrom = filePermission.unlockAt
                    self?.availableUntil = filePermission.lockAt
                }

                self?.visibilityDidSelect.send(filePermission.visibility)
                self?.availabilityDidSelect.send(filePermission.availability)
            })
            .store(in: &subscriptions)
    }
}
