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

struct K5SubjectHeaderView: View {

    let title: String?
    let imageUrl: URL?
    let backgroundColor: Color?

    var body: some View {
        ZStack(alignment: .bottom) {

            if let imageUrl = imageUrl {
                GeometryReader { geometry in
                    RemoteImage(imageUrl, width: geometry.size.width, height: 113)
                        .clipped()
                        .contentShape(Path(CGRect(x: 0, y: 0, width: geometry.size.width, height: geometry.size.height)))
                }
            }
            Rectangle().foregroundColor(backgroundColor).opacity(imageUrl == nil ? 1 : 0.75)
            Rectangle().fill(
                LinearGradient(gradient: Gradient(colors: [.black, .clear]), startPoint: .leading, endPoint: .trailing)
            ).frame(height: 38).opacity(0.60)
            if let title = title {
                HStack {
                    Text(title.uppercased()).foregroundColor(.textLightest).font(.regular17).padding(.leading, 16)
                    Spacer()
                }.padding(.bottom, 8)
            }
        }.frame(height: 113).cornerRadius(4)
    }
}

struct K5SubjectHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        let imageUrl = URL(string: "https://inst.prod.acquia-sites.com/sites/default/files/image/2021-01/Instructure%20Office.jpg")!
        K5SubjectHeaderView(title: "Math", imageUrl: imageUrl, backgroundColor: Color(hexString: "#FF8277"))
            .previewLayout(.sizeThatFits)
            .padding(16)
            .previewDisplayName(String(describing: K5SubjectHeaderView.self))
            .frame(width: 600)
    }
}
