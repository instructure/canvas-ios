//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

struct DownloadsCourseDetailsHeaderView: View {

    // MARK: - Properties -

    @ObservedObject private var viewModel: DownloadsCourseDetailsHeaderViewModel
    private let width: CGFloat

    public init(viewModel: DownloadsCourseDetailsHeaderViewModel, width: CGFloat) {
        self.viewModel = viewModel
        self.width = width
    }

    // MARK: - Views -

    public var body: some View {
        ZStack {
            Color(viewModel.courseColor.darkenToEnsureContrast(against: .white))
                .frame(width: width, height: viewModel.height)
            image
            VStack(spacing: 3) {
                Text(viewModel.courseName)
                    .font(.semibold23)
                    .accessibility(identifier: "course-details.title-lbl")
                Text(viewModel.termName)
                    .font(.semibold14)
                    .accessibility(identifier: "course-details.subtitle-lbl")
            }
            .padding()
            .multilineTextAlignment(.center)
            .foregroundColor(.textLightest)
            .opacity(viewModel.titleOpacity)
        }
        .frame(height: viewModel.height)
        .clipped()
        .offset(x: 0, y: viewModel.verticalOffset)
    }

    @ViewBuilder
    private var image: some View {
        if let imageDownloadURL = viewModel.imageURL,
           let image = ImageDownloader().loadImage(fileName: imageDownloadURL.lastPathComponent) {
            Image(uiImage: image.withRenderingMode(.alwaysOriginal))
                .resizable().scaledToFill()
                .frame(width: width, height: viewModel.height)
                .opacity(viewModel.imageOpacity)
                .clipped()
        } else {
            if let url = viewModel.imageURL {
                RemoteImage(url, width: width, height: viewModel.height)
                    .opacity(viewModel.imageOpacity)
            }
        }
    }
}
