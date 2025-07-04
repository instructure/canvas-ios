//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

struct DocViewerAnnotationToolsView<AnnotationBar: View>: View {
    @ObservedObject private var viewModel: DocViewerAnnotationToolbarViewModel
    @State private var size: CGSize = .zero
    @State private var buttonSize: CGSize = .zero
    @ScaledMetric private var closedStateCornerRadius: CGFloat = 30
    @ScaledMetric private var borderWidth: CGFloat = 1 / UIScreen.main.scale
    private var buttonIcon: Image { viewModel.isOpen ? .arrowOpenLeftSolid : .editLine }
    private var cornerRadius: CGFloat { viewModel.isOpen ? 0 : closedStateCornerRadius }
    private var trailingPadding: CGFloat { viewModel.isOpen ? 16 : 10 }
    private var offsetX: CGFloat { viewModel.isOpen ? 0 : -(size.width - buttonSize.width - 2 * trailingPadding) }
    private let annotationToolbarView: AnnotationBar

    init(
        viewModel: DocViewerAnnotationToolbarViewModel,
        annotationToolbarView: AnnotationBar
    ) {
        self.viewModel = viewModel
        self.annotationToolbarView = annotationToolbarView
    }

    var body: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                annotationToolbarView
                    /// PSPDFKit's annotation toolbar has an internal rendering logic I couldn't control,
                    /// so we need to apply some magic numbers to align it properly.
                    .padding(.top, -7)
                    .padding(.leading, -9)
                    .frame(height: 39)
                DocViewerAnnotationSaveStateView(viewModel: viewModel)
            }
            closeButton
                .onSizeChange(update: $buttonSize)
        }
        .frame(minHeight: 56)
        .paddingStyle(.leading, .standard)
        .padding(.trailing, trailingPadding)
        .paddingStyle(.vertical, .textVertical)
        .frame(maxWidth: .infinity)
        .background(Color.backgroundLightest)
        .overlay(alignment: .bottom) {
            ToolbarBorder(isOpen: viewModel.isOpen)
                .stroke(Color.borderMedium, lineWidth: borderWidth)
        }
        .cornerRadius(cornerRadius, corners: [.topRight, .bottomRight])
        .onSizeChange(update: $size)
        .offset(x: offsetX)
        .clipped()
    }

    private var closeButton: some View {
        Button {
            viewModel.didTapCloseToggle.send()
        } label: {
            Circle()
                .scaledFrame(size: 32, useIconScale: true)
                .foregroundStyle(Color.backgroundLight)
                .overlay(
                    buttonIcon
                        .scaledIcon(size: 20)
                        .offset(x: -1, y: 0)
                )
        }
        .frame(minHeight: 52)
        .accessibilityLabel(Text("Annotation toolbar", bundle: .core))
        .accessibilityValue(viewModel.a11yValue)
        .accessibilityHint(viewModel.a11yHint)
    }
}

private struct ToolbarBorder: Shape {
    let isOpen: Bool

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.height))
        path.addLine(to: CGPoint(x: rect.maxX - (isOpen ? 0 : rect.height), y: rect.height))

        if isOpen {
            return path
        }

        let radius = rect.height / 2.0
        let centerX = rect.maxX - radius
        let centerY = rect.origin.y + rect.height / 2.0
        let center = CGPoint(x: centerX, y: centerY)

        path.addArc(
            center: center,
            radius: radius,
            startAngle: .degrees(90),
            endAngle: .degrees(-90),
            clockwise: true
        )

        return path
    }
}

#if DEBUG

#Preview {
    VStack {
        DocViewerAnnotationToolsView(
            viewModel: DocViewerAnnotationToolbarViewModel(),
            annotationToolbarView: Text(verbatim: "Annotation Toolbar")
        )
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.white)
}

#endif
