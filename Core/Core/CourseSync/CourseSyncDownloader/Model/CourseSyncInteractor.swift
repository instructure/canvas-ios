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
    func cancel()
}

public protocol CourseSyncContentInteractor {
    var associatedTabType: TabName { get }
    func getContent(courseId: String) -> AnyPublisher<Void, Error>
}

public final class CourseSyncInteractorLive: CourseSyncInteractor {
    private let contentInteractors: [CourseSyncContentInteractor]
    private let filesInteractor: CourseSyncFilesInteractor
    private let modulesInteractor: CourseSyncModulesInteractor
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
    private let notificationInteractor: CourseSyncNotificationInteractor
    internal private(set) var downloadSubscription: AnyCancellable?
    private var subscriptions = Set<AnyCancellable>()
    private let courseListInteractor: CourseListInteractor
    private let backgroundActivity: BackgroundActivity

    /**
     - parameters:
        - courseListInteractor: This is used to download data for the "All Courses" screen opened from the dashboard.
     The reason is that the user can select courses for offline availability which are not on the dashboard so we have to make sure that
     when they access the "All Courses" screen the courses are listed.
     */
    public init(
        contentInteractors: [CourseSyncContentInteractor],
        filesInteractor: CourseSyncFilesInteractor,
        modulesInteractor: CourseSyncModulesInteractor,
        progressWriterInteractor: CourseSyncProgressWriterInteractor,
        notificationInteractor: CourseSyncNotificationInteractor,
        courseListInteractor: CourseListInteractor,
        backgroundActivity: BackgroundActivity,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.contentInteractors = contentInteractors
        self.filesInteractor = filesInteractor
        self.modulesInteractor = modulesInteractor
        self.progressWriterInteractor = progressWriterInteractor
        self.courseListInteractor = courseListInteractor
        self.notificationInteractor = notificationInteractor
        self.backgroundActivity = backgroundActivity
        self.scheduler = scheduler

        listenToCancellationEvent()
    }

    /**
      **Warning!** While the download is in progress the interactor must not be released otherwise it will crash!
     */
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

        downloadSubscription = backgroundActivity
            .start { unownedSelf.handleSyncInterruptByOS() }
            .receive(on: scheduler)
            .flatMap { _ in unownedSelf.downloadCourseList() }
            .flatMap { Publishers.Sequence(sequence: entriesWithInitialLoadingState) }
            .buffer(size: .max, prefetch: .byRequest, whenFull: .dropOldest)
            .flatMap(maxPublishers: .max(3)) { unownedSelf.downloadCourseDetails($0) }
            .collect()
            .flatMap { [notificationInteractor] _ in
                let hasError = unownedSelf.safeCourseSyncEntriesValue.hasError
                unownedSelf.progressWriterInteractor.saveDownloadResult(
                    isFinished: true,
                    error: hasError ? unownedSelf.fileErrorMessage : nil
                )

                return notificationInteractor.send()
            }
            .flatMap { unownedSelf.backgroundActivity.stop() }
            .sink(
                receiveCompletion: { _ in
                    NotificationCenter.default.post(name: .OfflineSyncCompleted, object: nil)
                },
                receiveValue: { _ in }
            )

