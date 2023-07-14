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
import CombineSchedulers
import Foundation
import CombineExt

public protocol CourseSyncInteractor {
    func downloadContent(for entries: [CourseSyncEntry]) -> AnyPublisher<[CourseSyncEntry], Error>
}

public protocol CourseSyncContentInteractor {
    var associatedTabType: TabName { get }
    func getContent(courseId: String) -> AnyPublisher<Void, Error>
}

public final class CourseSyncInteractorLive: CourseSyncInteractor {
    private let contentInteractors: [CourseSyncContentInteractor]
    private let filesInteractor: CourseSyncFilesInteractor
    private let progressWriterInteractor: CourseSyncProgressWriterInteractor
    private let scheduler: AnySchedulerOf<DispatchQueue>
    private var courseSyncEntries = CurrentValueSubject<[CourseSyncEntry], Error>.init([])
    private var safeCourseSyncEntriesValue: [CourseSyncEntry] {
        backgroundQueue.sync {
            courseSyncEntries.value
        }
    }
    private let backgroundQueue = DispatchQueue(
        label: "com.instructure.icanvas.core.course-sync-utility",
        attributes: .concurrent
    )
    private let fileErrorMessage = NSLocalizedString("File download failed.", comment: "")
    private var subscription: AnyCancellable?

    public init(
        contentInteractors: [CourseSyncContentInteractor],
        filesInteractor: CourseSyncFilesInteractor,
        progressWriterInteractor: CourseSyncProgressWriterInteractor,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.contentInteractors = contentInteractors
        self.filesInteractor = filesInteractor
        self.progressWriterInteractor = progressWriterInteractor
        self.scheduler = scheduler
    }

