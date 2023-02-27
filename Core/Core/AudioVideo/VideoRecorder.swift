//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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
import CoreServices
import SwiftUI
import UniformTypeIdentifiers

public struct VideoRecorder: UIViewControllerRepresentable {
    public typealias Camera = UIImagePickerController.CameraDevice
    public let action: (URL?) -> Void
    public let camera: Camera

    @Environment(\.presentationMode) var presentationMode

    public init(camera: Camera = .rear, action: @escaping (URL?) -> Void) {
        self.action = action
        self.camera = camera
    }

    public func makeUIViewController(context: Self.Context) -> UIImagePickerController {
        let uiViewController = UIImagePickerController()
        uiViewController.allowsEditing = true
        uiViewController.mediaTypes = [ UTType.movie.identifier ]
        return uiViewController
    }

    public func updateUIViewController(_ uiViewController: UIImagePickerController, context: Self.Context) {
        uiViewController.delegate = context.coordinator
        #if !targetEnvironment(simulator)
            uiViewController.sourceType = .camera
            uiViewController.cameraDevice = camera
        #endif
    }

    public class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let view: VideoRecorder

        init(view: VideoRecorder) {
            self.view = view
        }

        public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            view.action(info[.mediaURL] as? URL)
            view.presentationMode.wrappedValue.dismiss()
        }

        public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            view.action(nil)
            view.presentationMode.wrappedValue.dismiss()
        }
    }

    public func makeCoordinator() -> Coordinator {
        return Coordinator(view: self)
    }

    public static func requestPermission(callback: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            callback(true)
        case .denied, .restricted:
            callback(false)
        default:
            AVCaptureDevice.requestAccess(for: .video) { allowed in performUIUpdate {
                callback(allowed)
            } }
        }
    }
}
