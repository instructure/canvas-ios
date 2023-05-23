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
    let error: String?
    let selectionState: SelectionState
    let isCollapsed: Bool?
    let selectionDidToggle: (() -> Void)?
    let collapseDidToggle: (() -> Void)?
    let removeItemPressed: (() -> Void)?

    let progress: Float?

    internal init(cellStyle: ListCellView.ListCellStyle,
                  title: String,
                  subtitle: String? = nil,
                  selectionState: ListCellView.SelectionState = .deselected,
                  isCollapsed: Bool? = nil,
                  selectionDidToggle: (() -> Void)? = nil,
                  collapseDidToggle: (() -> Void)? = nil,
                  removeItemPressed: (() -> Void)? = nil,
                  progress: Float? = nil,
                  error: String? = nil) {
        self.cellStyle = cellStyle
        self.title = title
        self.subtitle = subtitle
        self.selectionState = selectionState
        self.isCollapsed = isCollapsed
        self.selectionDidToggle = selectionDidToggle
        self.collapseDidToggle = collapseDidToggle
        self.removeItemPressed = removeItemPressed
        self.progress = progress
        self.error = error
    }

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
        if selectionDidToggle != nil {
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
                .padding(.trailing, 4)
        }
    }

    @ViewBuilder
    private var accessoryIcon: some View {
        HStack(spacing: 0) {
            switch cellStyle {
            case .mainAccordionHeader, .listAccordionHeader:
                if let isCollapsed = isCollapsed {
                    Image.arrowOpenDownLine
                        .size(24)
                        .foregroundColor(.textDarkest)
                        .rotationEffect(isCollapsed ? .degrees(0) : .degrees(-180))
                }
            case .listItem:
                SwiftUI.EmptyView()
            }
            if error != nil {
                Button {
                    removeItemPressed?()
                } label: {
                    Image.xLine
                        .size(24)
                        .foregroundColor(.textDarkest)
                        .accessibilityHidden(true)
                        .padding(.leading, 30)
                }

            } else if let progress = progress {
                if progress < 1 {
                    ProgressView(value: progress)
                        .progressViewStyle(.determinateCircle(size: 20,
                                                              lineWidth: 2,
                                                              color: .backgroundInfo))
                        .accessibilityHidden(true)
                        .padding(.leading, 30)
                } else {
                    Image.checkLine
                        .size(24)
                        .foregroundColor(.textDarkest)
                        .accessibilityHidden(true)
                        .padding(.leading, 30)
                }
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
            .padding(.bottom, error != nil ? 2 : 14)
    }

    @ViewBuilder
    private var errorText: some View {
        Text(error ?? "")
            .lineLimit(1)
            .foregroundColor(.textDanger)
            .font(.regular14)
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
                    Button {
                        withAnimation {
                            selectionDidToggle?()
                        }
                    } label: {
                        iconImage.accessibilityHidden(true)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        titleText
                        if subtitle != nil {
                            subTitleText
                        }
                        if error != nil {
                            errorText
                        }
                    }.padding(.leading, 16)
                    Spacer()
                    accessoryIcon.accessibilityHidden(true)
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            .frame(minHeight: cellHeight)
        }
        .accessibilityElement(children: .combine)
        .accessibilityAction(named: accessibilitySelectionText) {
            selectionDidToggle?()
        }
        .if(isCollapsed != nil) { view in
            view.accessibilityAction(named: accessibilityAccordionHeaderText) {
                collapseDidToggle?()
            }
        }
        .if(error != nil) { view in
            view.accessibilityAction(named: Text("Remove item", bundle: .core)) {
                removeItemPressed?()
            }
        }
        .accessibility(label: accessibilityText)
    }

    private var accessibilitySelectionText: Text {
        switch selectionState {
        case .deselected:
            return Text("Select item", bundle: .core)
        case .selected, .partiallySelected:
            return Text("Deselect item", bundle: .core)
        }
    }

    private var accessibilityAccordionHeaderText: Text {
        if isCollapsed == true {
            return Text("Open section", bundle: .core)
        }
        return Text("Close section", bundle: .core)
    }

    private var accessibilityText: Text {
        var titleText = Text(title + (subtitle ?? "") + ",")
        if let error = error {
            titleText.append(error + ",")
        }
        var selectionText: Text = Text("")
        if selectionDidToggle != nil {
            switch selectionState {
            case .deselected:
                selectionText = Text("Deselected,", bundle: .core)
            case .selected:
                selectionText = Text("Selected,", bundle: .core)
            case .partiallySelected:
                selectionText = Text("Partially selected,", bundle: .core)
            }
        }
        var collapseText: Text
        switch isCollapsed {
        case true:
            collapseText = Text("Closed section,", bundle: .core)
        case false:
            collapseText = Text("Open section,", bundle: .core)
        default:
            collapseText = Text("")
        }
        var progressText: Text
        if let progress = progress, error == nil {
            if progress == 1 {
                progressText = Text("Download complete,", bundle: .core)
            } else {
                progressText = Text("Downloading,", bundle: .core)
            }
        } else {
            progressText = Text("")
        }

        return titleText + selectionText + collapseText + progressText
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
                         selectionDidToggle: {})
            Divider()
            ListCellView(cellStyle: .listAccordionHeader,
                         title: "Something",
                         subtitle: nil,
                         selectionState: .deselected,
                         selectionDidToggle: {})
            Divider()
            ListCellView(cellStyle: .listAccordionHeader,
                         title: "Files",
                         subtitle: nil,
                         selectionState: .deselected,
                         isCollapsed: false,
                         selectionDidToggle: {})
            Divider()
            ListCellView(cellStyle: .listItem,
                         title: "Creative Machines and InnovativeInstrument ation.mov",
                         subtitle: "4 GB",
                         selectionState: .selected,
                         isCollapsed: false,
                         selectionDidToggle: {})
            Divider()
            Spacer()
        }
        VStack(spacing: 0) {
            Divider()
            ListCellView(cellStyle: .mainAccordionHeader,
                         title: "Top Secret.pdf",
                         subtitle: "1MB",
                         isCollapsed: false,
                         progress: 0.15)
            Divider()
            ListCellView(cellStyle: .listAccordionHeader,
                         title: "Files",
                         subtitle: "1.13 GB",
                         isCollapsed: false,
                         progress: 0.5)
            Divider()
            ListCellView(cellStyle: .listItem,
                         title: "Creative Machines and Innovative Instrumentation.mov",
                         subtitle: "4 GB",
                         isCollapsed: false,
                         progress: 1,
                         error: "Sync Failed")
            Divider()
            Spacer()
        }

    }
}

#endif
