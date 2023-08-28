//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

import SwiftUI

public struct K5GradeCellViewModel {

    public let a11yId: String
    public let title: String
    public let imageURL: URL?
    public let grade: String?
    public let score: Double?
    public let color: Color
    public let route: String
    public let hideGradeBar: Bool

    init(title: String?, imageURL: URL?, grade: String?, score: Double?, color: UIColor?, courseID: String, hideGradeBar: Bool) {
        self.title = title ?? ""
        self.imageURL = imageURL
        self.grade = grade
        self.score = score
        self.color = ((color != nil) ? Color(color!) : .oxford)
        self.a11yId = "K5GradeCell.\(courseID)"
        self.route = "/courses/\(courseID)#grades"
        self.hideGradeBar = hideGradeBar
    }

    public var gradePercentage: Double {
        guard let grade = grade else { return score ?? 0 }
        return Double(grade) ?? 0 / 0.05
    }

    public var roundedDisplayGrade: String {
        guard let score = score else { return grade ?? "" }
        return "\(Int(score.rounded()))%"
    }
}

extension K5GradeCellViewModel: Identifiable {
    public var id: String {
        UUID.string
    }
}
