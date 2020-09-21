//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

import Combine
import SwiftUI

@available(iOS 13, *)
public struct SwiftUIAvatarView: View {
    let label: String
    @State var image: Image?
    var cancellables = Set<AnyCancellable>()

    init(imageUrl: URL?, name: String) {
        label = name.split(separator: " ", maxSplits: 1).reduce("") { (value: String, part: Substring) -> String in
            guard let char = part.first else { return value }
            return "\(value)\(char)"
        }.localizedUppercase

        if let url = Self.scrubbedURL(imageUrl) {
            cancellables.insert(
                ImageLoader.Publisher(url: url)
                    .map { $0.map(Image.init(uiImage:)) }
                    .catch { _ in Just(nil) }
                    .assign(to: \.image, on: self)
            )
        }
    }

    public var body: some View {
        GeometryReader { geom in
            SwiftUI.Group {
                if image != nil {
                    image!
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .background(Color.backgroundLight)
                } else {
                    Circle()
                        .strokeBorder(lineWidth: 1 / UIScreen.main.scale)
                        .foregroundColor(.borderMedium)
                        .overlay(
                            Text(label)
                                .allowsTightening(true)
                                .lineLimit(1)
                                .foregroundColor(.textDark)
                                .font(.system(size: round(geom.frame(in: .local).width / 2.25), weight: .semibold))
                        )
                }
            }
        }.accessibility(hidden: true)
        .clipShape(Circle())
    }

    static func scrubbedURL(_ url: URL?) -> URL? {
        // Ignore crappy default avatars.
        if url?.absoluteString.contains("images/dotted_pic.png") == true || url?.absoluteString.contains("images/messages/avatar-50.png") == true {
            return nil
        }
        return url
    }

    struct Group: View {
        var body: some View {
            Circle()
                .strokeBorder(lineWidth: 1 / UIScreen.main.scale)
                .foregroundColor(.borderMedium)
                .overlay(Icon.groupLine.foregroundColor(.borderDark))
        }
    }
}

#if DEBUG
@available(iOS 13, *)
struct AvatarView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            SwiftUIAvatarView(imageUrl: nil, name: "Test User")
                .previewLayout(.fixed(width: 40, height: 40))
            SwiftUIAvatarView.Group()
                .previewLayout(.fixed(width: 40, height: 40))
            ZStack {
                Rectangle().frame(width: 24, height: 24).foregroundColor(.red)
                Icon.groupLine
            }.previewLayout(.fixed(width: 50, height: 50))
            Image(uiImage: UIImage.groupLine)
            Text(verbatim: "\(UIImage.groupLine.size)")
        }.previewLayout(.sizeThatFits)
    }
}
#endif
