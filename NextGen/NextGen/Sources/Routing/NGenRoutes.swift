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

import Core
import UIKit

public enum NGRoutes {
    public static func makeRouter(
        academicRoutes: [RouteHandler],
        nextgenRoutes: [RouteHandler] = NGRoutes.routes
    ) -> Router {
        let overriddenTemplates = Set(nextgenRoutes.map { $0.route.template })
        let mergedRoutes = nextgenRoutes + academicRoutes.filter { !overriddenTemplates.contains($0.route.template) }
        return Router(routes: mergedRoutes)
    }

    public static var routes: [RouteHandler] {
        [
            RouteHandler("/courses/:courseID", factory: makeCourseDetails),
            RouteHandler("/courses/:courseID/tabs", factory: makeCourseDetails)
        ]
    }

    private static func makeCourseDetails(_: URLComponents, params: [String: String], _: [String: Any]?) -> UIViewController? {
        guard let courseID = params["courseID"] else { return nil }
        return NGCourseDetailsAssembly.makeCourseDetailsViewController(courseID: courseID)
    }
}
