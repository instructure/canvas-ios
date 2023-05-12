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

    enum SelectionState {
        case deselected
        case selected
        case partiallySelected
    }

    let cellStyle: ListCellStyle
    let title: String
    let subtitle: String?
    let selectionState: SelectionState
    let isCollapsed: Bool?
    let selectionDidToggle: (() -> Void)?
    let collapseDidToggle: (() -> Void)?

    private var backgroundColor: Color {
        switch cellStyle {
        case .mainAccordionHeader:
            return .backgroundLight
        default:
            return .backgroundLightest
        }
    }

    private var cellHeight: CGFloat {
        switch cellStyle {
        case .mainAccordionHeader:
            return 72.0
        default:
            return 54.0
        }
    }

    @ViewBuilder
    private var iconImage: some View {
        HStack {
            switch selectionState {
            case .deselected:
                Image.emptyLine
                    .size(20)
                    .foregroundColor(.textDarkest)
            case .selected:
                Image.completeSolid
                    .size(20)
                    .foregroundColor(.textInfo)
            case .partiallySelected:
                Image.partialSolid
                    .size(20)
                    .foregroundColor(.textInfo)
            }
        }.frame(width: 32, height: 32)
            .padding(.leading, 24)
            .padding(.trailing, 20)
    }

    @ViewBuilder
    private var accessoryIcon: some View {
        HStack {
            switch cellStyle {
            case .mainAccordionHeader, .listAccordionHeader:
                if let isCollapsed = isCollapsed {
                    Image.arrowOpenDownLine
                        .size(16)
                        .foregroundColor(.textDarkest)
                        .rotationEffect(isCollapsed ? .degrees(0) : .degrees(-180))
                }
            case .listItem:
                SwiftUI.EmptyView()
            }
        }
        .padding(16)
    }

    private var titleFont: Font {
        switch cellStyle {
        default:
            return .semibold16
        }
    }

    @ViewBuilder
    private var titleText: some View {
        Text(title)
            .lineLimit(2)
            .fixedSize(horizontal: false, vertical: true)
            .multilineTextAlignment(.leading)
            .foregroundColor(.textDarkest)
            .font(titleFont)
            .padding(.top, 12)
            .padding(.bottom, subtitle == nil ? 16 : 0)
    }

    private var subtitleFont: Font {
        switch cellStyle {
        default:
            return .regular14
        }
    }

    @ViewBuilder
    private var subTitleText: some View {
        Text(subtitle ?? "")
            .lineLimit(1)
            .foregroundColor(.textDark)
            .font(subtitleFont)
            .padding(.bottom, 14)
    }

    var body: some View {
        Button {
            withAnimation {
                if cellStyle == .listItem || isCollapsed == nil {
                    selectionDidToggle?()
                    return
                }
                collapseDidToggle?()
            }
        } label: {
            ZStack {
                backgroundColor
                    .fixedSize(horizontal: false, vertical: false)
                    .frame(minHeight: cellHeight)
                HStack(spacing: 0) {
                    iconImage
                        .onTapGesture {
                            withAnimation {
                                selectionDidToggle?()
                            }
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        titleText
                        if subtitle != nil {
                            subTitleText
                        }
                    }
                    Spacer()
                    accessoryIcon
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            .frame(minHeight: cellHeight)
        }
    }
}

#if DEBUG

struct ListCellView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
            ListCellView(cellStyle: .mainAccordionHeader,
                         title: "Top Secret.pdf",
                         subtitle: "1MB",
                         selectionState: .selected,
                         isCollapsed: false,
                         selectionDidToggle: nil,
                         collapseDidToggle: nil)
            Divider()
            ListCellView(cellStyle: .listAccordionHeader,
                         title: "Something",
                         subtitle: nil,
                         selectionState: .deselected,
                         isCollapsed: nil,
                         selectionDidToggle: nil,
                         collapseDidToggle: nil)
            Divider()
            ListCellView(cellStyle: .listAccordionHeader,
                         title: "Files",
                         subtitle: nil,
                         selectionState: .deselected,
                         isCollapsed: false,
                         selectionDidToggle: nil,
                         collapseDidToggle: nil)
            Divider()
            ListCellView(cellStyle: .listItem,
                         title: "Creative Machines and Innovative Instrumentation.mov",
                         subtitle: "4 GB",
                         selectionState: .selected,
                         isCollapsed: false,
                         selectionDidToggle: nil,
                         collapseDidToggle: nil)
            Divider()
        }
        Spacer()
    }
}

#endif
