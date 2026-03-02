//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

import SwiftUI
import SDWebImage
import SDWebImageSwiftUI

public struct ImageLoaderView: View {
    private let url: URL?
    private let options: SDWebImageOptions
    private let placeholder: (() -> AnyView)?
    private let maxImageSize: CGSize?
    private let context: [SDWebImageContextOption: Any]?

    public init<P: View>(
        url: URL?,
        options: SDWebImageOptions = [.scaleDownLargeImages, .retryFailed, .queryMemoryData],
        maxImageSize: CGSize? = CGSize(width: 800, height: 800),
        @ViewBuilder placeholder: @escaping () -> P
    ) {
        self.url = url
        self.options = options
        self.maxImageSize = maxImageSize
        self.placeholder = { AnyView(placeholder()) }

        if let maxSize = maxImageSize {
            self.context = [
                .imageThumbnailPixelSize: maxSize,
                .imageScaleFactor: UIScreen.main.scale
            ]
        } else {
            self.context = nil
        }
    }

    public init(
        url: URL?,
        options: SDWebImageOptions = [.scaleDownLargeImages, .retryFailed, .queryMemoryData],
        maxImageSize: CGSize? = CGSize(width: 800, height: 800)
    ) {
        self.url = url
        self.options = options
        self.maxImageSize = maxImageSize
        self.placeholder = nil

        if let maxSize = maxImageSize {
            self.context = [
                .imageThumbnailPixelSize: maxSize,
                .imageScaleFactor: UIScreen.main.scale
            ]
        } else {
            self.context = nil
        }
    }

    public var body: some View {
        if let placeholder = placeholder {
            WebImage(
                url: url,
                options: options,
                context: context,
                content: { image in
                    image.resizable()
                },
                placeholder: placeholder
            )
            .indicator(.activity)
        } else {
            WebImage(url: url, options: options, context: context)
                .resizable()
                .indicator(.activity)
        }
    }
}
