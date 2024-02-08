//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

#if DEBUG

import Foundation

public class CoreAVAudioRecorderPreview: CoreAVAudioRecorder {

    private(set) var isPrepareToRecordCalled: Bool = false
    private(set) var isRecordCalled: Bool = false
    private(set) var isStopCalled: Bool = false
    private(set) var isPeakPowerCalled: Bool = false
    private(set) var isUpdateMetersCalled: Bool = false
    private(set) var meteringValue: Bool = false

    public var currentTime: TimeInterval { 0 }

    public var isMeteringEnabled: Bool = false

    required public init(url: URL, settings: [String: Int]) throws {}

    init() {}

    public func prepareToRecord() {
        isPrepareToRecordCalled = true
    }

    public func record() {
        isRecordCalled = true
    }

    public func updateMeters() {
        isUpdateMetersCalled = true
    }

    public func peakPower(forChannel channelNumber: Int) -> Float {
        isPeakPowerCalled = true
        return 0
    }

    public func stop() {
        isStopCalled = true
    }
}

#endif
