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

    var item: CourseSyncSelectorViewModel.Item

    private var backgroundColor: Color {
        switch item.cellStyle {
        case .mainAccordionHeader:
            return .backgroundLight
        default:
            return .backgroundLightest
        }
    }

    private var cellHeight: CGFloat {
        switch item.cellStyle {
        case .mainAccordionHeader:
            return 72.0
        default:
            return 54.0
        }
    }

    @ViewBuilder
    private var iconImage: some View {
        HStack {
            if item.isSelected {
                Image("completeSolid", bundle: .core)
                    .size(20)
                    .foregroundColor(.textInfo)
            } else {
                Image("emptyLine", bundle: .core)
                    .size(20)
                    .foregroundColor(.textDarkest)
            }
        }.frame(width: 32, height: 32)
            .padding(.leading, 24)
            .padding(.trailing, 20)
    }

    @ViewBuilder
    private var accessoryIcon: some View {
        HStack {
            switch item.cellStyle {
            case .mainAccordionHeader, .listAccordionHeader:
                if let isCollapsed = item.isCollapsed {
                    Image("arrowOpenDownLine", bundle: .core)
                        .size(16)
                        .foregroundColor(.textDarkest)
                        .rotationEffect(isCollapsed ? .degrees(-180) : .degrees(0))
                } else {
                    SwiftUI.EmptyView()
                }
            case .listItem:
                SwiftUI.EmptyView()
            }
        }
        .padding(16)
    }

    private var titleFont: Font {
        switch item.cellStyle {
        default:
            return .semibold16
        }
    }

    @ViewBuilder
    private var titleText: some View {
        Text(item.title)
            .lineLimit(2)
            .fixedSize(horizontal: false, vertical: true)
            .multilineTextAlignment(.leading)
            .foregroundColor(.textDarkest)
            .font(titleFont)
            .padding(.top, 12)
            .padding(.bottom, item.subtitle == nil ? 16 : 0)
    }

    private var subtitleFont: Font {
        switch item.cellStyle {
        default:
            return .regular14
        }
    }

    @ViewBuilder
    private var subTitleText: some View {
        Text(item.subtitle ?? "")
            .lineLimit(1)
            .foregroundColor(.textDark)
            .font(subtitleFont)
            .padding(.bottom, 14)
    }

    var body: some View {
        Button {
            withAnimation {
                if item.cellStyle == .listItem || item.isCollapsed == nil {
                    item.selectionDidToggle?()
                    return
                }
                item.collapseDidToggle?()
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
                                item.selectionDidToggle?()
                            }
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        titleText
                        if item.subtitle != nil {
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
