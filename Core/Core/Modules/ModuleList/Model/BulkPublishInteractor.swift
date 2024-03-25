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

class BulkPublishInteractor {
    typealias ProgressId = String

    public enum PublishProgress: Equatable {
        case running(progress: Float)
        case completed

        public init(response: GetBulkPublishProgressRequest.Response) {
            if response.isCompleted {
                self = .completed
            } else {
                self = .running(progress: response.progress)
            }
        }

        public var progress: Float? {
            if case .running(let progress) = self {
                return progress
            }
            return nil
        }
    }

    public let progress = CurrentValueSubject<PublishProgress, Error>(.running(progress: 0))
    public let moduleIds: [String]
    public let action: ModulePublishAction
    public private(set) var progressId: String?

    private let api: API
    private let courseId: String
    private let scheduler: AnySchedulerOf<DispatchQueue>
    private var subscriptions = Set<AnyCancellable>()
    private var pollRetryCount = 0
    private var maxPollRetryCount = 4

    public init(
        api: API,
        courseId: String,
        moduleIds: [String],
        action: ModulePublishAction,
        scheduler: AnySchedulerOf<DispatchQueue> = .global()
    ) {
        self.api = api
        self.courseId = courseId
        self.moduleIds = moduleIds
        self.action = action
        self.scheduler = scheduler
        sendBulkPublishRequest()
    }

    private func sendBulkPublishRequest() {
        let request = PutBulkPublishModulesRequest(
            courseId: courseId,
            moduleIds: moduleIds,
            action: action
        )
        api.makeRequest(request) { [weak self] response, _, error in
            guard let self else { return }

            if let progressId = response?.progress?.progress?.id {
                self.progressId = progressId
                pollDelayed(id: progressId)
            } else {
                progress.send(completion: .failure(error ?? NSError.internalError()))
            }
        }
    }

    private func pollProgress(id: ProgressId) {
        let request = GetBulkPublishProgressRequest(modulePublishProgressId: id)
        api.makeRequest(request) { [weak self] response, _, _ in
            guard let self else { return }
            guard let response else {
                pollRetryCount += 1

                if pollRetryCount > maxPollRetryCount {
                    progress.send(completion: .failure(NSError.internalError()))
                    return
                } else {
                    return pollDelayed(id: id)
                }
            }

            if response.isCompleted {
                progress.send(.running(progress: 1))
                refreshModules()
            } else {
                pollRetryCount = 0
                progress.send(.running(progress: response.progress / 100.0))
                pollDelayed(id: id)
            }
        }
    }

    private func pollDelayed(id: ProgressId) {
        scheduler.schedule(after: scheduler.now.advanced(by: 1)) { [weak self] in
            self?.pollProgress(id: id)
        }
    }

    private func refreshModules() {
        let useCase = GetModules(courseID: courseId)
        ReactiveStore(useCase: useCase)
            .forceRefresh()
            .sink { [weak self] _ in
                guard let self else { return }
                progress.send(.completed)
                progress.send(completion: .finished)
            } receiveValue: { _ in }
            .store(in: &subscriptions)
    }
}

extension BulkPublishInteractor: Equatable {
    static func == (lhs: BulkPublishInteractor, rhs: BulkPublishInteractor) -> Bool {
        lhs.courseId == rhs.courseId &&
        lhs.action == rhs.action &&
        lhs.moduleIds == rhs.moduleIds
    }
}
