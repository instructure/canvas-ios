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

struct DownloadCourseCellView: View {

    // MARK: - Properties -

    let courseViewModel: DownloadCourseViewModel

    // MARK: - Views -

    var body: some View {
        if UIDevice.current.userInterfaceIdiom == .pad {
            padBody
        } else {
            phoneBody
        }
    }

    private var padBody: some View {
        VStack(alignment: .leading) {
            contentPad
        }
        .contentShape(Rectangle())
        .background(
            RoundedRectangle(cornerRadius: 4)
                .stroke(
                    Color.gray,
                    lineWidth: 1 / UIScreen.main.scale
                )
        )
        .background(Color.backgroundLightest)
        .cornerRadius(4)
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
        .buttonStyle(PlainButtonStyle())
    }

    private var phoneBody: some View {
        VStack(alignment: .leading) {
            contentPhone
        }
        .contentShape(Rectangle())
        .background(
            RoundedRectangle(cornerRadius: 4)
                .stroke(
                    Color.gray,
                    lineWidth: 1 / UIScreen.main.scale
                )
        )
        .background(Color.backgroundLightest)
        .cornerRadius(4)
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
        .buttonStyle(PlainButtonStyle())
    }

    private var contentPad: some View {
        HStack(alignment: .top, spacing: 3) {
            ZStack {
                Color(courseViewModel.color).frame(width: 177, height: 100)
                padImage
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(courseViewModel.name)
                    .font(.semibold18)
                    .foregroundColor(Color(courseViewModel.textColor))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                Text(courseViewModel.courseCode)
                    .font(.semibold12)
                    .foregroundColor(.textDark)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            .padding(.all, 10)
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    private var contentPhone: some View {
        VStack(alignment: .leading, spacing: 3) {
            ZStack {
                Color(courseViewModel.color).frame(height: 80)
                phoneImage
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(courseViewModel.name)
                    .font(.semibold18)
                    .foregroundColor(Color(courseViewModel.textColor))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                Text(courseViewModel.courseCode)
                    .font(.semibold12)
                    .foregroundColor(.textDark)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            .padding(.all, 10)
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var phoneImage: some View {
        if let imageDownloadURL = courseViewModel.course?.imageDownloadURL,
           let image = ImageDownloader().loadImage(fileName: imageDownloadURL.lastPathComponent) {
            GeometryReader { reader  in
                Image(uiImage: image.withRenderingMode(.alwaysOriginal))
                    .resizable().scaledToFill()
                    .frame(width: reader.size.width, height: 80)
                    .opacity(0.4)
                    .clipped()
            }
        } else {
            courseViewModel.course?.imageDownloadURL.map { url in
                GeometryReader { reader in
                    RemoteImage(url, width: reader.size.width, height: 80)
                }
            }?
            .opacity(0.4)
            .clipped()
        }
    }

    @ViewBuilder
    private var padImage: some View {
        if let imageDownloadURL = courseViewModel.course?.imageDownloadURL,
           let image = ImageDownloader().loadImage(fileName: imageDownloadURL.lastPathComponent) {
            Image(uiImage: image.withRenderingMode(.alwaysOriginal))
                .resizable().scaledToFill()
                .frame(width: 177, height: 100)
                .opacity(0.4)
                .clipped()
        } else {
            courseViewModel.course?.imageDownloadURL.map { url in
                RemoteImage(url, width: 177, height: 100)
            }?
            .opacity(0.4)
            .clipped()
        }
    }
}
