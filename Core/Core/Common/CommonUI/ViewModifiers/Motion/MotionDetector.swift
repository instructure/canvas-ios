//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

import CoreMotion

public class MotionDetector: ObservableObject {
    @Published public private(set) var pitch: Double = 0
    @Published public private(set) var roll: Double = 0

    private let manager: CMMotionManager
    private var initialAttitude: CMAttitude?

    init() {
        self.manager = CMMotionManager()
        self.manager.deviceMotionUpdateInterval = 1/60
        self.manager.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
            self?.updateOrientation(motion)
        }
    }

    deinit {
        manager.stopDeviceMotionUpdates()
    }

    private func updateOrientation(_ motion: CMDeviceMotion?) {
        guard let motion = motion else { return }
        guard let initialAttitude = initialAttitude else {
            self.initialAttitude = motion.attitude
            return
        }

        let attitude = motion.attitude
        attitude.multiply(byInverseOf: initialAttitude)

        pitch = attitude.pitch
        roll = attitude.roll
    }
}
