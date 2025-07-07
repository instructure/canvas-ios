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
import UniformTypeIdentifiers

public struct ImagePickerView: UIViewControllerRepresentable {

    public enum MediaType {
        case photoOnly
        case videoOnly
        case photoAndVideo
    }

    public typealias ImagePickedHandler = (URL) -> Void

    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private let sourceType: UIImagePickerController.SourceType
    private let allowedMediaTypes: MediaType
    private let imageHandler: ImagePickedHandler

    public init(
        sourceType: UIImagePickerController.SourceType,
        allowedMediaTypes: MediaType = .photoAndVideo,
        imageHandler: @escaping ImagePickedHandler
    ) {
        self.sourceType = sourceType
        self.allowedMediaTypes = allowedMediaTypes
        self.imageHandler = imageHandler
    }

    public func makeCoordinator() -> Coordinator {
        return Coordinator(self, imageHandler: imageHandler)
    }

    public func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePickerView>) -> UIImagePickerController {

        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator

        switch allowedMediaTypes {
        case .photoOnly:
            imagePicker.mediaTypes = [UTType.image.identifier]
        case .videoOnly:
            imagePicker.mediaTypes = [UTType.movie.identifier]
        case .photoAndVideo:
            if let mediaTypes = UIImagePickerController.availableMediaTypes(for: .camera) {
                imagePicker.mediaTypes = mediaTypes
            }
        }

        return imagePicker
    }

    public func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePickerView>) {
    }

    final public class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

        let parent: ImagePickerView
        let imageHandler: ImagePickedHandler

        init(_ parent: ImagePickerView, imageHandler: @escaping ImagePickedHandler) {
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
