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

public struct WrappingHStack<Model, V>: View where Model: Hashable, V: View {
    public typealias ViewGenerator = (Model) -> V
    var models: [Model]
    var viewGenerator: ViewGenerator
    var horizontalSpacing: CGFloat
    var verticalSpacing: CGFloat

    @State private var totalHeight = CGFloat.zero

    public init(
        models: [Model],
        horizontalSpacing: CGFloat = 5,
        verticalSpacing: CGFloat = 5,
        viewGenerator: @escaping ViewGenerator
    ) {
        self.models = models
        self.viewGenerator = viewGenerator
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = horizontalSpacing
    }

    public var body: some View {
        VStack {
            GeometryReader { geometry in
                self.generateContent(in: geometry)
            }
        }
        .frame(height: totalHeight)
    }

    private func generateContent(in geometry: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        return ZStack(alignment: .topLeading) {
            ForEach(self.models, id: \.self) { models in
                viewGenerator(models)
                    .padding(.horizontal, horizontalSpacing)
                    .padding(.vertical, verticalSpacing)
                    .alignmentGuide(.leading, computeValue: { dimension in
                        if (abs(width - dimension.width) > geometry.size.width) {
                            width = 0
                            height -= dimension.height
                        }
                        let result = width
                        if models == self.models.last! {
                            width = 0
                        } else {
                            width -= dimension.width
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: { _ in
                        let result = height
                        if models == self.models.last! {
                            height = 0 // last item
                        }
                        return result
                    })
            }
        }.background(viewHeightReader($totalHeight))
    }

    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        return GeometryReader { geometry -> Color in
            let rect = geometry.frame(in: .local)
            DispatchQueue.main.async {
                binding.wrappedValue = rect.size.height
            }
            return .clear
        }
    }
}

#if DEBUG

struct WrappingHStack_Previews: PreviewProvider {
    static let context = PreviewEnvironment().globalDatabase.viewContext

    static var previews: some View {
        WrappingHStack(models: [
            .init(id: "1", name: "Alice", avatarURL: nil),
            .init(id: "2", name: "Bob", avatarURL: nil)
        ]) { recipient in
            RecipientPillView(recipient: recipient, removeDidTap: { _ in  })
        }
    }
}

#endif
