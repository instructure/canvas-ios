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

protocol CourseSyncProgressInteractor {
    func getFileProgress() -> AnyPublisher<ReactiveStore<LocalUseCase<CourseSyncFileProgress>>.State, Never>
    func getCourseSyncProgressEntries() -> AnyPublisher<[CourseSyncEntry], Error>
    func setCollapsed(selection: CourseEntrySelection, isCollapsed: Bool)
    func cancelSync()
    func retrySync()
}

final class CourseSyncProgressInteractorLive: CourseSyncProgressInteractor {
    private let fileFolderInteractor: CourseSyncFileFolderInteractor
    private let progressObserverInteractor: CourseSyncProgressObserverInteractor

    private let courseListStore = ReactiveStore(
        useCase: GetCourseSyncSelectorCourses()
    )
    private let courseSyncEntries = CurrentValueSubject<[CourseSyncEntry], Error>(.init())
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Progress info view
    init(
        fileFolderInteractor: CourseSyncFileFolderInteractor = CourseSyncFileFolderInteractorLive(),
        progressObserverInteractor: CourseSyncProgressObserverInteractor = CourseSyncProgressObserverInteractorLive()
    ) {
        self.fileFolderInteractor = fileFolderInteractor
        self.progressObserverInteractor = progressObserverInteractor
    }

    func getFileProgress() -> AnyPublisher<ReactiveStore<LocalUseCase<CourseSyncFileProgress>>.State, Never> {
        progressObserverInteractor.observeFileProgress()
    }

    func getCourseSyncProgressEntries() -> AnyPublisher<[CourseSyncEntry], Error> {
        unowned let unownedSelf = self

        return courseListStore.getEntitiesFromDatabase()
            .flatMap { Publishers.Sequence(sequence: $0).setFailureType(to: Error.self) }
            .flatMap { unownedSelf.fileFolderInteractor.getAllFiles(course: $0) }
            .collect()
            .replaceEmpty(with: [])
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
        progressObserverInteractor.observeEntryProgress()
            .flatMap { state -> AnyPublisher<[CourseSyncEntryProgress], Never> in
                switch state {
                case .data(let progressList):
                    guard progressList.count > 0 else {
                        return Empty(completeImmediately: false).eraseToAnyPublisher()
                    }
                    return Just(progressList).eraseToAnyPublisher()
                default:
                    return Empty(completeImmediately: false).eraseToAnyPublisher()
                }
            }
            .sink { [weak self] progressList in
                progressList.forEach {
                    self?.setState(id: $0.id, selection: $0.selection, state: $0.state)
                }
            }
            .store(in: &subscriptions)
    }

    private func setState(id: String, selection: CourseEntrySelection, state: CourseSyncEntry.State) {
        var entries = courseSyncEntries.value

        switch selection {
        case let .course(courseID):
            entries[id: courseID]?.updateCourseState(state: state)
        case let .tab(courseID, tabID):
            entries[id: courseID]?.updateTabState(id: tabID, state: state)
        case let .file(courseID, fileID):
            entries[id: courseID]?.updateFileState(id: fileID, state: state)
        }

        courseSyncEntries.send(entries)
    }

    func setCollapsed(selection: CourseEntrySelection, isCollapsed: Bool) {
        var entries = courseSyncEntries.value

        switch selection {
        case let .course(courseID):
            entries[id: courseID]?.isCollapsed = isCollapsed
        case let .tab(courseID, tabID):
            entries[id: courseID]?.tabs[id: tabID]?.isCollapsed = isCollapsed
        case .file:
            break
        }

        courseSyncEntries.send(entries)
    }

    func cancelSync() {
    }

    func retrySync() {
    }
}
