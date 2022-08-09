//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

import AVFoundation
import Combine

class FilePreviewProvider {
    enum PreviewType {
        case pdf(fileName: String)
        case image(UIImage)
        case movie(UIImage, duration: Double)
        case unknown
    }

    public private(set) lazy var result: AnyPublisher<PreviewType?, Never> = resultSubject.eraseToAnyPublisher()

    private let url: URL
    private let resultSubject = CurrentValueSubject<PreviewType?, Never>(nil)

    public init(url: URL) {
        self.url = url
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            self.resultSubject.send(self.determineType())
        }
    }

    private func determineType() -> PreviewType {
        if isPDFDocument() {
            return .pdf(fileName: url.lastPathComponent)
        } else if let image = image() {
            return .image(image)
        } else if let movieData = self.movieData {
            return .movie(movieData.firstFrame, duration: movieData.movieLength)
        } else {
            return .unknown
        }
    }

    private var movieData: (firstFrame: UIImage, movieLength: Double)? {
        guard url.pathExtension.lowercased() == "mov" else { return nil }

        let asset = AVURLAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true

        guard let cgImage = try? imageGenerator.copyCGImage(at: .zero, actualTime: nil) else { return nil }

        return (firstFrame: UIImage(cgImage: cgImage), movieLength: asset.duration.seconds)
    }

    private func isPDFDocument() -> Bool {
        url.pathExtension.lowercased().hasSuffix("pdf")
    }

    private func image() -> UIImage? {
        guard let imageData = try? Data(contentsOf: url), let uiImage = UIImage(data: imageData) else {
            return nil
        }

        return uiImage
    }
}
