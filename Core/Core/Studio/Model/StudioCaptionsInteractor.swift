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

public protocol StudioCaptionsInteractor {

    func write(
        captions: [APIStudioMediaItem.Caption],
        to directory: URL
    ) -> AnyPublisher<[URL], Error>
}

public class StudioCaptionsInteractorLive: StudioCaptionsInteractor {

    public func write(
        captions: [APIStudioMediaItem.Caption],
        to directory: URL
    ) -> AnyPublisher<[URL], Error> {
        Just(())
            .flatMap { self.deleteAllExistingVttFiles(in: directory) }
            .flatMap { _ in
                Publishers
                    .Sequence(sequence: captions)
                    .flatMap { [self] caption in
                        self.write(caption: caption, to: directory)
                    }
                    .collect()
            }
            .eraseToAnyPublisher()
    }

    private func deleteAllExistingVttFiles(
        in directory: URL
    ) -> AnyPublisher<Void, Error> {
        Just(directory)
            .setFailureType(to: Error.self)
            .tryMap { directory in
                let vttFiles = FileManager.default.allFiles(
                    withExtension: "vtt",
                    inDirectory: directory
                )
                try vttFiles.forEach { vttURL in
                    try FileManager.default.removeItem(at: vttURL)
                }
                return ()
            }
            .eraseToAnyPublisher()
    }

    private func convertSrtToVttFormat(srtCaption: String) -> String {
        var vttCaption = srtCaption

        if !vttCaption.hasPrefix("WEBVTT") {
            vttCaption.insert(contentsOf: "WEBVTT\n\n", at: vttCaption.startIndex)
        }

        // Replace `,` milliseconds separator with `.`
        let pattern = #"(\d{2}:\d{2}:\d{2}),(\d{3}) --> (\d{2}:\d{2}:\d{2}),(\d{3})"#
        // swiftlint:disable:next force_try
        let regex = try! NSRegularExpression(pattern: pattern, options: [])

        vttCaption = regex.stringByReplacingMatches(
            in: vttCaption,
            options: [],
            range: vttCaption.nsRange,
            withTemplate: "$1.$2 --> $3.$4"
        )

        return vttCaption
    }

    private func write(
        caption: APIStudioMediaItem.Caption,
        to directory: URL
    ) -> AnyPublisher<URL, Error> {
        let vttFileName = "\(caption.srclang).vtt"
        return Just(caption.data)
            .tryMap { [self] srtCaptionString in
                let vttCaptionString = convertSrtToVttFormat(srtCaption: srtCaptionString)
                return try vttCaptionString.dataWithError(using: .utf8)
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
