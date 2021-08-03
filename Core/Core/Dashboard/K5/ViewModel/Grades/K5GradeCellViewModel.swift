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
    public let grade: Int
    public let color: Color
    public let courseID: String

    init(a11yId: String, title: String, imageURL: URL?, grade: Int, color: UIColor?, courseID: String) {
        self.a11yId = a11yId
        self.title = title
        self.imageURL = imageURL
        self.grade = grade
        self.color = ((color != nil) ? Color(color!) : Color(hexString: "#394B58")!)
        self.courseID = courseID
    }
}

extension K5GradeCellViewModel: Identifiable {
    public var id: String { a11yId }
}
