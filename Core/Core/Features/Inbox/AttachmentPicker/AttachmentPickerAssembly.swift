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
import Combine

public enum AttachmentPickerAssembly {
    public static func makeAudioPickerViewcontroller(
        router: Router,
        onSelect: @escaping (URL) -> Void = { _ in }
    ) -> AudioPickerView {
        let viewModel = AudioPickerViewModel(router: router, interactor: AudioPickerInteractorLive(), onSelect: onSelect)
        return AudioPickerView(viewModel: viewModel)
    }

    public static func makeFilePickerViewController(
        env: AppEnvironment = .shared,
        folderId: String? = nil,
        onSelect: @escaping (File) -> Void = { _ in }
    ) -> UIViewController {
        let interactor = FilePickerInteractorLive(folderId: folderId)
        let viewModel = FilePickerViewModel(env: env, interactor: interactor, onSelect: onSelect)
        let view = FilePickerView(viewModel: viewModel)
        return CoreHostingController(view)
    }

#if DEBUG

    public static func makeAudioPickerPreview(
        env: AppEnvironment
    ) -> AudioPickerView {
        let viewModel = AudioPickerViewModel(router: env.router, interactor: AudioPickerInteractorPreview(), onSelect: {_ in })
        return AudioPickerView(viewModel: viewModel)
    }

    public static func makeFilePickerPreview(env: AppEnvironment) -> FilePickerView {
        let viewModel = FilePickerViewModel(env: env, interactor: FilePickerInteractorPreview(), onSelect: { _ in })
        return FilePickerView(viewModel: viewModel)
    }

#endif
}
