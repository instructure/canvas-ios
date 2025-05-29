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

// Extension to easily apply rounded corners to specific corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorners(radius: radius, corners: corners))
    }
}

// Reusable shape for specific corner rounding
public struct RoundedCorners: Shape {
    private var radius: CGFloat
    private var corners: UIRectCorner

    init(radius: CGFloat, corners: UIRectCorner) {
        self.radius = radius
        self.corners = corners
    }

    public var animatableData: CGFloat {
        get { radius }
        set { radius = newValue }
    }

    public func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

struct DocViewerAnnotationToolsView: View {
    @ObservedObject private var viewModel: DocViewerAnnotationSaveStateViewModel
    @State private var isOpen = true
    @State private var size: CGSize = .zero
    @State private var buttonSize: CGSize = .zero
    private var buttonIcon: Image { isOpen ? .arrowOpenLeftSolid : .editLine }
    private var cornerRadius: CGFloat { isOpen ? 0 : 30 }
    private var trailingPadding: CGFloat { isOpen ? 16 : 10 }
    private var offsetX: CGFloat { isOpen ? 0 : -(size.width - buttonSize.width - 2 * trailingPadding) }

    init(
        viewModel: DocViewerAnnotationSaveStateViewModel,
    ) {
        self.viewModel = viewModel
    }

    var body: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                DocViewerAnnotationSaveStateView(viewModel: viewModel)
            }
            closeButton
                .onSizeChange(update: $buttonSize)
        }
        .frame(minHeight: 52)
        .paddingStyle(.leading, .standard)
        .padding(.trailing, trailingPadding)
        .paddingStyle(.vertical, .textVertical)
        .frame(maxWidth: .infinity)
        .background(Color.backgroundLightest)
        .cornerRadius(cornerRadius, corners: [.topRight, .bottomRight])
        .onSizeChange(update: $size)
        .offset(x: offsetX)
        .clipped()
    }

    private var closeButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.3)) {
                isOpen.toggle()
            }
        } label: {
            Circle()
                .frame(width: 32, height: 32)
                .foregroundStyle(Color.backgroundLight)
                .overlay(
                    buttonIcon
                        .scaledIcon(size: 20)
                        .foregroundStyle(Brand.shared.primary.asColor)
                        .offset(x: -1, y: 0)
                )
        }
        .frame(minHeight: 52)
    }
}

#if DEBUG

#Preview {
    VStack {
        DocViewerAnnotationToolsView(viewModel: DocViewerAnnotationSaveStateViewModel())
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.black)
}

#endif
