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

/// Marks a plannable item (assignment, quiz, etc.) as done or not done.
///
/// Canvas uses "planner overrides" to track user-specific modifications to plannable items.
/// When a user marks an item as done, a planner override is created or updated with the
/// `marked_complete` flag. This allows users to track their personal completion status
/// without affecting the actual assignment state on the server.
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
        useCaseId: PlannableUseCaseID? = nil,
        done: Bool
    ) {
        self.plannableId = plannableId
        self.plannableType = plannableType
        self.overrideId = overrideId
        self.done = done
        self.scope = .plannable(id: plannableId, useCase: useCaseId)
    }

    public func makeRequest(environment: AppEnvironment, completionHandler: @escaping RequestCallback) {
        if let overrideId {
            updateExistingOverride(overrideId: overrideId, environment: environment, completionHandler: completionHandler)
        } else {
            createNewOverride(environment: environment, completionHandler: completionHandler)
        }
    }

    public func write(response: APIPlannerOverride?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let response,
              let plannable: Plannable = client.fetch(scope: scope).first
        else {
            return
        }

        plannable.plannerOverrideId = response.id.value
        plannable.isMarkedComplete = done
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
