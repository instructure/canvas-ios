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

import Foundation
@testable import Core

enum HProgramCourseStub {

    static func getProgramCourse() -> GetHProgramCourseResponse.ProgramCourse {
        .init(id: "1", name: "Test Course", modulesConnection: getModules(), usersConnection: getUsersConnection())
    }

    static func getModules() -> GetHProgramCourseResponse.ModuleConnection {
        let moduleItems: [GetHProgramCourseResponse.ModuleItem] = [
            .init(published: true, id: "1", estimatedDuration: "12PT"),
            .init(published: false, id: "2", estimatedDuration: "10PT"),
            .init(published: true, id: "3", estimatedDuration: "12PT"),
            .init(published: true, id: "5", estimatedDuration: "20pT")
        ]
        let node: GetHProgramCourseResponse.EdgeNode = .init(id: "modudel - 1", name: "Module 1", moduleItems: moduleItems)
        let edges: [GetHProgramCourseResponse.Edge] =  [ .init(node: node) ]
        return GetHProgramCourseResponse.ModuleConnection(pageInfo: nil, edges: edges)
    }

    static func getUsersConnection() -> GetHProgramCourseResponse.UsersConnection {
        .init(nodes: [.init(courseProgression: .init(requirements: .init(completionPercentage: 0.4)))])
    }
}
