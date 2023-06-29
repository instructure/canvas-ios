//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

extension DataSeeder {

    public func createModuleItem(courseId: String, moduleId: String, moduleItemBody: CreateDSModuleItemRequest.RequestedDSModuleItem) -> DSModuleItem {
        let requestedBody = CreateDSModuleItemRequest.Body(module_item: moduleItemBody)
        let request = CreateDSModuleItemRequest(body: requestedBody, courseId: courseId, moduleId: moduleId)
        return makeRequest(request)
    }

    public func updateModuleItemWithPublished(courseId: String, moduleId: String, itemId: String, published: Bool) -> DSModuleItem {
        let requestedBody = UpdateDSModuleItemRequest.Body(module_item: .init(published: published))
        let request = UpdateDSModuleItemRequest(body: requestedBody, courseId: courseId, moduleId: moduleId, itemId: itemId)
        return makeRequest(request)
    }
}
