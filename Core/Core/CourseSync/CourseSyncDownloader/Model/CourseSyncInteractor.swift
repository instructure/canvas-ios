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
import Foundation

public protocol CourseSyncInteractor {
    func downloadContent(for entries: [CourseSyncEntry]) -> AnyPublisher<[CourseSyncEntry], Never>
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
    private var courseSyncEntries = CurrentValueSubject<[CourseSyncEntry], Never>.init([])
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
    internal private(set) var downloadSubscription: AnyCancellable?
    private var subscriptions = Set<AnyCancellable>()

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

        listenToCancellationEvent()
    }

    public func downloadContent(for entries: [CourseSyncEntry]) -> AnyPublisher<[CourseSyncEntry], Never> {
        downloadSubscription?.cancel()
        downloadSubscription = nil

        unowned let unownedSelf = self

        let entriesWithInitialLoadingState = resetEntryStates(entries: entries)

        backgroundQueue.sync(flags: .barrier) {
            courseSyncEntries.send(entriesWithInitialLoadingState)
        }

        progressWriterInteractor.cleanUpPreviousDownloadProgress()
        progressWriterInteractor.setInitialLoadingState(entries: entriesWithInitialLoadingState)

        downloadSubscription = Publishers.Sequence(sequence: entriesWithInitialLoadingState)
            .buffer(size: .max, prefetch: .byRequest, whenFull: .dropOldest)
            .receive(on: scheduler)
            .flatMap(maxPublishers: .max(3)) { unownedSelf.downloadCourseDetails($0) }
            .collect()
            .sink(
                receiveCompletion: { _ in
                    let hasError = unownedSelf.safeCourseSyncEntriesValue.hasError
                    unownedSelf.progressWriterInteractor.saveDownloadResult(
                        isFinished: true,
                        error: hasError ? unownedSelf.fileErrorMessage : nil
                    )
                },
                receiveValue: { _ in }
            )

        return courseSyncEntries.eraseToAnyPublisher()
    }

    private func downloadCourseDetails(_ entry: CourseSyncEntry) -> AnyPublisher<Void, Never> {
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
            .updateDownloadedState {
                let hasError = unownedSelf.safeCourseSyncEntriesValue[id: entry.id]?.hasError ?? false
                let state: CourseSyncEntry.State = hasError ? .error : .downloaded
                unownedSelf.setState(
                    selection: .course(entry.id),
                    state: state
                )
            }
            .map { _ in () }
            .eraseToAnyPublisher()
    }

    private func downloadTabContent(for entry: CourseSyncEntry, tabName: TabName) -> AnyPublisher<Void, Never> {
        unowned let unownedSelf = self

        guard let tabIndex = entry.tabs.firstIndex(where: { $0.type == tabName }),
              entry.tabs[tabIndex].selectionState == .selected else {
            return Just(()).eraseToAnyPublisher()
        }

        guard let interactor = contentInteractors.first(where: { $0.associatedTabType == tabName }) else {
            assertionFailure("No interactor found for selected tab: \(tabName)")
            return Just(()).eraseToAnyPublisher()
        }

        return interactor.getContent(courseId: entry.courseId)
            .receive(on: scheduler)
            .updateLoadingState {
                unownedSelf.setState(
                    selection: .tab(entry.id, entry.tabs[tabIndex].id),
                    state: .loading(nil)
                )
            }
            .updateDownloadedState {
                unownedSelf.setState(
                    selection: .tab(entry.id, entry.tabs[tabIndex].id),
                    state: .downloaded
                )
            }
            .catch { _ in
                unownedSelf.setState(
                    selection: .tab(entry.id, entry.tabs[tabIndex].id),
                    state: .error
                )
                return Just(()).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    private func downloadFiles(for entry: CourseSyncEntry) -> AnyPublisher<Void, Never> {
        guard
            let tabIndex = entry.tabs.firstIndex(where: { $0.type == .files }),
            entry.files.count > 0,
            entry.tabs[tabIndex].selectionState == .selected ||
            entry.tabs[tabIndex].selectionState == .partiallySelected
        else {
            return Just(()).eraseToAnyPublisher()
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
                    mimeClass: element.mimeClass,
                    updatedAt: element.updatedAt
                )
                .throttle(for: .milliseconds(300), scheduler: unownedSelf.scheduler, latest: true)
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
                .catch { _ in Just(0).eraseToAnyPublisher() }
                .eraseToAnyPublisher()
            }
            .collect()
            .handleEvents(
                receiveOutput: { _ in
                    let hasError = unownedSelf.safeCourseSyncEntriesValue[id: entry.id]?.hasFileError ?? false
                    let state: CourseSyncEntry.State = hasError ? .error : .downloaded

                    unownedSelf.setState(
                        selection: .tab(entry.id, entry.tabs[tabIndex].id), state: state
                    )
                }
            )
            .map { _ in () }
            .eraseToAnyPublisher()
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

        progressWriterInteractor.saveDownloadProgress(entries: entries)
        backgroundQueue.sync(flags: .barrier) {
            courseSyncEntries.send(entries)
        }
    }

    private func resetEntryStates(entries: [CourseSyncEntry]) -> [CourseSyncEntry] {
        entries.map { entry in
            var cpy = entry
            if cpy.state != .downloaded {
                cpy.state = .loading(nil)
            } else {
                return cpy
            }

            for var tab in cpy.tabs where tab.state != .downloaded {
                tab.state = .loading(nil)
            }

            for var file in cpy.files where file.state != .downloaded {
                file.state = .loading(nil)
            }

            return cpy
        }
    }

    private func listenToCancellationEvent() {
        NotificationCenter.default.publisher(for: .OfflineSyncCancelled)
            .sink(receiveValue: { [unowned self] _ in
                downloadSubscription?.cancel()
                downloadSubscription = nil
                progressWriterInteractor.cleanUpPreviousDownloadProgress()
            })
            .store(in: &subscriptions)
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

    func updateDownloadedState(_ stateUpdate: @escaping () -> Void) -> AnyPublisher<Self.Output, Self.Failure> {
        handleEvents(
            receiveOutput: { _ in
                stateUpdate()
            }
        )
        .eraseToAnyPublisher()
    }
}
