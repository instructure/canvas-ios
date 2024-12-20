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

public class PlannerOverrideUpdater {
    public let plannableId: ID
    public let plannableType: String
    public private(set) var overrideId: ID?
    public var updateInProgress: Bool { completion != nil }

    private let api: API
    private var completion: ((_ succeeded: Bool) -> Void)?

    public init(api: API, plannableId: ID, plannableType: String, overrideId: ID?) {
        self.api = api
        self.plannableId = plannableId
        self.plannableType = plannableType
        self.overrideId = overrideId
    }

    public convenience init(api: API, plannable: APIPlannable) {
        self.init(api: api, plannableId: plannable.plannable_id, plannableType: plannable.plannable_type, overrideId: plannable.planner_override?.id)
    }

    public func markAsComplete(isComplete: Bool, completion: @escaping (_ succeeded: Bool) -> Void) {
        if updateInProgress { return }

        self.completion = completion

        if let overrideId = overrideId?.value {
            let request = UpdatePlannerOverrideRequest(overrideId: overrideId, body: .init(marked_complete: isComplete))
            api.makeRequest(request) { [weak self] _, _, error in
                self?.completion?(error == nil)
                self?.completion = nil
            }
        } else {
            let request = CreatePlannerOverrideRequest(body: .init(plannable_type: plannableType, plannable_id: plannableId.value, marked_complete: isComplete))
            api.makeRequest(request) { [weak self] newOverride, _, error in
                // We save the created ID so the next update doesn't want to re-create it again but will update instead
                self?.overrideId = newOverride?.id
                self?.completion?(error == nil)
                self?.completion = nil
            }
        }
    }
}
