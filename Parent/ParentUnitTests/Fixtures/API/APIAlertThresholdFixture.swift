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
@testable import Parent
@testable import Core
import CoreData
import TestsFoundation

extension APIAlertThreshold {
    public static func make(
    	id: String = "1",
    	observer_id: String = "5",
    	user_id: String = "1",
    	alert_type: String = "assignment_grade_high",
    	threshold: String? = "100"
    ) -> APIAlertThreshold {
        return APIAlertThreshold(
			id: id,
			observer_id: observer_id,
			user_id: user_id,
			alert_type: alert_type,
			threshold: threshold
        )
    }
}

extension Core.AlertThreshold {
    @discardableResult
    public static func make(
        from api: APIAlertThreshold = .make(),
        in context: NSManagedObjectContext = TestsFoundation.singleSharedTestDatabase.viewContext
        ) -> Core.AlertThreshold {
            let model: Core.AlertThreshold = context.insert()
            model.id = api.id
            model.observerID = api.observer_id
            model.studentID = api.user_id
            model.threshold = api.threshold
            model.typeRaw = api.alert_type
            try! context.save()
            return model
    }
}
