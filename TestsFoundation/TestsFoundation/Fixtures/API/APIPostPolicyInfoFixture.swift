//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

@testable import Core

extension APIPostPolicyInfo {
    public static func make(
        sections: [APIPostPolicyInfo.SectionNode] = [.make()],
        submissions: [APIPostPolicyInfo.SubmissionNode] = [.make()]
    ) -> Self {
        Self(data: PostPolicyData(
            course: Course(sections: Sections(nodes: sections)),
            assignment: Assignment(submissions: Submissions(nodes: submissions))
        ))
    }
}

extension APIPostPolicyInfo.SectionNode {
    public static func make(
        id: String = "1",
        name: String = "section 1"
    ) -> Self {
        Self(id: id, name: name)
    }
}

extension APIPostPolicyInfo.SubmissionNode {
    public static func make(
        score: Double? = 1.0,
        excused: Bool = false,
        state: String = "graded",
        postedAt: Date? = nil
    ) -> Self {
        Self(
            score: score,
            excused: excused,
            state: state,
            postedAt: postedAt
        )
    }
}
