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
    func cleanContent(for courseIds: [String]) -> AnyPublisher<Void, Never>
    func cancel()
}

public protocol CourseSyncContentInteractor {
    var associatedTabType: TabName { get }
    func getContent(courseId: CourseSyncID) -> AnyPublisher<Void, Error>
    func cleanContent(courseId: CourseSyncID) -> AnyPublisher<Void, Never>
}

public final class CourseSyncInteractorLive: CourseSyncInteractor {
    private let brandThemeInteractor: BrandThemeDownloaderInteractor
    private let contentInteractors: [CourseSyncContentInteractor]
    private let filesInteractor: CourseSyncFilesInteractor
    private let modulesInteractor: CourseSyncModulesInteractor
    private let progressWriterInteractor: CourseSyncProgressWriterInteractor
    private let studioMediaInteractor: CourseSyncStudioMediaInteractor
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
    private let fileErrorMessage = String(localized: "File download failed.", bundle: .core)
    private let notificationInteractor: CourseSyncNotificationInteractor
    internal private(set) var downloadSubscription: AnyCancellable?
    private var subscriptions = Set<AnyCancellable>()
    private let courseListInteractor: CourseListInteractor
    private let backgroundActivity: BackgroundActivity
    private let env: AppEnvironment

    /**
     - parameters:
        - courseListInteractor: This is used to download data for the "All Courses" screen opened from the dashboard.
     The reason is that the user can select courses for offline availability which are not on the dashboard so we have to make sure that
     when they access the "All Courses" screen the courses are listed.
     */
    public init(
        brandThemeInteractor: BrandThemeDownloaderInteractor,
        contentInteractors: [CourseSyncContentInteractor],
        filesInteractor: CourseSyncFilesInteractor,
        modulesInteractor: CourseSyncModulesInteractor,
        progressWriterInteractor: CourseSyncProgressWriterInteractor,
        notificationInteractor: CourseSyncNotificationInteractor,
        courseListInteractor: CourseListInteractor,
        studioMediaInteractor: CourseSyncStudioMediaInteractor,
        backgroundActivity: BackgroundActivity,
        scheduler: AnySchedulerOf<DispatchQueue>,
        env: AppEnvironment
    ) {
        self.brandThemeInteractor = brandThemeInteractor
        self.contentInteractors = contentInteractors
        self.filesInteractor = filesInteractor
        self.modulesInteractor = modulesInteractor
        self.progressWriterInteractor = progressWriterInteractor
        self.courseListInteractor = courseListInteractor
        self.studioMediaInteractor = studioMediaInteractor
        self.notificationInteractor = notificationInteractor
        self.backgroundActivity = backgroundActivity
        self.scheduler = scheduler
        self.env = env

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

        let sendFinishedNotification: () -> AnyPublisher<Void, Never> = { [notificationInteractor] in
            let hasError = unownedSelf.safeCourseSyncEntriesValue.hasError
            unownedSelf.progressWriterInteractor.saveDownloadResult(
                isFinished: true,
                error: hasError ? unownedSelf.fileErrorMessage : nil
            )

            return notificationInteractor.send()
        }
        let syncStudioMedia: () -> AnyPublisher<Void, Never> = { [studioMediaInteractor] in
            let courseIDs = entries.map { $0.syncID }
            return studioMediaInteractor.getContent(courseIDs: courseIDs)
        }
        downloadSubscription = backgroundActivity
            .start { unownedSelf.handleSyncInterruptByOS() }
            .receive(on: scheduler)
            .flatMap { [brandThemeInteractor] (_: Void) -> AnyPublisher<Void, Never> in
                brandThemeInteractor.getContent()
            }
            .flatMap { (_: Void) -> AnyPublisher<Void, Never> in
                unownedSelf.downloadCourseList()
            }
            .flatMap { (_: Void) -> AnyPublisher<Void, Never> in
                unownedSelf.syncEntries(entriesWithInitialLoadingState)
            }
            .flatMap { (_: Void) -> AnyPublisher<Void, Never> in
                syncStudioMedia()
            }
            .flatMap { (_: Void) -> AnyPublisher<Void, Never> in
                sendFinishedNotification()
            }
            .flatMap { (_: Void) -> Future<Void, Never> in
                unownedSelf.backgroundActivity.stop()
            }
            .sink(
                receiveCompletion: { _ in
                    NotificationCenter.default.post(name: .OfflineSyncCompleted, object: nil)
                },
                receiveValue: { _ in }
            )

        return courseSyncEntries.eraseToAnyPublisher()
    }

