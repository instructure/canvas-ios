//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

import AVKit
import Foundation

public protocol AVPermissionInteractor {
    var isCameraPermitted: Bool? { get }
    var isMicrophonePermitted: Bool? { get }

    func requestCameraPermission(_ response: @escaping (Bool) -> Void)
    func requestMicrophonePermission(_ response: @escaping (Bool) -> Void)
}

public struct AVPermissionInteractorLive: AVPermissionInteractor {
    public init() { }

    public var isCameraPermitted: Bool? {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: true
        case .denied, .restricted: false
        default: nil
        }
    }

    public var isMicrophonePermitted: Bool? {
        switch AVAudioApplication.shared.recordPermission {
        case .granted: true
        case .denied: false
        default: nil
        }
    }

    public func requestCameraPermission(_ response: @escaping (Bool) -> Void) {
        AVCaptureDevice.requestAccess(for: .video, completionHandler: response)
    }

    public func requestMicrophonePermission(_ response: @escaping (Bool) -> Void) {
        AVAudioApplication.requestRecordPermission(completionHandler: response)
    }
}
