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
    public let a11yId: String
    public let courseRoute: String
    public let imageURL: URL?
    public let name: String
    public let color: Color
    public let infoLines: [InfoLine]

    public init(courseId: String, imageURL: URL?, name: String, color: UIColor?, infoLines: [InfoLine]) {
        self.a11yId = "DashboardCourseCell.\(courseId)"
        self.courseRoute = "/courses/\(courseId)"
        self.imageURL = imageURL
        self.name = name.uppercased()
        self.color = {
            if let color {
                return Color(color.ensureContrast(against: .backgroundLightest))
            } else {
                return .textDarkest
            }
        }()
        self.infoLines = infoLines
    }
}

extension K5HomeroomSubjectCardViewModel {
    public struct InfoLine: Equatable {
        public let icon: Image
        public let route: String
        public let text: String
        public let highlightedText: String

        public init(icon: Image, route: String, text: String = "", highlightedText: String = "") {
            self.icon = icon
            self.route = route
            self.text = text
            self.highlightedText = highlightedText
        }

        public static func make(from announcement: LatestAnnouncement?, courseId: String) -> InfoLine? {
            guard let announcement = announcement else { return nil }
            return InfoLine(icon: .announcementLine, route: "/courses/\(courseId)", text: announcement.title)
        }

        public static func make(dueToday: Int, missing: Int, courseId: String) -> InfoLine {
            var text = ""
            var highlightedText = ""

            if dueToday > 0 {
                text = String(format: String(localized: "%d due today", bundle: .core, comment: "Number of assignments due today"), dueToday)
            }

            if missing > 0 {
                highlightedText = String(format: String(localized: "%d missing", bundle: .core, comment: "Number of missing submissions"), missing)
            }

            if text.isEmpty && highlightedText.isEmpty {
                text = String(localized: "Nothing Due Today", bundle: .core, comment: "No due assignments for today")
            } else if !text.isEmpty && !highlightedText.isEmpty {
                text += " | "
            }

            return InfoLine(icon: .k5dueToday, route: "/courses/\(courseId)#schedule", text: text, highlightedText: highlightedText)
        }
    }
}
