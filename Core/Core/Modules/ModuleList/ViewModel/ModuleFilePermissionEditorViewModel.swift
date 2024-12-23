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
import CombineSchedulers
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
    @Published public private(set) var availability: FileAvailability = .published
    @Published public private(set) var visibility: FileVisibility = .inheritCourse
    @Published public private(set) var availableFrom: Date?
    @Published public private(set) var availableUntil: Date?
    @Published public private(set) var defaultFromDate: Date = Date.now.inCalendar.startOfDay()
    @Published public private(set) var defaultUntilDate: Date = Date.now.inCalendar.startOfDay()
    @Published public var showError = false

    // Inputs
    public let cancelDidPress = PassthroughSubject<UIViewController, Never>()
    public let doneDidPress = PassthroughSubject<UIViewController, Never>()
    public let availabilityDidSelect = PassthroughSubject<FileAvailability, Never>()
    public let visibilityDidSelect = PassthroughSubject<FileVisibility, Never>()
    public let availableFromDidSelect = PassthroughSubject<Date?, Never>()
    public let availableUntilDidSelect = PassthroughSubject<Date?, Never>()

    private typealias Permission = ModulePublishInteractorLive.FilePermission
    private typealias Context = ModulePublishInteractorLive.FileContext
    private let router: Router
    private let fileContext: ModulePublishInteractorLive.FileContext
    private var subscriptions = Set<AnyCancellable>()
    private let scheduler: AnySchedulerOf<DispatchQueue>

    init(
        fileContext: ModulePublishInteractorLive.FileContext,
        interactor: ModulePublishInteractor,
        router: Router,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.fileContext = fileContext
        self.router = router
        self.scheduler = scheduler

        availabilityDidSelect
            .assign(to: &$availability)
        availabilityDidSelect
            .map { $0 == .scheduledAvailability }
            .assign(to: &$isScheduleDateSectionVisible)
        visibilityDidSelect
            .assign(to: &$visibility)
        cancelDidPress
            .sink { [weak router] editor in
                router?.dismiss(editor)
            }
            .store(in: &subscriptions)

        handleDateChangeEvents()
        handleDoneButtonPress(interactor: interactor)
        loadInitialState(fileContext: fileContext, interactor: interactor)
    }

    private func loadInitialState(
        fileContext: ModulePublishInteractorLive.FileContext,
        interactor: ModulePublishInteractor
    ) {
        interactor
            .getFilePermission(fileContext: fileContext)
            .receive(on: scheduler)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    self?.state = .data
                case .failure:
                    self?.state = .error
                }
            }, receiveValue: { [weak self] filePermission in
                if filePermission.availability == .scheduledAvailability {
                    self?.availableFromDidSelect.send(filePermission.unlockAt)
                    self?.availableUntilDidSelect.send(filePermission.lockAt)
                }

                self?.visibilityDidSelect.send(filePermission.visibility)
                self?.availabilityDidSelect.send(filePermission.availability)
            })
            .store(in: &subscriptions)

    }

    private func handleDateChangeEvents() {
        availableFromDidSelect
            .assign(to: &$availableFrom)
        availableFromDidSelect
            .map {
                if let date = $0 {
                    return date.inCalendar.addDays(1)
                }
                return Date.now.inCalendar.startOfDay()
            }
            .assign(to: &$defaultUntilDate)

        availableUntilDidSelect
            .assign(to: &$availableUntil)
        availableUntilDidSelect
            .map {
                if let date = $0 {
                    return date.inCalendar.addDays(-1)
                }
                return Date.now.inCalendar.startOfDay()
            }
            .assign(to: &$defaultFromDate)
    }

    private func handleDoneButtonPress(interactor: ModulePublishInteractor) {
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
                    fileContext,
                    Permission(
                        unlockAt: (availability == .scheduledAvailability ? availableFrom : nil),
                        lockAt: (availability == .scheduledAvailability ? availableUntil : nil),
                        availability: availability,
                        visibility: visibility
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
            .receive(on: scheduler)
            .sink { [weak self] result in
                guard let self else { return }

                switch result {
                case .failure:
                    isUploading = false
                    isDoneButtonActive = true
                    showError = true
                case .success(let host):
                    router.dismiss(host)
                }
            }
            .store(in: &subscriptions)
    }
}
