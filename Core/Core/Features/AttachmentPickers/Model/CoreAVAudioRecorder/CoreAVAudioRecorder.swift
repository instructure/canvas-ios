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

import Foundation

public protocol CoreAVAudioRecorder {

    var currentTime: TimeInterval { get }
    var isMeteringEnabled: Bool { get set }

    init(url: URL, settings: [String: Int]) throws

    func prepareToRecord()
    func record()
    func updateMeters()
    func peakPower(forChannel channelNumber: Int) -> Float
    func stop()
}