    public func downloadContent(for entries: [CourseSyncEntry]) -> AnyPublisher<[CourseSyncEntry], Error> {
        subscription?.cancel()
        subscription = nil

        unowned let unownedSelf = self

        backgroundQueue.sync(flags: .barrier) {
            courseSyncEntries.send(entries)
        }

        progressWriterInteractor.cleanUpPreviousDownloadProgress()

        subscription = Publishers.Sequence(sequence: entries)
            .buffer(size: .max, prefetch: .byRequest, whenFull: .dropOldest)
            .receive(on: scheduler)
            .flatMap(maxPublishers: .max(3)) { unownedSelf.downloadCourseDetails($0) }
            .collect()
            .handleEvents(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        unownedSelf.setIdleStateForUnfinishedEntries()
                    }
                }
            )
            .sink()

        return courseSyncEntries.eraseToAnyPublisher()
    }

    private func downloadCourseDetails(_ entry: CourseSyncEntry) -> AnyPublisher<Void, Error> {
        unowned let unownedSelf = self

        setState(
            selection: .course(entry.id),
            state: .loading(nil)
        )

        var downloaders = TabName
            .OfflineSyncableTabs
            .filter { $0 != .files } // files are handled separately
            .map { downloadTabContent(for: entry, tabName: $0) }
        downloaders.append(downloadFiles(for: entry))

        return downloaders
            .zip()
            .receive(on: scheduler)
            .updateErrorState {
                unownedSelf.setState(
                    selection: .course(entry.id),
                    state: .error
                )
            }
            .updateDownloadedState {
                unownedSelf.setState(
                    selection: .course(entry.id),
                    state: .downloaded
                )
            }
            .map { _ in () }
            .eraseToAnyPublisher()
    }

    private func downloadTabContent(for entry: CourseSyncEntry, tabName: TabName) -> AnyPublisher<Void, Error> {
        unowned let unownedSelf = self

        guard let tabIndex = entry.tabs.firstIndex(where: { $0.type == tabName }),
              entry.tabs[tabIndex].selectionState == .selected else {
            return Just(())
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        guard let interactor = contentInteractors.first(where: { $0.associatedTabType == tabName }) else {
            assertionFailure("No interactor found for selected tab: \(tabName)")
            return Just(())
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        return interactor.getContent(courseId: entry.courseId)
            .receive(on: scheduler)
            .updateLoadingState {
                unownedSelf.setState(
                    selection: .tab(entry.id, entry.tabs[tabIndex].id),
                    state: .loading(nil)
                )
            }
            .updateErrorState {
                unownedSelf.setState(
                    selection: .tab(entry.id, entry.tabs[tabIndex].id),
                    state: .error
                )
            }
            .updateDownloadedState {
                unownedSelf.setState(
                    selection: .tab(entry.id, entry.tabs[tabIndex].id),
                    state: .downloaded
                )
            }
            .eraseToAnyPublisher()
    }

    private func downloadFiles(for entry: CourseSyncEntry) -> AnyPublisher<Void, Error> {
        guard
            let tabIndex = entry.tabs.firstIndex(where: { $0.type == .files }),
            entry.files.count > 0,
            entry.tabs[tabIndex].selectionState == .selected ||
            entry.tabs[tabIndex].selectionState == .partiallySelected
        else {
            return Just(())
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        unowned let unownedSelf = self

        let files = entry.files.filter { $0.selectionState == .selected }

        unownedSelf.setState(
            selection: .tab(entry.id, entry.tabs[tabIndex].id),
            state: .loading(nil)
        )

        return files.publisher
            .eraseToAnyPublisher()
            .buffer(size: .max, prefetch: .byRequest, whenFull: .dropOldest)
            .receive(on: scheduler)
            .flatMap(maxPublishers: .max(6)) { element in
                let fileIndex = files.firstIndex(of: element)!

                unownedSelf.setState(
                    selection: .file(entry.id, files[fileIndex].id), state: .loading(nil)
                )

                return unownedSelf.filesInteractor.getFile(
                    url: element.url,
                    fileID: element.fileId,
                    fileName: element.fileName,
                    mimeClass: element.mimeClass
                )
                .throttle(for: .milliseconds(300), scheduler: unownedSelf.scheduler, latest: true)
                .tryCatch { error -> AnyPublisher<Float, Error> in
                    unownedSelf.setState(
                        selection: .file(entry.id, files[fileIndex].id), state: .error
                    )
                    unownedSelf.setState(
                        selection: .tab(entry.id, entry.tabs[tabIndex].id), state: .error
                    )
                    throw error
                }
                .eraseToAnyPublisher()
                .handleEvents(
                    receiveOutput: { progress in
                        unownedSelf.setState(
                            selection: .file(entry.id, files[fileIndex].id), state: .loading(progress)
                        )
                        unownedSelf.setState(
                            selection: .tab(entry.id, entry.tabs[tabIndex].id),
                            state: .loading(unownedSelf.safeCourseSyncEntriesValue[id: entry.id]?.progress)
                        )

                    },
                    receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            unownedSelf.setState(
                                selection: .file(entry.id, files[fileIndex].id), state: .downloaded
                            )
                        case .failure:
                            unownedSelf.setState(
                                selection: .file(entry.id, files[fileIndex].id), state: .error
                            )
                        }
                    }
                )
            }
            .collect()
            .handleEvents(
                receiveOutput: { _ in
                    unownedSelf.setState(
                        selection: .tab(entry.id, entry.tabs[tabIndex].id), state: .downloaded
                    )
                }
            )
            .map { _ in () }
            .eraseToAnyPublisher()
    }

    /// When a download fails, we need to update the state of every other item that were still loading at the time when the error occured.
    private func setIdleStateForUnfinishedEntries() {
        var entries = safeCourseSyncEntriesValue

        entries.forEach { entry in
            if case .loading = entry.state {
                entries[id: entry.id]?.updateCourseState(state: .idle)
                progressWriterInteractor.saveStateProgress(
                    id: entry.id,
                    selection: .course(entry.id),
                    state: .idle
                )
            }

            entry.tabs.forEach { tab in
                if case .loading = tab.state {
                    entries[id: entry.id]?.updateTabState(id: tab.id, state: .idle)
                    progressWriterInteractor.saveStateProgress(
                        id: tab.id,
                        selection: .tab(entry.id, tab.id),
                        state: .idle
                    )
                }
            }
            entry.files.forEach { file in
                if case .loading = file.state {
                    entries[id: entry.id]?.updateFileState(id: file.id, state: .idle)
                    progressWriterInteractor.saveStateProgress(
                        id: file.id,
                        selection: .file(entry.id, file.id),
                        state: .idle
                    )
                }
            }
        }

        progressWriterInteractor.saveDownloadProgress(entries: entries, error: fileErrorMessage)
        backgroundQueue.sync(flags: .barrier) {
            courseSyncEntries.send(entries)
        }
    }

    /// Updates entry state in memory and writes it to Core Data. In addition it also writes file progress to Core Data.
    private func setState(selection: CourseEntrySelection, state: CourseSyncEntry.State) {
        var entries = safeCourseSyncEntriesValue

        switch selection {
        case let .course(entryID):
            entries[id: entryID]?.updateCourseState(state: state)
            progressWriterInteractor.saveStateProgress(id: entryID, selection: selection, state: state)
        case let .tab(entryID, tabID):
            entries[id: entryID]?.updateTabState(id: tabID, state: state)
            progressWriterInteractor.saveStateProgress(id: tabID, selection: selection, state: state)
        case let .file(entryID, fileID):
            entries[id: entryID]?.updateFileState(id: fileID, state: state)
            progressWriterInteractor.saveStateProgress(id: fileID, selection: selection, state: state)
        }

        var errorMessage: String?

        if case .error = state {
            errorMessage = fileErrorMessage
        }

        progressWriterInteractor.saveDownloadProgress(entries: entries, error: errorMessage)
        backgroundQueue.sync(flags: .barrier) {
            courseSyncEntries.send(entries)
        }
    }
}

private extension Publisher {
    func updateLoadingState(_ stateUpdate: @escaping () -> Void) -> AnyPublisher<Self.Output, Self.Failure> {
        handleEvents(
            receiveSubscription: { _ in
                stateUpdate()
            }
        )
        .eraseToAnyPublisher()
    }

    func updateErrorState(_ stateUpdate: @escaping () -> Void) -> AnyPublisher<Self.Output, Error> {
        return tryCatch { error -> AnyPublisher<Self.Output, Error> in
            stateUpdate()
            throw error
        }
        .eraseToAnyPublisher()
    }

    func updateDownloadedState(_ stateUpdate: @escaping () -> Void) -> AnyPublisher<Self.Output, Self.Failure> {
        handleEvents(
            receiveOutput: { _ in
                stateUpdate()
            }
        )
        .eraseToAnyPublisher()
    }
}
