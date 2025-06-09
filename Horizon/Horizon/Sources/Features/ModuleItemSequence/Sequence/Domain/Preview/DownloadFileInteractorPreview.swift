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

#if DEBUG
import Foundation
import Combine
import Core

class DownloadFileInteractorPreview: DownloadFileInteractor {
    func download(file: Core.File) -> AnyPublisher<URL, any Error> {
        Just(URL(string: "https://github.com/instructure/canvas-ios")!)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func download(fileID: String) -> AnyPublisher<URL, Error> {
        Just(URL(string: "https://github.com/instructure/canvas-ios")!)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func download(
        remoteURL: URL,
        fileName: String
    ) -> AnyPublisher<URL, Error> {
        Just(URL(string: "https://github.com/instructure/canvas-ios")!)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
#endif
