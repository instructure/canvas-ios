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

public struct K5HomeroomSubjectCardViewModel {
    public let courseId: String
    public let imageURL: URL?
    public let name: String
    public let color: Color
    public let infoLines: [InfoLine]

    public init(courseId: String, imageURL: URL?, name: String, color: UIColor?, infoLines: [InfoLine]) {
        self.courseId = courseId
        self.imageURL = imageURL
        self.name = name
        self.color = ((color != nil) ? Color(color!) : Color(hexString: "#394B58")!)
        self.infoLines = infoLines
    }
}

extension K5HomeroomSubjectCardViewModel {
    public struct InfoLine {
        public let icon: Image
        public let text: String
    }
}
