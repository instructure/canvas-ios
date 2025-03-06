//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
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
import Core

class AttendanceStatusController {
    let session: RollCallSession
    var currentStatus: Status
    var pendingStatus: Status?
    var timer: Timer?

    var statusDidChange: () -> Void = {}
    var statusUpdateDidFail: (Error) -> Void = {_ in}

    var status: Status {
        return pendingStatus ?? currentStatus
    }

    init(
        status: Status,
        in session: RollCallSession
    ) {
        self.session = session
        self.currentStatus = status
    }

    func update(attendance: Attendance?) {
        var pending = currentStatus
        pending.attendance = attendance
        pendingStatus = pending
        statusDidChange()
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
            self.session.updateStatus(pending) { newID, error in performUIUpdate {
                self.pendingStatus = nil
                defer { self.statusDidChange() }

                if let e = error {
                    return self.statusUpdateDidFail(e)
                }

                self.currentStatus = pending
                self.currentStatus.id = newID
            } }
        }
    }
}
