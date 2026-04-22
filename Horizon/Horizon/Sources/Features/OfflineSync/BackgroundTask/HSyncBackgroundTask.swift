//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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
import Core

public final class HSyncBackgroundTask: BackgroundTask {
    private let sessions: [LoginSession]
    private let lastLoggedInSession: LoginSession?
    private let scheduleInteractor: HSyncScheduleInteractor
    private let networkAvailabilityService: NetworkAvailabilityService
    private let courseSyncInteractor: HCourseSyncInteractor
    private var isCancelled = false
    private var subscriptions = Set<AnyCancellable>()

    public init(
        syncableAccounts: HSyncAccountsInteractor,
        sessions: Set<LoginSession>,
        scheduleInteractor: HSyncScheduleInteractor = HSyncScheduleInteractorLive(),
        networkAvailabilityService: NetworkAvailabilityService = NetworkAvailabilityServiceLive(),
        courseSyncInteractor: HCourseSyncInteractor
    ) {
        self.sessions = syncableAccounts.calculate(Array(sessions), date: Clock.now)
        self.lastLoggedInSession = LoginSession.mostRecent
        self.scheduleInteractor = scheduleInteractor
        self.networkAvailabilityService = networkAvailabilityService
        self.courseSyncInteractor = courseSyncInteractor
    }

    public func start(completion: @escaping () -> Void) {
        Logger.shared.log("Horizon: Background sync started with \(sessions.count) session(s).")
        networkAvailabilityService.startMonitoring()
        networkAvailabilityService
            .startObservingStatus()
            .compactMap { $0 }
            .first()
            .sink { [sessions, weak self] _ in
                self?.syncNextSession(in: sessions, completion: completion)
            } receiveValue: { _ in }
            .store(in: &subscriptions)
    }

    public func cancel() {
        Logger.shared.log("Horizon: Background sync cancelled.")
        isCancelled = true
        subscriptions.removeAll()
        networkAvailabilityService.stopMonitoring()
        restoreLastLoggedInSession()
        scheduleInteractor.scheduleNextSync()
    }

    // MARK: - Private

    private func syncNextSession(in sessions: [LoginSession], completion: @escaping () -> Void) {
        guard !isCancelled else {
            Logger.shared.log("Horizon Offline: Sync cancelled, aborting next account sync.")
            return
        }

        guard let session = sessions.first else {
            return handleSyncCompleted(completion: completion)
        }

        Logger.shared.log("Horizon: Syncing session \(session.uniqueID).")
        AppEnvironment.shared.userDidLogin(session: session, isSilent: true)

        let sessionDefaults = SessionDefaults(sessionID: session.uniqueID)

        if sessionDefaults.isOfflineWifiOnlySyncEnabled == true, networkAvailabilityService.status == .connected(.cellular) {
            Logger.shared.log("Offline: Wifi only sync is selected but wifi not available, postponing.")
            scheduleInteractor.updateNextSyncDate(sessionUniqueID: session.uniqueID)
            removeCompletedSessionAndStartNextSync(sessions: sessions, completion: completion)
            return
        }

        let courses = buildCourses(from: sessionDefaults)

        courseSyncInteractor.downloadContent(courses: courses, environment: AppEnvironment.shared)
        courseSyncInteractor.progressPublisher
            .filter(\.isComplete)
            .first()
            .sink { [weak self] _ in
                self?.scheduleInteractor.updateNextSyncDate(sessionUniqueID: session.uniqueID)
                self?.removeCompletedSessionAndStartNextSync(sessions: sessions, completion: completion)
            }
            .store(in: &subscriptions)
    }

    private func buildCourses(from sessionDefaults: SessionDefaults) -> [OfflineCourseItem] {
        let types = sessionDefaults.horizonOfflineSyncItems.compactMap { OfflineType.parse(path: $0) }
        let fileMetadata = sessionDefaults.horizonOfflineSyncFileMetadata

        var courseFilesMap: [String: [String]] = [:]
        var courseOnlyIDs: Set<String> = []

        for type in types {
            switch type {
            case .course(let id):
                courseOnlyIDs.insert(id)
            case .file(let courseID, let fileID):
                courseFilesMap[courseID, default: []].append(fileID)
            default:
                break
            }
        }

        return courseOnlyIDs.union(Set(courseFilesMap.keys)).map { courseID in
            let fileItems = (courseFilesMap[courseID] ?? []).compactMap { fileID -> OfflineFileItem? in
                guard let info = fileMetadata[fileID] else { return nil }
                return OfflineFileItem(
                    id: fileID,
                    name: info["name"] as? String ?? "",
                    size: "",
                    sizeInBytes: info["sizeInBytes"] as? Double ?? 0,
                    isSelected: true,
                    mimeClass: info["mimeClass"] as? String ?? "",
                    courseID: courseID
                )
            }
            return OfflineCourseItem(
                id: courseID,
                name: "",
                size: nil,
                isExpanded: false,
                isSelected: fileItems.isEmpty,
                subItems: fileItems
            )
        }
    }

    private func handleSyncCompleted(completion: () -> Void) {
        Logger.shared.log("Horizon: Background sync completed.")
        networkAvailabilityService.stopMonitoring()
        restoreLastLoggedInSession()
        scheduleInteractor.scheduleNextSync()
        completion()
    }

    private func removeCompletedSessionAndStartNextSync(sessions: [LoginSession], completion: @escaping () -> Void) {
        var remaining = sessions
        remaining.removeFirst()
        syncNextSession(in: remaining, completion: completion)
    }

    private func restoreLastLoggedInSession() {
        if let session = lastLoggedInSession {
            AppEnvironment.shared.userDidLogin(session: session)
        }
    }
}
