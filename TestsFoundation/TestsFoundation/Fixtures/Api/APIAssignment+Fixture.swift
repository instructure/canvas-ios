//
// Copyright (C) 2018-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation
@testable import Core

extension APIAssignment: Fixture {
    public static var template: Template {
        return [
            "id": "1",
            "course_id": "2",
            "name": "some assignment",
            "description": "<p>Do the following:</p>...",
            "points_possible": 10,
            "due_at": nil,
            "html_url": "https://canvas.instructure.com/courses/2/assignments/1",
            "grading_type": "pass_fail",
            "submission_types": ["on_paper"],
            "submission": APISubmission.template,
        ]
    }
}
