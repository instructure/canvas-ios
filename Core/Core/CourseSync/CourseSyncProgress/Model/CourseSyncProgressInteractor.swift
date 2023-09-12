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
import CombineSchedulers
import CoreData
import Foundation

protocol CourseSyncProgressInteractor: AnyObject {
    func observeDownloadProgress() -> AnyPublisher<CourseSyncDownloadProgress, Never>
    func observeEntries() -> AnyPublisher<[CourseSyncEntry], Error>
    func setCollapsed(selection: CourseEntrySelection, isCollapsed: Bool)
    func cancelSync()
    func retrySync()
}

final class CourseSyncProgressInteractorLive: CourseSyncProgressInteractor {
    private struct StateProgress: Hashable {
        let id: String
        var selection: CourseEntrySelection
        var state: CourseSyncEntry.State

        init(from entity: CourseSyncStateProgress) {
            id = entity.id
            selection = entity.selection
            state = entity.state
        }

        mutating func update(with entity: CourseSyncStateProgress) {
            selection = entity.selection
            state = entity.state
        }
    }

    private let courseSyncListInteractor: CourseSyncListInteractor
    private let progressObserverInteractor: CourseSyncProgressObserverInteractor
    private let sessionDefaults: SessionDefaults
    private let scheduler: AnySchedulerOf<DispatchQueue>
    private let context: NSManagedObjectContext

    private lazy var courseListStore = ReactiveStore(
        context: context,
        useCase: GetCourseSyncSelectorCourses()
    )
    private let backgroundQueue = DispatchQueue(
        label: "com.instructure.icanvas.core.course-sync-progress-utility",
        attributes: .concurrent
    )
    private var safeCourseSyncEntriesValue: [CourseSyncEntry] {
        backgroundQueue.sync {
            courseSyncEntries.value
        }
    }

    private let courseSyncEntries = CurrentValueSubject<[CourseSyncEntry], Error>(.init())
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Progress info view

    init(
        courseSyncListInteractor: CourseSyncListInteractor = CourseSyncListInteractorLive(),
        progressObserverInteractor: CourseSyncProgressObserverInteractor = CourseSyncProgressObserverInteractorLive(),
        sessionDefaults: SessionDefaults = AppEnvironment.shared.userDefaults ?? .fallback,
        container: NSPersistentContainer = AppEnvironment.shared.database,
        scheduler: AnySchedulerOf<DispatchQueue> = DispatchQueue(
            label: "com.instructure.icanvas.core.course-sync-progress"
        ).eraseToAnyScheduler()
    ) {
        self.courseSyncListInteractor = courseSyncListInteractor
        self.progressObserverInteractor = progressObserverInteractor
        self.sessionDefaults = sessionDefaults
        self.scheduler = scheduler
        context = container.newBackgroundContext()
        context.automaticallyMergesChangesFromParent = true
    }

    func observeDownloadProgress() -> AnyPublisher<CourseSyncDownloadProgress, Never> {
        progressObserverInteractor
            .observeDownloadProgress()
            .receive(on: scheduler)
            .eraseToAnyPublisher()
    }

    func observeEntries() -> AnyPublisher<[CourseSyncEntry], Error> {
        unowned let unownedSelf = self

        return courseSyncListInteractor.getCourseSyncEntries(filter: .synced)
            .handleEvents(
                receiveOutput: {
                    unownedSelf.courseSyncEntries.send($0)
                    unownedSelf.observeEntryProgress()
                },
                receiveCompletion: { completion in
                    switch completion {
                    case let .failure(error):
                        unownedSelf.courseSyncEntries.send(completion: .failure(error))
                    default:
                        break
                    }
                }
            )
            .flatMap { _ in unownedSelf.courseSyncEntries.eraseToAnyPublisher() }
            .eraseToAnyPublisher()
    }

    private func observeEntryProgress() {
        progressObserverInteractor.observeStateProgress()
            .receive(on: scheduler)
            .throttle(for: .milliseconds(300), scheduler: scheduler, latest: true)
            .map { $0.map { StateProgress(from: $0) } }
            .map { Set($0) }
            .scan((Set([]), Set([]))) { ($0.1, $1) } // Access previous and current published element
            .map { $1.subtracting($0) } // Substract previous elements from current
            .map { Array($0) }
            .sink { [weak self] progressList in
                self?.setState(newList: progressList)
            }
            .store(in: &subscriptions)
    }

    private func setState(newList: [StateProgress]) {
        var entries = safeCourseSyncEntriesValue

        for progress in newList {
            switch progress.selection {
            case let .course(entryID):
                entries[id: entryID]?.updateCourseState(state: progress.state)
            case let .tab(entryID, tabID):
                entries[id: entryID]?.updateTabState(id: tabID, state: progress.state)
            case let .file(entryID, fileID):
                entries[id: entryID]?.updateFileState(id: fileID, state: progress.state)
            }
        }

        backgroundQueue.sync(flags: .barrier) {
            courseSyncEntries.send(entries)
        }
    }

    func setCollapsed(selection: CourseEntrySelection, isCollapsed: Bool) {
        switch selection {
        case let .course(entryID):
            backgroundQueue.sync(flags: .barrier) {
                courseSyncEntries.value[id: entryID]?.isCollapsed = isCollapsed
            }
        case let .tab(entryID, tabID):
            backgroundQueue.sync(flags: .barrier) {
                courseSyncEntries.value[id: entryID]?.tabs[id: tabID]?.isCollapsed = isCollapsed
            }
        case .file:
            break
        }
    }

    func cancelSync() {
        NotificationCenter.default.post(name: .OfflineSyncCancelled, object: nil)
    }

    func retrySync() {
        NotificationCenter.default.post(name: .OfflineSyncTriggered, object: safeCourseSyncEntriesValue)
    }
}
