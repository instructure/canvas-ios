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
import PDFKit

public class FilePreviewProvider {
    public struct FailedToGeneratePreview: Error {}
    public struct PreviewData {
        public let image: UIImage
        public let duration: Double?
    }
    public private(set) lazy var result: AnyPublisher<PreviewData, Error> = resultSubject.eraseToAnyPublisher()
    public let url: URL
    private let resultSubject = PassthroughSubject<PreviewData, Error>()

    public init(url: URL) {
        self.url = url
    }

    /** Starts the asynchronous loading of preview data from the given url. */
    public func load() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }

            if let previewData = self.generatePreview() {
                self.resultSubject.send(previewData)
                self.resultSubject.send(completion: .finished)
            } else {
                self.resultSubject.send(completion: .failure(FailedToGeneratePreview()))
            }
        }
    }

    private func generatePreview() -> PreviewData? {
        if let image = image() {
            return PreviewData(image: image, duration: nil)
        } else if let pdf = pdf() {
            return PreviewData(image: pdf, duration: nil)
        } else if let movieData = movieData() {
            return PreviewData(image: movieData.firstFrame, duration: movieData.movieLength)
        } else {
            return nil
        }
    }

    private func movieData() -> (firstFrame: UIImage, movieLength: Double)? {
        let asset = AVURLAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true

        guard let cgImage = try? imageGenerator.copyCGImage(at: .zero, actualTime: nil) else { return nil }

        return (firstFrame: UIImage(cgImage: cgImage), movieLength: asset.duration.seconds)
    }

    /** Creates a thumbnail from the given URL if it's an image without reading the whole file into memory. */
    private func image() -> UIImage? {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        let maxDimensionInPixels: CGFloat = 200 * UIScreen.main.scale
        let downsampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceCreateThumbnailFromImageIfAbsent: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels
        ] as CFDictionary

        guard let imageSource = CGImageSourceCreateWithURL(url as CFURL, imageSourceOptions),
              let downsampledImage =  CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions)
        else {
            return nil
        }

        return UIImage(cgImage: downsampledImage)
    }

    private func pdf() -> UIImage? {
        guard
            let pdf = PDFDocument(url: url),
            let page = pdf.page(at: 0)
        else {
            return nil
        }
        let bounds = page.bounds(for: .mediaBox)

        return page.thumbnail(
            of: bounds.size,
            for: .mediaBox
        )
    }
}
