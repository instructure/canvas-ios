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

import Foundation
import Core
import SwiftUI

struct FileDetailsAssembly {
    static func makeView(
        courseID: String,
        fileID: String,
        context: Context,
        fileName: String
    ) -> FileDetailsView {
        let interactor = DownloadFileInteractorLive(courseID: courseID)
        let router = AppEnvironment.shared.router
        let viewModel = FileDetailsViewModel(interactor: interactor, router: router)
        return FileDetailsView(
            viewModel: viewModel,
            context: context,
            fileID: fileID,
            fileName: fileName
        )
    }

#if DEBUG
    static func makePreview() -> FileDetailsView {
        let interactor = DownloadFileInteractorPreview()
        let router = AppEnvironment.shared.router
        let viewModel = FileDetailsViewModel(interactor: interactor, router: router)
        let view = FileDetailsView(
            viewModel: viewModel,
            context: nil,
            fileID: "23",
            fileName: "AI for Everyone.pdf"
        )
        return view
    }
#endif
}