    private func syncEntries(_ entries: [CourseSyncEntry]) -> AnyPublisher<Void, Never> {
        Publishers.Sequence(sequence: entries)
            .buffer(size: .max, prefetch: .byRequest, whenFull: .dropOldest)
            .flatMap(maxPublishers: .max(3)) { [unowned self] (entry: CourseSyncEntry) -> AnyPublisher<Void, Never> in
                self.downloadCourseDetails(entry)
            }
            .collect()
            .mapToVoid()
            .eraseToAnyPublisher()
    }

    public func cleanContent(for courseIds: [String]) -> AnyPublisher<Void, Never> {
        return courseIds.publisher
            .compactMap { [weak self] courseId in
                let rootURL = URL.Directories.documents
                    .appendingPathComponent(self?.env.currentSession?.uniqueID ?? "")
                    .appendingPathComponent("Offline")
                    .appendingPathComponent("course-\(courseId)")
                try? FileManager.default.removeItem(at: rootURL)
            }
            .collect()
            .mapToVoid()
            .eraseToAnyPublisher()
    }

    public func cancel() {
        downloadSubscription?.cancel()
        downloadSubscription = nil
        progressWriterInteractor.cleanUpPreviousDownloadProgress()
        backgroundActivity.stopAndWait()
    }

    // MARK: - Private Methods

    private func downloadCourseList() -> AnyPublisher<Void, Never> {
        courseListInteractor
            .getCourses()
            .first()
            .mapToVoid()
            .replaceError(with: ())
            .eraseToAnyPublisher()
    }

