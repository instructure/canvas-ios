//
//  AttendanceStatusController.swift
//  AttendanceLE
//
//  Created by Derrick Hathaway on 10/19/17.
//  Copyright © 2017 Instructure. All rights reserved.
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
        
        RunLoop.main.add(timer, forMode: .defaultRunLoopMode)
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
