//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

import Foundation

// undocumented
struct APIDashboardCardLink: Codable, Equatable {
    let css_class: String
    let hidden: Bool?
    let icon: String
    let label: String
    let path: String
}

public struct APIDashboardCard: Codable, Equatable {
    let assetString: String
    let courseCode: String
    /** Teacher assigned hex color for K5 courses */
    let color: String?
    let enrollmentType: String
    let href: String
    let id: ID
    let image: String?
    let isHomeroom: Bool?
    let isK5Subject: Bool?
    let links: [APIDashboardCardLink]
    let longName: String
    let originalName: String
    let position: Int?
    let shortName: String
    let subtitle: String
    let term: String?
}

#if DEBUG
extension APIDashboardCard {
    static func make(
        assetString: String = "course_1",
        courseCode: String = "C1",
        color: String? = nil,
        enrollmentType: String = "StudentEnrollment",
        href: String = "/courses/1",
        id: ID = 1,
        image: String? = nil,
        isHomeroom: Bool? = false,
        isK5Subject: Bool? = false,
        links: [APIDashboardCardLink] = [],
        longName: String = "Course 1",
        originalName: String = "Course 1",
        position: Int? = nil,
        shortName: String = "Course 1",
        subtitle: String = "enrolled as: Student",
        term: String? = nil
    ) -> APIDashboardCard {
        return APIDashboardCard(
            assetString: assetString,
            courseCode: courseCode,
            color: color,
            enrollmentType: enrollmentType,
            href: href,
            id: id,
            image: image,
            isHomeroom: isHomeroom,
            isK5Subject: isK5Subject,
            links: links,
            longName: longName,
            originalName: originalName,
            position: position,
            shortName: shortName,
            subtitle: subtitle,
            term: term
        )
    }
}
#endif

public struct GetDashboardCardsRequest: APIRequestable {
    public typealias Response = [APIDashboardCard]
    public var path: String { "dashboard/dashboard_cards" }
}
