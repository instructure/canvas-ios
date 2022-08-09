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
    @ObservedObject private var viewModel: AttachmentPreviewViewModel
    private let size: CGFloat = 200

    public init(url: URL) {
        viewModel = AttachmentPreviewViewModel(url: url)
    }

    public var body: some View {
        switch viewModel.state {
        case .loading: loadingView
        case .noPreview: noPreview
        case .media(let image, let length): mediaPreview(image, length: length)
        case .pdf(let fileName): pdfPreview(fileName: fileName)
        }
    }

    fileprivate var loadingView: some View {
        CircleProgress()
            .background(Color.backgroundLightest)
            .frame(width: size, height: size)
    }

    fileprivate func imagePreview(_ image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: size, height: size)
            .clipped()
    }

    fileprivate func mediaPreview(_ frame: UIImage, length: String?) -> some View {
        ZStack(alignment: .bottomTrailing) {
            Image(uiImage: frame)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .contentShape(Rectangle())
                .frame(width: size, height: size)
                .clipped()
            if let length = length {
                Text(length)
                    .font(.bold13)
                    .padding(4)
                    .background(Color.black.opacity(0.4))
                    .foregroundColor(.textLightest)
            }
        }
        .frame(width: size, height: size)
    }

    fileprivate var noPreview: some View {
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

    fileprivate func pdfPreview(fileName: String) -> some View {
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
        .background(Color.backgroundLightest)
        .frame(width: size, height: size)
    }
}

#if DEBUG

struct AttachmentPreviewView_Previews: PreviewProvider {
    static var previews: some View {
        let view = AttachmentPreviewView(url: URL(string: "https://instructure.com")!)
        let image = UIImage(named: "PandaAtLaptop", in: .core, compatibleWith: nil)!
        view.loadingView
            .previewLayout(.sizeThatFits)
        view.loadingView
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
        view.imagePreview(image).previewLayout(.sizeThatFits)
        view.mediaPreview(image, length: "3:06").previewLayout(.sizeThatFits)
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
