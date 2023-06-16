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

public protocol MessageDetailsInteractor {
    // MARK: - Outputs
    var state: CurrentValueSubject<StoreState, Never> { get }
    var subject: CurrentValueSubject<String, Never> { get }
    var messages: CurrentValueSubject<[ConversationMessage], Never> { get }
    var starred: CurrentValueSubject<Bool, Never> { get }
    // This is an ID-Participant map, reused from the parent implementation
    var userMap: [String: ConversationParticipant] { get }

    // MARK: - Inputs
    func refresh() -> Future<Void, Never>
    func updateStarred(starred: Bool) -> Future<Void, Never>
}
