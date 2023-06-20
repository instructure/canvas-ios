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

#if DEBUG

import Combine

public class MessageDetailsInteractorPreview: MessageDetailsInteractor {

    // MARK: - Outputs
    public var state = CurrentValueSubject<StoreState, Never>(.loading)
    public var subject = CurrentValueSubject<String, Never>("")
    public var messages = CurrentValueSubject<[ConversationMessage], Never>([])
    public var starred = CurrentValueSubject<Bool, Never>(true)
    public var userMap: [String: ConversationParticipant] = [:]

    public init(env: AppEnvironment, subject: String, messages: [ConversationMessage] = []) {
        self.subject = CurrentValueSubject<String, Never>(subject)
        self.messages = CurrentValueSubject<[ConversationMessage], Never>(messages)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [self] in
            if messages.isEmpty {
                state.send(.empty)
            } else {
                state.send(.data)
            }
        }
    }

    public func refresh() -> Future<Void, Never> {
        Future<Void, Never> { promise in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                promise(.success(()))
            }
        }
    }

    public func updateStarred(starred: Bool) -> Future<Void, Never> {
        Future<Void, Never> { promise in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.starred.send(!starred)
                promise(.success(()))
            }
        }
    }
}

#endif