    /// Collects and manages downloaders for a single course and publishes the final state update.
    private func downloadCourseDetails(_ entry: CourseSyncEntry) -> AnyPublisher<Void, Never> {
        unowned let unownedSelf = self

        setState(
            selection: .course(entry.id),
            state: .loading(nil)
        )

        var downloaders = TabName
            .OfflineSyncableTabs
            .filter { $0 != .files && $0 != .modules } // files and modules are handled separately
            .map { downloadTabContent(for: entry, tabName: $0) }

        downloaders.append(downloadFiles(for: entry))
        downloaders.append(downloadModules(for: entry))
        downloaders.append(downloadFrontPage(entry: entry))

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
                guard let additionalContentTabId = entry.tabs.filter({ $0.type == .additionalContent }).first?.id else {
                    return
                }
                unownedSelf.setState(
                    selection: .tab(entry.id, additionalContentTabId),
                    state: state,
                    isFinalUpdate: true
                )
            }
            .map { _ in () }
            .eraseToAnyPublisher()
    }

    /// Downloads tab content based on the currently received course entry and tab.
    /// It's called iteratively where each iteration is one of the currently supported offline downloadable tab.
    /// If the user choses to sync the whole course, then:
    ///     - We first check if the received tab is already part of the visible course tabs and set the tab id that needs to be updated.
    ///     - If it isn't part of the visible tabs, then this is an "Additional Content" download, so we set the tab id accordingly.
    /// Otherwise we check if the currently received tab has been selected by the user.
    private func downloadTabContent(for entry: CourseSyncEntry, tabName: TabName) -> AnyPublisher<Void, Never> {
        unowned let unownedSelf = self

        var tabId: String?
        var interactor: CourseSyncContentInteractor?

        if entry.isFullContentSync {
            interactor = contentInteractors.first(where: { $0.associatedTabType == tabName })

            if let tab = entry.tabs.first(where: { $0.type == tabName }) {
                tabId = tab.id
            } else if let tab = entry.tabs.first(where: { $0.type == .additionalContent }) {
                tabId = tab.id
            }
        } else if entry.selectedTabs.contains(tabName) {
            interactor = contentInteractors.first(where: { $0.associatedTabType == tabName })
            tabId = entry.tabs.first(where: { $0.type == tabName })?.id
        }

        guard
            let interactor,
            let tabId,
            let tabIndex = entry.tabs.firstIndex(where: { $0.id == tabId })
        else {
            return Just(()).eraseToAnyPublisher()
        }

        switch entry.tabs[tabIndex].selectionState {
        case .deselected:
            return interactor.cleanContent(courseId: entry.syncID).eraseToAnyPublisher()
        default:
            return Just(()).eraseToAnyPublisher()
                .flatMap { interactor.cleanContent(courseId: entry.syncID).eraseToAnyPublisher() }
                .flatMap { [scheduler] in
                    interactor
                        .getContent(courseId: entry.syncID)
                        .receive(on: scheduler)
                        .updateLoadingState {
                            unownedSelf.setState(
                                selection: .tab(entry.id, tabId),
                                state: .loading(nil)
                            )
                        }
                        .updateDownloadedState {
                            unownedSelf.setState(
                                selection: .tab(entry.id, tabId),
                                state: .downloaded
                            )
                        }
                        .tryCatch {
                            unownedSelf.handleNonFatalErrors(
                                error: $0,
                                selection: .tab(entry.id, tabId),
                                state: .downloaded
                            )
                        }
                        .catch { _ in
                            unownedSelf.setState(
                                selection: .tab(entry.id, tabId),
                                state: .error
                            )
                            return Just(()).eraseToAnyPublisher()
                        }
                        .eraseToAnyPublisher()
                }
                .eraseToAnyPublisher()
        }
    }

    /// Downloads files for a single course.
    /// If the user choses to sync the whole course, then:
    ///     - We first check if the files tab is already part of the visible course tabs and set the tab id that needs to be updated.
    ///     - If it isn't part of the visible tabs, then this is an "Additional Content" download, so we set the tab id accordingly.
    /// Otherwise we check if the files tab has been fully or partially selected by the user,
    /// and we download the selected files.
    private func downloadFiles(for entry: CourseSyncEntry) -> AnyPublisher<Void, Never> {
        var tabId: String?

        if entry.isFullContentSync {
            if let tab = entry.tabs.first(where: { $0.type == .files }) {
                tabId = tab.id
            } else if let tab = entry.tabs.first(where: { $0.type == .additionalContent }) {
                tabId = tab.id
            }
        } else if entry.selectedTabs.contains(.files) {
            tabId = entry.tabs.first(where: { $0.type == .files })?.id
        }

        guard
            let tabId,
            let tabIndex = entry.tabs.firstIndex(where: { $0.id == tabId }),
            entry.tabs[tabIndex].selectionState == .selected ||
            entry.tabs[tabIndex].selectionState == .partiallySelected
        else {
            return removeUnavailableFiles(courseId: entry.courseId, environment: entry.environment)
        }

        let files = entry.files.filter {
            if entry.isFullContentSync {
                return true
            } else {
                return $0.selectionState == .selected
            }
        }

        guard !files.isEmpty else {
            return removeUnavailableFiles(
                courseId: entry.courseId,
                newFileIDs: files.map { $0.fileId },
                environment: entry.environment
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
                    newFileIDs: files.map { $0.fileId },
                    environment: entry.environment
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
            updatedAt: file.updatedAt,
            environment: entry.environment
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

    /// Downloads modules tab for a single course.
    /// If the user choses to sync the whole course, then:
    ///     - We first check if the modules tab is already part of the visible course tabs and set the tab id that needs to be updated.
    ///     - If it isn't part of the visible tabs, then this is an "Additional Content" download, so we set the tab id accordingly.
    /// Otherwise we check if the modules tab has been selected by the user.
    /// Additionally, it iterates through module items and downloads the tab content from the appropriate API.
    private func downloadModules(for entry: CourseSyncEntry) -> AnyPublisher<Void, Never> {
        var tabId: String?

        if entry.isFullContentSync {
            if let tab = entry.tabs.first(where: { $0.type == .modules }) {
                tabId = tab.id
            } else if let tab = entry.tabs.first(where: { $0.type == .additionalContent }) {
                tabId = tab.id
            }
        } else if entry.selectedTabs.contains(.modules) {
            tabId = entry.tabs.first(where: { $0.type == .modules })?.id
        }

        unowned let unownedSelf = self

        guard
            let tabId,
            let tabIndex = entry.tabs.firstIndex(where: { $0.id == tabId }),
            entry.tabs[tabIndex].selectionState == .selected
        else {
            return Just(()).eraseToAnyPublisher()
        }

        return modulesInteractor.getModuleItems(courseId: entry.syncID)
            .flatMap {
                unownedSelf.getModuleSubItems(entry: entry, moduleItems: $0)
                    .zip()
                    .mapToVoid()
            }
            .receive(on: scheduler)
            .replaceEmpty(with: ())
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
            .tryCatch {
                unownedSelf.handleNonFatalErrors(
                    error: $0,
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

    /// Downloads module items for a single course.
    /// Some module items:
    ///     - are downloadable by simply querying the course's tab list like `/courses/:id/discussions`,
    ///     - some need to be explicitily called like `/courses/:id/pages/:id`.
    private func getModuleSubItems(entry: CourseSyncEntry, moduleItems: [ModuleItem]) -> [AnyPublisher<Void, Error>] {
        let tabsForRegularDownload = Set(moduleItems.tabItemsToRequestByList).subtracting(Set(entry.selectedTabs))
        let tabsForModuleItemDownload = Set(moduleItems.tabItemsToRequestByID)

        let interactors = tabsForRegularDownload.compactMap { tabName in
            if let interactor = contentInteractors.first(where: { $0.associatedTabType == tabName }) {
                return interactor
            } else {
                return nil
            }
        }

        var downloaders = interactors.map { $0.getContent(courseId: entry.syncID) }

        if tabsForModuleItemDownload.count > 0 {
            let modulesDownloaders = modulesInteractor.getAssociatedModuleItems(
                courseId: entry.syncID,
                moduleItemTypes: tabsForModuleItemDownload,
                moduleItems: moduleItems
            )
            downloaders.append(modulesDownloaders)
        }

        return downloaders
    }

    private func downloadFrontPage(entry: CourseSyncEntry) -> AnyPublisher<Void, Never> {
        guard !entry.selectedTabs.contains(.pages), entry.hasFrontPage,
              let interactor = contentInteractors.first(where: { $0.associatedTabType == .pages })
        else {
            return Just(()).eraseToAnyPublisher()
        }

        return interactor.getContent(courseId: entry.syncID)
            .catch { _ in Just(()).eraseToAnyPublisher() }
            .eraseToAnyPublisher()
    }

    private func removeUnavailableFiles(courseId: String, newFileIDs: [String] = [], environment: AppEnvironment) -> AnyPublisher<Void, Never> {
        filesInteractor.removeUnavailableFiles(
            courseId: courseId,
            newFileIDs: newFileIDs,
            environment: environment
        )
        .replaceError(with: ())
        .eraseToAnyPublisher()
    }

    /// Some courses are setup in a way that there are no visible tabs except e.g.: Modules, Front Page, etc.
    /// When the user choses to sync the whole course, we'll try to fetch every tab content from the different APIs.
    /// Some of these APIs will respond with an error when trying to fetch hidden tabs. We swallow these errors and let
    /// the download continue.
    private func handleNonFatalErrors(
        error: Error,
        selection: CourseEntrySelection,
        state: CourseSyncEntry.State
    ) -> AnyPublisher<Void, Error> {
        let err = error as NSError
        if (error is APIError ||
            (err.domain == NSError.Constants.domain &&
            err.code == HttpError.unauthorized ||
            err.code == HttpError.forbidden ||
            err.code == HttpError.notFound ||
            err.code == HttpError.unexpected ||
            err == NSError.instructureError("Failed to save base content") ||
            err == NSError.instructureError("The resource could not be loaded because the App Transport Security policy requires the use of a secure connection."))) {
            setState(
                selection: selection,
                state: state
            )
            return Just(())
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        } else {
            return Fail(error: error).eraseToAnyPublisher()
        }
    }

    /// Updates entry state in memory and writes it to Core Data. In addition it also writes file progress to Core Data.
    private func setState(selection: CourseEntrySelection, state: CourseSyncEntry.State, isFinalUpdate: Bool = false) {
        var entries = safeCourseSyncEntriesValue

        switch selection {
        case let .course(entryID):
            entries[id: entryID]?.updateCourseState(state: state)
            progressWriterInteractor.saveStateProgress(id: entryID, selection: selection, state: state)
        case let .tab(entryID, tabID):
            /// When there's an "Additional Content" tab, there are most likely multiple hidden tabs that need to be downloaded.
            /// Since each entry has only 1 "Additional Content" tab but there are multiple downloads going on in the background,
            /// we don't want to do updates like `Loading` -> `Downloaded` then again `Loading`.
            /// Instead, we silently collect the results and only publish it once the entry finished downloading.
            if selection.isAdditionalContentTab, state == .downloaded || state == .error, !isFinalUpdate {
                entries[id: entryID]?.updateAdditionalContentResults(isSuccessful: state == .downloaded)
            } else {
                entries[id: entryID]?.updateTabState(id: tabID, state: state)
                progressWriterInteractor.saveStateProgress(id: tabID, selection: selection, state: state)
            }
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
            cpy.clearAdditionalContentResults()
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
                                                    error: String(localized: "Offline sync was interrupted by the operating system", bundle: .core))
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
