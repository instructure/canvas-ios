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
    public static let Height: CGFloat = 275

    @Environment(\.appEnvironment) private var env
    @Environment(\.viewController) private var controller

    private let viewModel: K5HomeroomSubjectCardViewModel
    private let cardSize: CGSize
    private let imageSize: CGSize

    public init(viewModel: K5HomeroomSubjectCardViewModel, width: CGFloat) {
        self.viewModel = viewModel
        self.cardSize = CGSize(width: width, height: Self.Height)
        self.imageSize = CGSize(width: width, height: 150)
    }

    public var body: some View {
        Button(action: {
            env.router.route(to: viewModel.courseRoute, from: controller)
        }, label: {
            VStack(alignment: .leading, spacing: 0) {
                image
                viewModel.color.frame(width: imageSize.width, height: 2)
                Text(viewModel.name)
                    .font(.bold15)
                    .foregroundColor(viewModel.color)
                    .lineLimit(1).fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 8).padding(.top, 8)
                viewModel.color
                    .frame(height: 2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                infoLines
                Spacer()
            }
            .background(RoundedRectangle(cornerRadius: 4).stroke(Color.borderMedium, lineWidth: 1 / UIScreen.main.scale))
            .cornerRadius(4)
        })
        .buttonStyle(PlainButtonStyle())
        .frame(width: cardSize.width, height: cardSize.height)
        .frame(minHeight: cardSize.height)
        .identifier(viewModel.a11yId)
    }

    private var image: some View {
        ZStack {
            viewModel.color.frame(width: imageSize.width, height: imageSize.height)
            viewModel.imageURL.map { RemoteImage($0, width: imageSize.width, height: imageSize.height) }?
                .clipped()
                // Fix big course image consuming tap events.
                .contentShape(Path(CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height)))
        }
        .frame(width: imageSize.width, height: imageSize.height)
    }

    private var infoLines: some View {
        VStack(alignment: .leading, spacing: 5) {
            let infoLines = viewModel.infoLines
            ForEach(0..<infoLines.count, id: \.self) { index in
                infoLine(from: infoLines[index])

                if index != infoLines.count - 1 {
                    Divider()
                }
            }
        }
        .foregroundColor(.textDarkest)
        .padding(.horizontal, 8)
        .environment(\.font, Font.regular13)
        .environment(\.lineLimit, 2)
    }

    private func infoLine(from model: K5HomeroomSubjectCardViewModel.InfoLine) -> some View {
        Button(action: {
            env.router.route(to: model.route, from: controller)
        }, label: {
            HStack(alignment: .top, spacing: 5) {
                model.icon
                    .resizable()
                    .foregroundColor(viewModel.color)
                    .scaledToFill()
                    .frame(width: 18, height: 18)
                (Text(model.text)
                +
                Text(model.highlightedText)
                    .foregroundColor(Color(DocViewerAnnotationColor.red.color)))
                .padding(.top, 1)
            }
        })
    }
}

#if DEBUG

struct K5HomeroomSubjectCardView_Previews: PreviewProvider {
    private static let env = PreviewEnvironment()
    private static let context = env.globalDatabase.viewContext

    static var previews: some View {
        let announcement = LatestAnnouncement.save(.make(title: "I will be out on Thursday. Mrs. Robinson will be substituting. Make sure to read the rest of the announcement as well!"), in: context)
        let imageURL = URL(string: "https://inst.prod.acquia-sites.com/sites/default/files/image/2021-01/Instructure%20Office.jpg")!
        let longCourseName = "long course title to test what happens if there's not enough space for it"
        let models = [
            K5HomeroomSubjectCardViewModel(courseId: "1", imageURL: imageURL, name: "SOCIAL STUDIES", color: .textInfo, infoLines: [
                .make(dueToday: 0, missing: 0, courseId: "")
            ]),
            K5HomeroomSubjectCardViewModel(courseId: "1", imageURL: imageURL, name: longCourseName, color: .textInfo, infoLines: [
                .make(dueToday: 3, missing: 1, courseId: ""),
                .make(from: announcement, courseId: "")!
            ])
        ]

        ForEach(0..<2) { index in
            K5HomeroomSubjectCardView(viewModel: models[index], width: 193).previewLayout(.sizeThatFits)
            K5HomeroomSubjectCardView(viewModel: models[index], width: 400).previewLayout(.sizeThatFits)
        }
    }
}

#endif
