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

struct ListCellView: View {

    enum ListCellStyle {
        case mainAccordionHeader
        case listAccordionHeader
        case listItem
    }

    let cellStyle: ListCellStyle
    let title: String
    let subtitle: String?
    @State var isSelected: Bool = false
    @State var isOpen: Bool = false

    var backgroundColor: Color {
        switch cellStyle {
        case .mainAccordionHeader:
            return .backgroundLight
        default:
            return .backgroundLightest
        }
    }
    @ViewBuilder
    var iconImage: some View {
        HStack {
            if isSelected {
                Image("completeSolid", bundle: .core).foregroundColor(.textInfo)
            } else {
                Image("emptyLine", bundle: .core).foregroundColor(.textDarkest)
            }
        }.frame(width: 32, height: 32)
            .padding(.leading, 24)
            .padding(.trailing, 20)
    }

    @ViewBuilder
    var accessoryIcon: some View {
        HStack {
            switch cellStyle {
            case .mainAccordionHeader, .listAccordionHeader:
                Image("arrowOpenRightLine", bundle: .core)
                    .rotationEffect(isOpen ? .degrees(90) : .degrees(0))
            case .listItem:
                Image("")
            }
        }
        .padding(16)
    }

    var titleFont: Font {
        switch cellStyle {
        case .mainAccordionHeader:
            return .semibold18
        case .listAccordionHeader, .listItem:
            return .semibold16
        }
    }

    var subtitleFont: Font {
        switch cellStyle {
        default:
            return .regular14
        }
    }

    var body: some View {
        Button {
            withAnimation {
                if cellStyle == .listItem {
                    isSelected.toggle()
                    return
                }
                isOpen.toggle()
            }
        } label: {
            ZStack {
                backgroundColor
                HStack(spacing: 0) {
                    iconImage
                        .onTapGesture {
                            withAnimation {
                                isSelected.toggle()
                            }
                        }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.leading)
                            .foregroundColor(.textDarkest)
                            .font(titleFont)
                            .padding(.top, 12)
                            .padding(.bottom, subtitle == nil ? 14 : 0)
                        if let subtitle = subtitle {
                            Text(subtitle)
                                .lineLimit(1)
                                .foregroundColor(.textDark)
                                .font(subtitleFont)
                                .padding(.bottom, 14)
                        }
                    }
                    Spacer()
                    accessoryIcon
                }
            }
            .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct ListCellView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
            ListCellView(cellStyle: .mainAccordionHeader, title: "Top Secret.pdf", subtitle: "1MB")
            Divider()
            ListCellView(cellStyle: .listAccordionHeader, title: "Submission.mp3", subtitle: "4GB")
            Divider()
            ListCellView(cellStyle: .listItem, title: "Creative Machines and Innovative Instrumentation.mov", subtitle: "4 GB")
            Divider()
            ListCellView(cellStyle: .listItem, title: "Something", subtitle: nil)
            Divider()
        }
        Spacer()
    }
}
