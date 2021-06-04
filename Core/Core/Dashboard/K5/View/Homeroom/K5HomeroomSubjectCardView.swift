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

import SwiftUI

public struct K5HomeroomSubjectCardView: View {
    public static let Height: CGFloat = 195

    @Environment(\.appEnvironment) private var env
    @Environment(\.viewController) private var controller

    private let viewModel: K5HomeroomSubjectCardViewModel
    private let cardSize: CGSize
    private let imageSize: CGSize

    public init(viewModel: K5HomeroomSubjectCardViewModel, width: CGFloat) {
        self.viewModel = viewModel
        self.cardSize = CGSize(width: width, height: Self.Height)
        self.imageSize = CGSize(width: width, height: 82)
    }

    public var body: some View {
        Button(action: {
            env.router.route(to: "/courses/\(viewModel.courseId)", from: controller)
        }, label: {
            VStack(alignment: .leading, spacing: 0) {
                image
                viewModel.color.frame(width: imageSize.width, height: 2)
                Text(viewModel.name)
                    .font(.regular16)
                    .foregroundColor(viewModel.color)
                    .lineLimit(2).fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 10).padding(.top, 8)
                viewModel.color
                    .frame(height: 2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                Spacer()
            }
                .background(RoundedRectangle(cornerRadius: 4).stroke(Color(white: 0.89), lineWidth: 1 / UIScreen.main.scale))
                .background(Color.white)
                .cornerRadius(4)
                .shadow(color: Color.black.opacity(0.2), radius: 1, x: 0, y: 1)
        })
        .buttonStyle(ScaleButtonStyle(scale: 1))
        .frame(width: cardSize.width, height: cardSize.height)
        .frame(minHeight: cardSize.height)
        .identifier("DashboardCourseCell.\(viewModel.courseId)")
    }

    private var image: some View {
        ZStack {
            viewModel.color.frame(width: imageSize.width, height: imageSize.height)
            viewModel.imageURL.map { RemoteImage($0, width: imageSize.width, height: imageSize.height) }?
                .opacity(0.4)
                .clipped()
                // Fix big course image consuming tap events.
                .contentShape(Path(CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height)))
        }
            .frame(width: imageSize.width, height: imageSize.height)
    }
}

struct K5HomeroomSubjectCardView_Previews: PreviewProvider {
    static var previews: some View {
        let model = K5HomeroomSubjectCardViewModel(courseId: "1", imageURL: URL(string: "https://inst.prod.acquia-sites.com/sites/default/files/image/2021-01/Instructure%20Office.jpg")!, name: "SOCIAL STUDIES", color: .oxford, infoLines: [])
        K5HomeroomSubjectCardView(viewModel: model, width: 193).previewLayout(.sizeThatFits)
        K5HomeroomSubjectCardView(viewModel: model, width: 400).previewLayout(.sizeThatFits)

    }
}
