//
// Copyright (C) 2019-present Instructure, Inc.
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
import Core
import CanvasCore

let router = Core.Router(routes: [
    RouteHandler(.modules(forCourse: ":courseID"), name: "course_modules") { _, params in
        guard let courseID = params["courseID"] else { return nil }
        return ModuleListViewController.create(courseID: courseID)
    },

    RouteHandler(.module(forCourse: ":courseID", moduleID: ":moduleID"), name: "course_module_item") { _, params in
        guard let courseID = params["courseID"], let moduleID = params["moduleID"] else { return nil }
        return ModuleItemListViewController.create(courseID: courseID, moduleID: moduleID)
    }
])
