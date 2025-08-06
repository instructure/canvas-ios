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
import Foundation

/// The purpose of the AssistGoal is to provide a base class for goals that can be executed within the Assist chat system.
/// The "Goal"s are used to define specific tasks or objectives that the Assist system can help the user achieve.
protocol AssistTool {
    var name: String { get }

    /// A description of the tool that gets delivered to the AI model for tool selection
    var description: String { get }

    /// After a choice of options is made, we execute
    func execute(response: String?, history: [AssistChatMessage]) -> AnyPublisher<AssistChatMessage?, any Error>

    /// Whether or not this goal should be selected in this list of goals
    var isAvailable: Bool { get }
}
