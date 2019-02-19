//
// Copyright (C) 2018-present Instructure, Inc.
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

//
//  Manages the time between app startup and when the first view controller's view appears on the screen
//
//  There is a really awkward time between when the app launches and when you can do post app launch things
//  For example:
//      - Starting up React Native. This can take a while as our entire javascript source needs to be parsed
//      - Routing. There are millions of reason why routing doesn't work right off the bat. The view heiarchy might not be setup and or other issues
//
//  This manager makes sense of all that craziness by taking in blocks that need to be executed post app launch. Once a view controller actually appears on the screen,
//  those blocks are then executed.
//
//  Also manages the launch screen placeholder and animations

public typealias StartupManagerTask = () -> ()

public class StartupManager {
    public static let shared = StartupManager()
    var blocks: [StartupManagerTask] = []
    var startupFinished = false
    
    public func markStartupFinished() {
        startupFinished = true
        executeTasks()
    }
    
    // Enqueues the task if startup sequence is in process
    // If startup is over, executes immediatly
    public func enqueueTask(_ task: @escaping StartupManagerTask) {
        guard startupFinished == false else { return task() }
        blocks.append(task)
    }
    
    func executeTasks() {
        blocks.forEach { (block) in
            block()
        }
        blocks.removeAll()
    }
}

public func StartupIconAnimation() -> CAAnimation {
    let animation = CABasicAnimation(keyPath: "transform.rotation.z")
    animation.fromValue = 0
    animation.toValue = 2 * Double.pi
    animation.repeatCount = 100.0
    animation.duration = 10.0
    return animation
}
