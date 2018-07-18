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

extension Quiz {
    var timed: Bool {
        switch timeLimit {
        case .minutes( _):
            return true
        default:
            return false
        }
    }
}

class QuizSubmissionTimerController: NSObject {
    
    let quiz: Quiz
    let timedQuizSubmissionService: TimedQuizSubmissionService
    var submission: QuizSubmission?
    
    fileprivate (set) var timerTime = 0
    var timerTick: (_ currentTime: Int)->() = { _ in }
    var timeExpired: ()->() = {}
    
    fileprivate var timer: Timer?
    fileprivate var timeSyncTimer: Timer?
    
    init(quiz: Quiz, timedQuizSubmissionService: TimedQuizSubmissionService) {
        self.quiz = quiz
        self.timedQuizSubmissionService = timedQuizSubmissionService
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func startSubmission(_ submission: QuizSubmission) {
        self.submission = submission
        
        syncStartingTime()
        syncTimeWithServer()
        NotificationCenter.default.addObserver(self, selector: #selector(QuizSubmissionTimerController.applicationBecameActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        
        startTimers()
    }
    
    func stopTimedSubmission() {
        invalidateTimers()
        NotificationCenter.default.removeObserver(self)
    }
    
    func applicationBecameActive() {
        syncStartingTime()
        syncTimeWithServer()
        
        invalidateTimers()
        startTimers()
    }
    
    fileprivate func startTimers() {
        timer = Timer(timeInterval: 1.0, target: self, selector: #selector(QuizSubmissionTimerController.updateTimer), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: RunLoopMode.commonModes)
        
        timeSyncTimer = Timer(timeInterval: 30.0, target: self, selector: #selector(QuizSubmissionTimerController.syncTimeWithServer), userInfo: nil, repeats: true)
        RunLoop.main.add(timeSyncTimer!, forMode: RunLoopMode.commonModes)
    }
    
    fileprivate func invalidateTimers() {
        timer?.invalidate()
        timer = nil
        
        timeSyncTimer?.invalidate()
        timeSyncTimer = nil
    }
    
    fileprivate func syncStartingTime() {
        if quiz.timed {
            if let submission = submission {
                var secondsTimeLimit = 0
                switch quiz.timeLimit {
                case .minutes(let minutes):
                    secondsTimeLimit = minutes * 60
                default: break
                }
                
                let startTime = submission.dateStarted!
                let currentTime = Date()
                let diff = currentTime.timeIntervalSince(startTime as Date)
                timerTime = secondsTimeLimit - Int(diff)
            }
        } else {
            if let submission = submission, let startTime = submission.dateStarted {
                let currentTime = Date()
                let diff = currentTime.timeIntervalSince(startTime as Date)
                timerTime = Int(diff)
            }
        }
    }
    
    func updateTimer() {
        if quiz.timed {
            timerTime -= 1
        } else {
            timerTime += 1
        }
        
        timerTick(timerTime)
        
        if timerTime <= 0 && quiz.timed {
            stopTimedSubmission()
            timeExpired()
        }
    }
    
    func syncTimeWithServer() {
        if quiz.timed {
            timedQuizSubmissionService.getTimeRemaining { [weak self] result in
                if let secondsLeft = result.value {
                    if let me = self {
                        me.timerTime = secondsLeft
                    }
                }
            }
        }
    }
}
