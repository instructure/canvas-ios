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

    public init(viewModel: AttachmentPreviewViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        switch viewModel.state {
        case .loading: loadingView
        case .noPreview: noPreview
        case .media(let image, let length): mediaPreview(image, length: length)
        }
    }

    fileprivate var loadingView: some View {
        ProgressView()
            .progressViewStyle(.indeterminateCircle())
            .background(Color.backgroundLightest)
            .frame(width: size, height: size)
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
                    .background(Color.backgroundDarkest.opacity(0.5))
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
            Text("No preview available", bundle: .core)
                .font(.regular17)
                .foregroundColor(.textDarkest)
        }
        .frame(width: size, height: size)
        .background(Color.backgroundLight)
    }
}

#if DEBUG

struct AttachmentPreviewView_Previews: PreviewProvider {
    static var previews: some View {
        let view = AttachmentPreviewView(viewModel: AttachmentPreviewViewModel(previewProvider: FilePreviewProvider(url: URL(string: "https://instructure.com")!)))
        let image = UIImage(named: "PandaAtLaptop", in: .core, compatibleWith: nil)!
        view.loadingView
            .previewLayout(.sizeThatFits)
        view.loadingView
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
        view.mediaPreview(image, length: "3:06")
            .previewLayout(.sizeThatFits)
        view.mediaPreview(image, length: "3:06")
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
        view.mediaPreview(image, length: nil).previewLayout(.sizeThatFits)
        view.noPreview.previewLayout(.sizeThatFits)
        view.noPreview
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
    }
}

#endif
