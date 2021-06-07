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
    public struct InfoLine: Equatable {
        public let icon: Image
        public let text: String
        public let highlightedText: String

        public init(icon: Image, text: String = "", highlightedText: String = "") {
            self.icon = icon
            self.text = text
            self.highlightedText = highlightedText
        }

        public static func make(from announcement: LatestAnnouncement?) -> InfoLine? {
            guard let announcement = announcement else { return nil }
            return InfoLine(icon: .announcementLine, text: announcement.title)
        }

        public static func make(dueToday: Int, missing: Int) -> InfoLine {
            var text = ""
            var highlightedText = ""

            if dueToday > 0 {
                text = String(format: NSLocalizedString("%d due today", comment: "Number of assignments due today"), dueToday)
            }

            if missing > 0 {
                highlightedText = String(format: NSLocalizedString("%d missing", comment: "Number of missing submissions"), missing)
            }

            if text.isEmpty && highlightedText.isEmpty {
                text = NSLocalizedString("Nothing Due Today", comment: "No due assignments for today")
            } else if !text.isEmpty && !highlightedText.isEmpty {
                text += " | "
            }

            return InfoLine(icon: .k5dueToday, text: text, highlightedText: highlightedText)
        }
    }
}
