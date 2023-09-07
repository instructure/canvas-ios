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
import SwiftUI
import mobile_offline_downloader_ios

final class DownloadsViewModel: ObservableObject, Reachabilitable {

    // MARK: - Injected -

    @Injected(\.reachability) var reachability: ReachabilityProvider

    private var storageManager: OfflineStorageManager = .shared
    private var downloadsManager: OfflineDownloadsManager = .shared

    // MARK: - Content -

    private(set) var courseViewModels: [DownloadCourseViewModel] = [] {
        didSet {
            setIsEmpty()
        }
    }
    @Published var downloadingModules: [DownloadsModuleCellViewModel] = [] {
        didSet {
            setIsEmpty()
        }
    }
    private(set) var categories: [String: [DownloadsCourseCategoryViewModel]] = [:]
    var cancellables: [AnyCancellable] = []

    enum State {
        case none // init
        case loading
        case loaded
        case updated
        case deleting
    }

    @Published var error: String = ""

    @Published var state: State = .none {
        didSet {
            setIsEmpty()
        }
    }

    @Published var isConnected: Bool = true {
        didSet {
            setIsEmpty()
        }
    }

    @Published var isEmpty: Bool = false

    init() {
        configure()
    }

    // MARK: - Intents -

    func pauseResume() {}

