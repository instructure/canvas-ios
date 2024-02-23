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

public enum AttachmentPickerAssembly {
    public static func makeAttachmentPickerViewController(
        env: AppEnvironment = .shared,
        batchId: String,
        uploadManager: UploadManager
    ) -> UIViewController {
        let interactor = AttachmentPickerInteractorLive(batchId: batchId, uploadManager: uploadManager)
        let viewModel = AttachmentPickerViewModel(router: env.router, interactor: interactor)
        let view = AttachmentPickerView(model: viewModel)
        return CoreHostingController(view)
    }

    public static func makeAudioPickerViewcontroller(
        router: Router,
        onSelect: @escaping (URL) -> Void = { _ in }
    ) -> AudioPickerView {
        let viewModel = AudioPickerViewModel(router: router, interactor: AudioPickerInteractorLive(), onSelect: onSelect)
        return AudioPickerView(viewModel: viewModel)
    }

#if DEBUG

    public static func makePreview(env: AppEnvironment)
    -> AttachmentPickerView {
        let interactor = AttachmentPickerInteractorPreview()
        let viewModel = AttachmentPickerViewModel(router: env.router, interactor: interactor)
        return AttachmentPickerView(model: viewModel)
    }

    public static func makeAudioPickerPreview(
        env: AppEnvironment
    ) -> AudioPickerView {
        let viewModel = AudioPickerViewModel(router: env.router, interactor: AudioPickerInteractorPreview(), onSelect: {_ in })
        return AudioPickerView(viewModel: viewModel)
    }

#endif
}