        return courseSyncEntries.eraseToAnyPublisher()
    }

    public func cancel() {
        downloadSubscription?.cancel()
        downloadSubscription = nil
        progressWriterInteractor.cleanUpPreviousDownloadProgress()
        backgroundActivity.stopAndWait()
    }

    // MARK: - Private Methods

    private func downloadCourseList() -> AnyPublisher<Void, Never> {
        let result = courseListInteractor
            .state
            .first { state in
                state != .loading
            }
            .mapToVoid()
            .eraseToAnyPublisher()

        if courseListInteractor.state.value == .loading {
            courseListInteractor.loadAsync()
        }

        return result
    }

    private func downloadCourseDetails(_ entry: CourseSyncEntry) -> AnyPublisher<Void, Never> {
        unowned let unownedSelf = self

        setState(
            selection: .course(entry.id),
            state: .loading(nil)
        )

        var downloaders = TabName
            .OfflineSyncableTabs
            .filter { $0 != .files && $0 != .modules } // files are handled separately
            .map { downloadTabContent(for: entry, tabName: $0) }

        downloaders.append(downloadFiles(for: entry))

        return downloaders
            .zip()
            .flatMap { _ in unownedSelf.downloadModules(for: entry) }
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
              entry.tabs[tabIndex].selectionState == .selected,
              entry.tabs[tabIndex].state != .downloaded
        else {
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
            return removeUnavailableFiles(courseId: entry.courseId)
        }

        let files = entry.files.filter { $0.selectionState == .selected }

        guard !files.isEmpty, entry.tabs[tabIndex].state != .downloaded else {
            return removeUnavailableFiles(
                courseId: entry.courseId,
                newFileIDs: files.map { $0.fileId }
            )
        }

        unowned let unownedSelf = self

        unownedSelf.setState(
            selection: .tab(entry.id, entry.tabs[tabIndex].id),
            state: .loading(nil)
        )

        return files.publisher
            .eraseToAnyPublisher()
            .buffer(size: .max, prefetch: .byRequest, whenFull: .dropOldest)
            .receive(on: unownedSelf.scheduler)
            .flatMap(maxPublishers: .max(6)) { file in
                unownedSelf.downloadSingleFile(
                    entry: entry,
                    file: file,
                    tabIndex: tabIndex,
                    files: files
                )
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
            .flatMap { _ in
                unownedSelf.removeUnavailableFiles(
                    courseId: entry.courseId,
                    newFileIDs: files.map { $0.fileId }
                )
            }
            .eraseToAnyPublisher()
    }

    private func downloadSingleFile(
        entry: CourseSyncEntry,
        file: CourseSyncEntry.File,
        tabIndex: Array<CourseSyncEntry.Tab>.Index,
        files: [CourseSyncEntry.File]
    ) -> AnyPublisher<Float, Never> {
        let fileIndex = files.firstIndex(of: file)!
        unowned let unownedSelf = self

        setState(
            selection: .file(entry.id, files[fileIndex].id), state: .loading(nil)
        )

        return filesInteractor.downloadFile(
            courseId: entry.courseId,
            url: file.url,
            fileID: file.fileId,
            fileName: file.fileName,
            mimeClass: file.mimeClass,
            updatedAt: file.updatedAt
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

    private func downloadModules(for entry: CourseSyncEntry) -> AnyPublisher<Void, Never> {
        unowned let unownedSelf = self

        guard let tabIndex = entry.tabs.firstIndex(where: { $0.type == .modules }),
              entry.tabs[tabIndex].selectionState == .selected,
              entry.tabs[tabIndex].state != .downloaded
        else {
            return Just(()).eraseToAnyPublisher()
        }

        return modulesInteractor.getContent(courseId: entry.courseId)
            .flatMap {
                unownedSelf.getModuleSubItems(entry: entry, moduleItems: $0)
                    .zip()
                    .mapToVoid()
            }
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

    private func getModuleSubItems(entry: CourseSyncEntry, moduleItems: [ModuleItem]) -> [AnyPublisher<Void, Error>] {
        let tabsForRegularDownload = Set(moduleItems.tabItemsToRequestByList).subtracting(Set(entry.selectedTabs))
        let tabsForModuleItemDownload = moduleItems.tabItemsToRequestByID

        let interactors = tabsForRegularDownload.compactMap { tabName in
            if let interactor = contentInteractors.first(where: { $0.associatedTabType == tabName }) {
                return interactor
            } else {
                return nil
            }
        }

        var downloaders = interactors.map { $0.getContent(courseId: entry.courseId) }

        let modulesDownloaders = modulesInteractor.getAssociatedModuleItems(
            courseId: entry.courseId,
            moduleItemTypes: tabsForModuleItemDownload,
            moduleItems: moduleItems
        )

        downloaders.append(modulesDownloaders)

        return downloaders
    }

    private func removeUnavailableFiles(courseId: String, newFileIDs: [String] = []) -> AnyPublisher<Void, Never> {
        filesInteractor.removeUnavailableFiles(
            courseId: courseId,
            newFileIDs: newFileIDs
        )
        .replaceError(with: ())
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
                cpy.updateCourseState(state: .loading(nil))
            } else {
                return cpy
            }

            for tab in cpy.tabs where tab.state != .downloaded {
                cpy.updateTabState(id: tab.id, state: .loading(nil))
            }

            for file in cpy.files where file.state != .downloaded {
                cpy.updateFileState(id: file.id, state: .loading(nil))
            }

            return cpy
        }
    }

    private func listenToCancellationEvent() {
        NotificationCenter.default.publisher(for: .OfflineSyncCancelled)
            .sink(receiveCompletion: { _ in }, receiveValue: { [unowned self] _ in
                self.cancel()
            })
            .store(in: &subscriptions)
    }

    private func handleSyncInterruptByOS() {
        downloadSubscription?.cancel()
        downloadSubscription = nil
        progressWriterInteractor.markInProgressDownloadsAsFailed()
        progressWriterInteractor.saveDownloadResult(isFinished: true,
                                                    error: NSLocalizedString("Offline sync was interrupted by the operating system", comment: ""))
        notificationInteractor.sendFailedNotification()
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

private extension Collection where Element == ModuleItem {
    var tabItemsToRequestByList: [TabName] {
        filter {
            switch $0.type {
            case .assignment:
                return true
            case .discussion:
                return true
            default:
                return false
            }
        }
        .compactMap { $0.associatedOfflineTab }
    }

    var tabItemsToRequestByID: [TabName] {
        filter {
            switch $0.type {
            case .assignment:
                return false
            case .discussion:
                return false
            default:
                return true
            }
        }
        .compactMap { $0.associatedOfflineTab }
    }
}

extension ModuleItem {
    /// Certain courses have their tabs hidden except Modules. In that case we need to iterate through each module item and download its' content from the appropiate API. This property gives back a `TabName` if the API accepts requests when the tab is hidden.
    var associatedOfflineTab: TabName? {
        switch type {
        case .file:
            return .files
        case .discussion:
            return .discussions
        case .assignment:
            return .assignments
        case .quiz:
            return .quizzes
        case .page:
            return .pages
        default:
            return nil
        }
    }
}
