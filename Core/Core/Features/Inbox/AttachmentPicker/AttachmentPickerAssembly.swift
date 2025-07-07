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

import Combine
import SwiftUI

public enum AttachmentPickerAssembly {

    /// Allows selecting photo & video
    public static func makeImagePicker(
        onSelect: @escaping (URL) -> Void
    ) -> ImagePickerView {
        ImagePickerView(sourceType: .photoLibrary, imageHandler: onSelect)
    }

    /// Allows taking photo & recording video
    public static func makeImageRecorder(
        onSelect: @escaping (URL) -> Void
    ) -> ImagePickerView {
        ImagePickerView(sourceType: .camera, imageHandler: onSelect)
    }

    /// Allows recording video only
    public static func makeVideoRecorder(
        onSelect: @escaping (URL) -> Void
    ) -> ImagePickerView {
        ImagePickerView(sourceType: .camera, allowedMediaTypes: .videoOnly, imageHandler: onSelect)
    }

    public static func makeAudioRecorder(
        router: Router,
        onSelect: @escaping (URL) -> Void
    ) -> AudioPickerView {
        let interactor = AudioPickerInteractorLive()
        let viewModel = AudioPickerViewModel(router: router, interactor: interactor, onSelect: onSelect)
        return AudioPickerView(viewModel: viewModel)
    }

    public static func makeCanvasFilePicker(
        folderId: String? = nil,
        router: Router,
        onSelect: @escaping (File) -> Void
    ) -> FilePickerView {
        let interactor = FilePickerInteractorLive(folderId: folderId)
        let viewModel = FilePickerViewModel(interactor: interactor, router: router, onSelect: onSelect)
        return FilePickerView(viewModel: viewModel)
    }

#if DEBUG

    public static func makeAudioPickerPreview(env: AppEnvironment) -> AudioPickerView {
        let interactor = AudioPickerInteractorPreview()
        let viewModel = AudioPickerViewModel(router: env.router, interactor: interactor) { _ in }
        return AudioPickerView(viewModel: viewModel)
    }

    public static func makeFilePickerPreview(env: AppEnvironment) -> FilePickerView {
        let interactor = FilePickerInteractorPreview()
        let viewModel = FilePickerViewModel(interactor: interactor, router: env.router) { _ in }
        return FilePickerView(viewModel: viewModel)
    }

#endif
}
