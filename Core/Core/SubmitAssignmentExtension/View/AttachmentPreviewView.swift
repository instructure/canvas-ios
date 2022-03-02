//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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
import SwiftUI

public struct AttachmentPreviewView: View {
    private let url: URL
    private let size: CGFloat = 200
    private let videoLengthFormatter = DateComponentsFormatter()
    private var isPDFDocument: Bool { url.pathExtension.lowercased().hasSuffix("pdf") }

    public init(url: URL) {
        self.url = url
        videoLengthFormatter.allowedUnits = [.second, .minute]
        videoLengthFormatter.zeroFormattingBehavior = .pad
    }

    public var body: some View {
        if isPDFDocument {
            pdfPreview(fileName: url.lastPathComponent)
        } else if let image = self.image {
            imagePreview(image)
        } else if let movieData = self.movieData {
            moviePreview(movieData.frame, movieLength: movieData.movieLength)
        } else {
            noPreview
        }
    }

    public func imagePreview(_ image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: size, height: size)
            .clipped()
    }

    public func moviePreview(_ frame: UIImage, movieLength: Double) -> some View {
        ZStack(alignment: .bottomTrailing) {
            Image(uiImage: frame)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .contentShape(Rectangle())
                .frame(width: size, height: size)
                .clipped()
            Text(videoLengthFormatter.string(from: movieLength) ?? "")
                .font(.bold13)
                .padding(4)
                .background(Color.black.opacity(0.4))
                .foregroundColor(.textLightest)
        }
        .frame(width: size, height: size)
    }

    public var noPreview: some View {
        ZStack {
            Image.noSolid
                .resizable()
                .foregroundColor(.textDark)
                .opacity(0.1)
                .padding()
            Text("No preview available", comment: "")
                .font(.regular17)
                .foregroundColor(.textDarkest)
        }
        .frame(width: size, height: size)
        .background(Color.backgroundLight)
    }

    public func pdfPreview(fileName: String) -> some View {
        ZStack(alignment: .bottom) {
            Image.pdfLine
                .resizable()
                .foregroundColor(.textDark)
                .opacity(0.8)
                .padding(30)
            Text(fileName)
                .lineLimit(1)
                .padding(.horizontal, 10)
                .padding(.bottom, 10)
                .font(.regular16)
                .foregroundColor(.textDarkest)
        }
        .frame(width: size, height: size)
    }

    private var image: UIImage? {
        guard let imageData = try? Data(contentsOf: url), let uiImage = UIImage(data: imageData) else {
            return nil
        }

        return uiImage
    }

    private var movieData: (frame: UIImage, movieLength: Double)? {
        guard url.pathExtension.lowercased() == "mov" else { return nil }

        let asset = AVURLAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true

        guard let cgImage = try? imageGenerator.copyCGImage(at: .zero, actualTime: nil) else { return nil }

        return (frame: UIImage(cgImage: cgImage), movieLength: asset.duration.seconds)
    }
}

#if DEBUG

struct AttachmentPreviewView_Previews: PreviewProvider {
    static var previews: some View {
        let view = AttachmentPreviewView(url: URL(string: "https://instructure.com")!)
        let image = UIImage(named: "PandaAtLaptop", in: .core, compatibleWith: nil)!
        view.imagePreview(image).previewLayout(.sizeThatFits)
        view.moviePreview(image, movieLength: 186).previewLayout(.sizeThatFits)
        view.noPreview.previewLayout(.sizeThatFits)
        view.noPreview
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
        view.pdfPreview(fileName: "verylongfilenamejusttoseeifitfits.pdf").previewLayout(.sizeThatFits)
        view.pdfPreview(fileName: "test.pdf")
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
    }
}

#endif
