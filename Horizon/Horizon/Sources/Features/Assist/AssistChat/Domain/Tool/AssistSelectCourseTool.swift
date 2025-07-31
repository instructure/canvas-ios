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

struct AssistSelectCourseTool: AssistTool {
    var description: String = "When the user has not yet selected a course, the user will be asked to select a course"

    private let environment: AssistDataEnvironment

    init(environment: AssistDataEnvironment) {
        self.environment = environment
    }

    func isRequested() -> Bool {
        environment.courseID.value == nil
    }
    
    func execute() -> AnyPublisher<AssistChatMessage?, any Error> {
        
    }
}
