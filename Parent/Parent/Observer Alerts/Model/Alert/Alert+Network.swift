//
// Copyright (C) 2016-present Instructure, Inc.
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
import ReactiveSwift
import Marshal
import CanvasCore

extension Alert {
    static func getObserveeAlerts(_ session: Session, observeeID: String) throws -> SignalProducer<[JSONObject], NSError> {
        let request = try AlertAPI.getAlertsForParent(session, observerID: session.user.id, studentID: observeeID)
        return session.paginatedJSONSignalProducer(request)
    }

    static func getAlerts(_ session: Session) throws -> SignalProducer<[JSONObject], NSError> {
        let request = try AlertAPI.getAlerts(session)
        return session.paginatedJSONSignalProducer(request)
    }

    func markAsRead(_ read: Bool, session: Session) throws -> SignalProducer<JSONObject, NSError> {
        let request = try AlertAPI.updateAlert(session, observerID: session.user.id, alertID: id, read: read)
        return session.JSONSignalProducer(request)
    }

    func markDismissed(_ dismissed: Bool, session: Session) throws -> SignalProducer<JSONObject, NSError> {
        let request = try AlertAPI.updateAlert(session, observerID: session.user.id, alertID: id, dismissed: dismissed)
        return session.JSONSignalProducer(request)
    }
}
