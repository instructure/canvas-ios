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
import SwiftUI

public struct ImagePickerViewController: UIViewControllerRepresentable {
    public typealias ImagePickedHandler = (URL) -> Void
    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let sourceType: UIImagePickerController.SourceType
    let imageHandler: ImagePickedHandler

    public init(sourceType: UIImagePickerController.SourceType, imageHandler: @escaping ImagePickedHandler) {
        self.sourceType = sourceType
        self.imageHandler = imageHandler
    }

    public func makeCoordinator() -> Coordinator {
        return Coordinator(self, imageHandler: imageHandler)
    }

    public func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePickerViewController>) -> UIImagePickerController {

        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator
        if let mediaTypes = UIImagePickerController.availableMediaTypes(for: .camera) {
            imagePicker.mediaTypes = mediaTypes
        }

        return imagePicker
    }

    public func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePickerViewController>) {
    }

    final public class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

        let parent: ImagePickerViewController
        let imageHandler: ImagePickedHandler

        init(_ parent: ImagePickerViewController, imageHandler: @escaping ImagePickedHandler) {
            self.parent = parent
            self.imageHandler = imageHandler
        }

        public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {

            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                if let url = try? image.write() {
                    imageHandler(url)
                }
            }

            if let url = info[.mediaURL] as? URL {
                imageHandler(url)
            }
        }
    }
}
