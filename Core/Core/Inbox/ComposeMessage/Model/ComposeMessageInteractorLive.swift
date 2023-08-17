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

public class ComposeMessageInteractorLive: ComposeMessageInteractor {
    // MARK: - Outputs
    public var state = CurrentValueSubject<StoreState, Never>(.loading)
    public var courses = CurrentValueSubject<[InboxCourse], Never>([])

    // MARK: - Private
    private var subscriptions = Set<AnyCancellable>()
    private let env: AppEnvironment
    private let courseListStore: Store<GetInboxCourseList>
    private let selectedContext = CurrentValueRelay<Context?>(nil)

    public init(env: AppEnvironment) {
        self.env = env
        self.courseListStore = env.subscribe(GetInboxCourseList())

        courseListStore
            .statePublisher
            .subscribe(state)
            .store(in: &subscriptions)

        courseListStore
            .allObjects
            .subscribe(courses)
            .store(in: &subscriptions)
        courseListStore.exhaust()
    }

    public func send(parameters: MessageParameters) -> Future<Void, Error> {
        Future<Void, Error> { promise in
            CreateConversation(
                subject: parameters.subject,
                body: parameters.body,
                recipientIDs: parameters.recipientIDs,
                canvasContextID: parameters.context.canvasContextID,
                attachmentIDs: parameters.attachmentIDs)
            .fetch { _, _, error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }
    }
}
