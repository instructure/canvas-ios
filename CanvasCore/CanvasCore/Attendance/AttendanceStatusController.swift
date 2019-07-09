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

class AttendanceStatusController {
    private let session: RollCallSession
    private var currentStatus: Status
    private var pendingStatus: Status?
    private var timer: Timer?
    
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
        invalidatePreviousUpdate()
        prepareUpdatedStatus(attendance: attendance)
        beginWaitingPeriodTimer(
            then: sendPendingUpdate
        )
    }
    
    private func invalidatePreviousUpdate() {
        self.timer?.invalidate()
        self.timer = nil
        self.pendingStatus = nil
    }
    
    private func prepareUpdatedStatus(attendance: Attendance?) {
        var pending = currentStatus
        pending.attendance = attendance
        pendingStatus = pending
        statusDidChange()
    }
    
    private func beginWaitingPeriodTimer(then timerExpired: @escaping () -> Void) {
        guard pendingStatus != nil else { return }
        
        let timer = Timer(timeInterval: 1, repeats: false, block: { timer in
            timerExpired()
        })
        
        RunLoop.main.add(timer, forMode: RunLoop.Mode.default)
        self.timer = timer
    }
    
    private func sendPendingUpdate() {
        guard let pending = pendingStatus else { return }
        
        session.updateStatus(pending) { newID, error in
            self.pendingStatus = nil
            defer {
                self.statusDidChange()
            }

            if let e = error {
                self.statusUpdateDidFail(e)
                return
            }
            
            var updated = pending
            updated.id = newID
            self.currentStatus = updated
        }
    }
}
