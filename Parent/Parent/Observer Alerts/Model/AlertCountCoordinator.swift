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
import CoreData
import CanvasCore

open class AlertCountCoordinator: ManagedObjectCountObserver<Alert> {
    fileprivate let session: Session
    fileprivate let studentID: String

    @objc public init(session: Session, studentID: String, predicate: NSPredicate, alertCountUpdated: @escaping (Int) -> Void) {
        self.session = session
        self.studentID = studentID
        //  swiftlint:disable:next force_try
        let context = try! session.alertsManagedObjectContext()

        super.init(predicate: predicate, inContext: context, objectCountUpdated: alertCountUpdated)
    }

    @objc open func refresh() {
        guard let remote = try? Alert.getAlerts(session, studentID: studentID) else { return }
        let sync = Alert.syncSignalProducer(inContext: context, fetchRemote: remote)
        _ = sync.start { event in
            switch event {
            case .failed(let e):
                if e.code == 401 {
                    AirwolfAPI.validateSessionAndLogout(self.session, parentID: self.session.user.id)
                }
                print(e)
                fallthrough
            default:
                break
            }
        }
    }
}
