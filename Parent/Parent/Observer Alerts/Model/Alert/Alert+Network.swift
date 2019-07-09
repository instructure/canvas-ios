//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
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
import ReactiveSwift
import Marshal
import CanvasCore

extension Alert {
    static func getAlerts(_ session: Session, studentID: String) throws -> SignalProducer<[JSONObject], NSError> {
        let request = try AlertAPI.getAlerts(session, studentID: studentID)
        return session.paginatedJSONSignalProducer(request)
    }

    func markAsRead(_ read: Bool, session: Session) throws -> SignalProducer<JSONObject, NSError> {
        let request = try AlertAPI.readAlert(session, alertID: id)
        return session.JSONSignalProducer(request)
    }

    func markDismissed(_ dismissed: Bool, session: Session) throws -> SignalProducer<JSONObject, NSError> {
        let request = try AlertAPI.dismissAlert(session, alertID: id)
        return session.JSONSignalProducer(request)
    }
}
