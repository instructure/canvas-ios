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
import CombineSchedulers

public extension APIStudioMediaItem.Caption {
    var vttFileName: String { "\(srclang).vtt" }

    func write(
        to directory: URL
    ) -> AnyPublisher<URL, Error> {
        Just(data)
            .tryMap { stringData in
                var output = "WEBVTT\n\n" + stringData
                output = output.replacingOccurrences(of: ",", with: ".")
                return try output.dataWithError(using: .utf8)
            }
            .map { fileData in
                (fileData, directory.appendingPathComponent(vttFileName, isDirectory: false))
            }
            .tryMap { fileData, fileURL in
                try fileData.write(to: fileURL)
                return fileURL
            }
            .eraseToAnyPublisher()
    }
}

public extension Array where Element == APIStudioMediaItem.Caption {

    func write(
        to directory: URL
    ) -> AnyPublisher<[URL], Error> {
        Publishers
            .Sequence(sequence: self)
            .flatMap { caption in
                caption.write(to: directory)
            }
            .collect()
            .eraseToAnyPublisher()
    }
}