    func deleteAll() {
        state = .deleting
        OfflineLogsMananger().logDeleteAll()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            do {
                try self.downloadsManager.deleteCompletedEntries { [weak self] in
                    guard let self = self else {
                        return
                    }
                    DispatchQueue.main.async {
                        self.courseViewModels = []
                        self.state = .updated
                    }
                }
            } catch {
                self.error = error.localizedDescription
                self.state = .updated
            }
        }
    }

    func swipeDeleteDownloading(indexSet: IndexSet) {
        do {
            try indexSet.forEach { index in
                let viewModel = downloadingModules[index]
                try downloadsManager.delete(entry: viewModel.entry)
                downloadingModules.remove(at: index)
            }
            state = .updated
        } catch {
            self.error = error.localizedDescription
        }
    }

    func swipeDelete(indexSet: IndexSet) {
        state = .deleting
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            do {
                try indexSet.forEach { index in
                    let viewModel = self.courseViewModels.remove(at: index)
                    let models = self.categories.removeValue(forKey: viewModel.courseId)
                    try models
                        .flatMap { $0.flatMap { $0.content } }?
                        .forEach {
                            try self.downloadsManager.delete(entry: $0)
                        }
                }
            } catch {
                self.error = error.localizedDescription
            }
            self.state = .updated
        }
    }

    func fetch() {
        state = .loading
        configureDownloadingModules()
        storageManager.loadAll(of: CourseStorageDataModel.self) { [weak self] result in
            guard let self = self else {
                return
            }
            result.success { courses in
                courses.forEach { courseStorageDataModel in
                    self.configureCourseViewModels(
                        courseDataModel: courseStorageDataModel
                    )
                }
                self.sort()
                self.state = .loaded
            }
            result.failure { _ in
                self.state = .loaded
            }
        }
    }

    func configureDownloadingModules() {
        downloadingModules = (
            downloadsManager.activeEntries
            + downloadsManager.waitingEntries
            + downloadsManager.pausedEntries
            + downloadsManager.failedEntries
        )
        .map { .init(entry: $0) }
    }

    func categories(courseId: String) -> [DownloadsCourseCategoryViewModel] {
        categories[courseId] ?? []
    }

    func delete(courseViewModel: DownloadCourseViewModel) {
        categories.removeValue(forKey: courseViewModel.courseId)
        courseViewModels.removeAll(where: {$0.courseId == courseViewModel.courseId})
        state = .updated
    }

    // MARK: - Private methods -

    private func configure() {
        fetch()
        isConnected = reachability.isConnected
        addObservers()
    }

    private func configureCourseViewModels(
        courseDataModel: CourseStorageDataModel
    ) {
        let categories = DownloadsHelper.categories(
            from: downloadsManager.completedEntries,
            courseDataModel: courseDataModel
        )
        if !categories.isEmpty {
            self.categories[courseDataModel.course.id] = categories
            self.courseViewModels.append(
                DownloadCourseViewModel(
                    courseDataModel: courseDataModel
                )
            )
        }
    }

    private func addObservers() {
        downloadsManager
            .publisher
            .sink { [weak self] event in
                switch event {
                case .statusChanged(object: let event):
                    self?.statusChanged(event)
                case .progressChanged:
                    break
                }
            }
            .store(in: &cancellables)

        connection { [weak self] isConnected in
            self?.isConnected = isConnected
        }
    }

    private func statusChanged(_ event: OfflineDownloadsManagerEventObject) {
        if !event.isSupported {
            deleteDownloading(event)
            return
        }
        switch event.status {
        case .removed:
            deleteDownloading(event)
        case .completed, .partiallyDownloaded:
            deleteDownloading(event)
            if let object = event.object as? OfflineDownloadTypeProtocol {
                addCompletedEntry(object: object)
            }
        default:
            break
        }
    }

    private func deleteDownloading(_ event: OfflineDownloadsManagerEventObject) {
        do {
            let object = event.object
            let model = try object.toOfflineModel()
            downloadingModules.removeAll(where: { $0.moduleId == model.id })
        } catch {}
    }

    private func addCompletedEntry(object: OfflineDownloadTypeProtocol) {
        downloadsManager.savedEntry(for: object) { [weak self] result in
            guard let self = self else {
                return
            }
            result.success { entry in
                guard let userInfo = entry.userInfo,
                    let courseId = DownloadsHelper.getCourseId(userInfo: userInfo) else {
                    return
                }

                if self.categories.contains(where: { $0.key == courseId }) && !self.courseViewModels.isEmpty {
                    let pageSection = DownloadsHelper.pages(
                        courseId: courseId,
                        entries: [entry]
                    ).first
                    let moduleSection = DownloadsHelper.moduleItems(
                        courseId: courseId,
                        entries: [entry]
                    ).first
                    let fileSection = DownloadsHelper.files(
                        courseId: courseId,
                        entries: [entry]
                    ).first

                    pageSection.flatMap {
                        self.categories[courseId]?
                            .first(where: {$0.contentType == .pages})?
                            .content
                            .append($0)
                    }
                    moduleSection.flatMap {
                        self.categories[courseId]?
                            .first(where: { $0.contentType == .modules})?
                            .content
                            .append($0)
                    }
                    fileSection.flatMap {
                        self.categories[courseId]?
                            .first(where: { $0.contentType == .files})?
                            .content
                            .append($0)
                    }
                    self.state = .updated
                } else {
                    self.storageManager.loadAll(
                        of: CourseStorageDataModel.self
                    ) { result in
                        result.success { courseDataModels in
                            guard let courseDataModel = courseDataModels.first(
                                where: { $0.course.id == courseId }
                            ) else {
                                return
                            }
                            let categories = DownloadsHelper.categories(
                                from: [entry],
                                courseDataModel: courseDataModel
                            )
                            self.categories[courseDataModel.course.id] = categories
                            self.courseViewModels.append(
                                DownloadCourseViewModel(
                                    courseDataModel: courseDataModel
                                )
                            )
                            self.sort()
                            self.state = .updated
                        }
                    }
                }
            }
        }
    }

    private func setIsEmpty() {
        switch state {
        case .loaded, .updated:
            if !isConnected && courseViewModels.isEmpty {
                isEmpty = true
            } else {
                isEmpty = downloadingModules.isEmpty && courseViewModels.isEmpty
            }
        default:
            break
        }
    }

    private func sort() {
        courseViewModels.sort {
             $0.name.compare($1.name, options: .numeric) == .orderedAscending
        }
    }
}
