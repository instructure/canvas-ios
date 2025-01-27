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
import AVFAudio

public class CoreAVAudioPlayerPreview: CoreAVAudioPlayer {
    private(set) var isPrepareToPlayCalled: Bool = false
    private(set) var isPlayCalled: Bool = false
    private(set) var isPauseCalled: Bool = false
    private(set) var isStopCalled: Bool = false

    public var duration: TimeInterval { 0 }
    public var currentTime: TimeInterval {
        get { 0 }
        set { _ = newValue }
    }
    public var delegate: AVAudioPlayerDelegate? {
        get { nil }
        set { _ = newValue }
    }
    public var isPlaying: Bool {
        return isPrepareToPlayCalled && isPlayCalled && !isPauseCalled && !isStopCalled
    }

    required public init(contentsOf url: URL) throws { }

    init() { }

    public func prepareToPlay() {
        isPrepareToPlayCalled = true
    }

    public func play() {
        isPlayCalled = true
    }

    public func pause() {
        isPauseCalled = true
    }

    public func stop() {
        isStopCalled = true
    }
}

#endif
