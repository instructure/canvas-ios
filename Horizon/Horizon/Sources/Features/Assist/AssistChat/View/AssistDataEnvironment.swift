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

import CombineExt

struct AssistDataEnvironment {
    private(set) var courseID = CurrentValueRelay<String?>(nil)
    private(set) var fileID = CurrentValueRelay<String?>(nil)
    private(set) var goal = CurrentValueRelay<Goal?>(nil)
    private(set) var pageURL = CurrentValueRelay<String?>(nil)

    init(
        courseID: String? = nil,
        fileID: String? = nil,
        goal: Goal? = nil,
        pageURL: String? = nil
    ) {
        self.courseID.accept(courseID)
        self.fileID.accept(fileID)
        self.goal.accept(goal)
        self.pageURL.accept(pageURL)
    }

    func duplicate() -> AssistDataEnvironment {
        AssistDataEnvironment(
            courseID: courseID.value,
            fileID: fileID.value,
            goal: goal.value,
            pageURL: pageURL.value
        )
    }
}
