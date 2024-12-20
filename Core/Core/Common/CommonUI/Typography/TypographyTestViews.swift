//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

#if DEBUG

import SwiftUI

struct BodyStyleTestView: View {
    // swiftlint:disable:next line_length
    let text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam tincidunt rhoncus rutrum. Donec tempus vulputate posuere.\u{2028}Aenean blandit nunc vitae tempus sodales. In vehicula venenatis tempus. In pharetra aliquet neque, non viverra massa sodales eget. Etiam hendrerit tincidunt placerat. Suspendisse et lacus a metus tempor gravida.\nNam vulputate, tellus ut blandit tempus, ex mauris sollicitudin tortor, vel luctus tortor libero a diam."

    var body: some View {
        VStack(alignment: .leading) {
            Text(verbatim: "Body Style")
                .font(.bold20)
                .padding(.bottom, 5)
            Text(text)
                .style(.body)
        }
        .padding()
    }
}

struct LineHeightTestView: View {
    let fontName = UIFont.Name.regular16
    let uiFont: UIFont
    let suiFont: Font

    init() {
        self.uiFont = UIFont.scaledNamedFont(fontName)
        self.suiFont = Font(uiFont)
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(verbatim: "Line Height")
                .font(.bold20)
                .padding(.bottom, 5)
            HStack(alignment: .top) {
                ForEach(Typography.LineHeight.allCases) { lineHeight in
                    VStack(alignment: .leading, spacing: 0) {
                        Text(lineHeight.name)
                            .font(.bold15)
                            .padding(.bottom, 5)
                        Text(InstUI.PreviewData.loremIpsumLong)
                            .font(.regular16, lineHeight: lineHeight)
                            .border(Color.black, width: 1)
                    }
                }
            }
        }
        .padding()
        .font(suiFont)
    }
}

struct TypographyTestViews: PreviewProvider {
    static var previews: some View {
        LineHeightTestView().previewLayout(.fixed(width: 900, height: 500))
        BodyStyleTestView().previewLayout(.fixed(width: 300, height: 400))
    }
}

#endif
