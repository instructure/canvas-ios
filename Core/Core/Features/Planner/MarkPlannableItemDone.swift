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
import CoreData

public struct MarkPlannableItemDone: UseCase {
    public typealias Model = Plannable
    public typealias Response = APIPlannerOverride

    public let cacheKey: String? = nil
    public let scope: Scope

    public let plannableId: String
    public let plannableType: String
    public let overrideId: String?
    public let done: Bool

    public init(
        plannableId: String,
        plannableType: String,
        overrideId: String?,
        done: Bool
    ) {
        self.plannableId = plannableId
        self.plannableType = plannableType
        self.overrideId = overrideId
        self.done = done
        self.scope = .plannable(id: plannableId)
    }

    public func makeRequest(environment: AppEnvironment, completionHandler: @escaping RequestCallback) {
        if let overrideId = overrideId {
            updateExistingOverride(overrideId: overrideId, environment: environment, completionHandler: completionHandler)
        } else {
            createNewOverride(environment: environment, completionHandler: completionHandler)
        }
    }

    public func write(response: APIPlannerOverride?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let response = response,
              let plannable: Plannable = client.fetch(scope: scope).first
        else {
            return
        }

        plannable.plannerOverrideId = response.id.value
        plannable.isMarkedComplete = done
    }

    public func reset(context: NSManagedObjectContext) {
    }

    // MARK: - Private Methods

    private func createNewOverride(environment: AppEnvironment, completionHandler: @escaping RequestCallback) {
        let request = CreatePlannerOverrideRequest(
            body: .init(
                plannable_type: plannableType,
                plannable_id: plannableId,
                marked_complete: done
            )
        )
        environment.api.makeRequest(request, callback: completionHandler)
    }

    private func updateExistingOverride(overrideId: String, environment: AppEnvironment, completionHandler: @escaping RequestCallback) {
        let request = UpdatePlannerOverrideRequest(
            overrideId: overrideId,
            body: .init(marked_complete: done)
        )
        environment.api.makeRequest(request, callback: completionHandler)
    }
}
