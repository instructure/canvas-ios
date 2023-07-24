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

    enum SelectionState: Equatable {
        case deselected
        case selected
        case partiallySelected
    }

    enum State {
        case idle
        case loading(Float?)
        case downloaded
        case error(String?)

        var isError: Bool {
            switch self {
            case .error: return true
            default: return false
            }
        }
    }

    @ObservedObject var viewModel: ListCellViewModel

    internal init(_ viewModel: ListCellViewModel) {
        self.viewModel = viewModel
    }

    @ViewBuilder
    private var iconImage: some View {
        if viewModel.selectionDidToggle != nil {
            HStack {
                switch viewModel.selectionState {
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
            switch viewModel.cellStyle {
            case .mainAccordionHeader, .listAccordionHeader:
                if let isCollapsed = viewModel.isCollapsed {
                    Image.arrowOpenDownLine
                        .size(24)
                        .foregroundColor(.textDarkest)
                        .rotationEffect(isCollapsed ? .degrees(0) : .degrees(-180))
                }
            case .listItem:
                SwiftUI.EmptyView()
            }
            progressAccessoryView
        }
        .padding(16)
    }

    @ViewBuilder
    private var progressAccessoryView: some View {
        switch viewModel.state {
        case .idle:
            SwiftUI.EmptyView()
        case let .loading(progress):
            if let progress {
                ProgressView(value: progress)
                    .progressViewStyle(
                        .determinateCircle(
                            size: 20,
                            lineWidth: 2,
                            color: .backgroundInfo
                        )
                    )
                    .accessibilityHidden(true)
                    .padding(2)
                    .padding(.leading, 30)

            } else {
                ProgressView(value: progress)
                    .progressViewStyle(
                        .indeterminateCircle(
                            size: 20,
                            lineWidth: 2,
                            color: .backgroundInfo
                        )
                    )
                    .accessibilityHidden(true)
                    .padding(2)
                    .padding(.leading, 30)
            }
        case .downloaded:
            Image.checkLine
                .size(24)
                .foregroundColor(.textDarkest)
                .accessibilityHidden(true)
                .padding(.leading, 30)
        case .error:
            Button {
                viewModel.removeItemPressed?()
            } label: {
                Image.xLine
                    .size(24)
                    .foregroundColor(.textDarkest)
                    .accessibilityHidden(true)
                    .padding(.leading, 30)
            }
        }
    }

    @ViewBuilder
    private var titleText: some View {
        Text(viewModel.title)
            .lineLimit(2)
            .fixedSize(horizontal: false, vertical: true)
            .multilineTextAlignment(.leading)
            .foregroundColor(.textDarkest)
            .font(viewModel.titleFont)
    }

    @ViewBuilder
    private var subTitleText: some View {
        Text(viewModel.subtitle ?? "")
            .lineLimit(1)
            .foregroundColor(.textDark)
            .font(viewModel.subtitleFont)
    }

    @ViewBuilder
    private var errorText: some View {
        if case .error(let error) = viewModel.state {
            Text(error ?? NSLocalizedString("Unknown Error", comment: ""))
                .lineLimit(1)
                .foregroundColor(.textDanger)
                .font(.regular14)
        }
    }

    var body: some View {
        Button {
            withAnimation {
                if viewModel.cellStyle == .listItem || viewModel.isCollapsed == nil {
                    viewModel.selectionDidToggle?()
                    return
                }
                viewModel.collapseDidToggle?()
            }
        } label: {
            ZStack {
                viewModel.backgroundColor
                    .fixedSize(horizontal: false, vertical: false)
                    .frame(minHeight: viewModel.cellHeight)
                HStack(spacing: 0) {
                    Button {
                        withAnimation {
                            viewModel.selectionDidToggle?()
                        }
                    } label: {
                        iconImage.accessibilityHidden(true)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        titleText
                        if viewModel.subtitle != nil {
                            subTitleText
                        }
                        errorText
                    }.padding(.leading, 16).padding(.top, 12).padding(.bottom, 14)
                    Spacer()
                    accessoryIcon.accessibilityHidden(true)
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            .frame(minHeight: viewModel.cellHeight)
        }
        .accessibilityElement(children: .combine)
        .accessibilityAction(named: viewModel.accessibilitySelectionText) {
            viewModel.selectionDidToggle?()
        }
        .if(viewModel.isCollapsed != nil) { view in
            view.accessibilityAction(named: viewModel.accessibilityAccordionHeaderText) {
                viewModel.collapseDidToggle?()
            }
        }
        .if(viewModel.state.isError) { view in
            view.accessibilityAction(named: Text("Remove item", bundle: .core)) {
                viewModel.removeItemPressed?()
            }
        }
        .accessibility(label: Text(viewModel.accessibilityText))
    }
}

#if DEBUG

struct ListCellView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
            ListCellView(ListCellViewModel(cellStyle: .mainAccordionHeader,
                                           title: "Top Secret.pdf",
                                           subtitle: "1MB",
                                           selectionState: .selected,
                                           isCollapsed: false,
                                           selectionDidToggle: {},
                                           state: .loading(nil)))
            Divider()
            ListCellView(ListCellViewModel(cellStyle: .listAccordionHeader,
                                           title: "Something",
                                           subtitle: nil,
                                           selectionState: .deselected,
                                           selectionDidToggle: {},
                                           state: .loading(0.2)))
            Divider()
            ListCellView(ListCellViewModel(cellStyle: .listAccordionHeader,
                                           title: "Files",
                                           subtitle: nil,
                                           selectionState: .deselected,
                                           isCollapsed: false,
                                           selectionDidToggle: {},
                                           state: .downloaded))
            Divider()
            ListCellView(ListCellViewModel(cellStyle: .listItem,
                                           title: "Creative Machines and Innovative Instrumentation.mov",
                                           subtitle: "4 GB",
                                           selectionState: .selected,
                                           isCollapsed: false,
                                           selectionDidToggle: {},
                                           state: .error(nil)
                                          )).padding(.leading, 20)
            Divider().padding(.leading, 20)
            Spacer()
        }
        VStack(spacing: 0) {
            Divider()
            ListCellView(ListCellViewModel(cellStyle: .mainAccordionHeader,
                                           title: "Top Secret.pdf",
                                           subtitle: nil,
                                           isCollapsed: false,
                                           state: .downloaded))
            Divider()
            ListCellView(ListCellViewModel(cellStyle: .listAccordionHeader,
                                           title: "Files",
                                           subtitle: "1.13 GB",
                                           isCollapsed: false,
                                           state: .loading(0.5)))
            Divider()
            ListCellView(ListCellViewModel(cellStyle: .listItem,
                                           title: "Creative Machines and Innovative Instrumentation.mov",
                                           subtitle: "4 GB",
                                           isCollapsed: false,
                                           state: .error("Sync Failed"))).padding(.leading, 40)
            Divider().padding(.leading, 56)
            Spacer()
        }
    }
}

#endif
