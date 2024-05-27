//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

// MARK: - Values

extension InstUI.Styles {

    public enum Padding: CGFloat {
        case standard = 16

        case cellTop = 12
        case cellBottom = 14
        /// The horizontal padding before a cell's leading icon
        case cellIconLeading = 22
        /// The horizontal padding between a cell's leading icon and its text
        case cellIconText = 18

        case paragraphTop = 24
        case paragraphBottom = 28

        /// When displaying multiple Text components below each other we use this spacing to separate them
        case textVertical = 4

        /// Corrections to negate baked in TextEditor insets, estimated values
        case textEditorVerticalCorrection = -7
        case textEditorHorizontalCorrection = -5
    }

    public enum PaddingSet {
        /// Default paddings for cells
        case standardCell
        /// Paddings for cells with leading icon
        case iconCell
        /// Paddings to negate TextEditor insets
        case textEditorCorrection

        var config: Config {
            switch self {
            case .standardCell:
                Config(
                    top: .cellTop,
                    bottom: .cellBottom,
                    leading: .standard,
                    trailing: .standard
                )
            case .iconCell:
                Config(
                    top: .cellTop,
                    bottom: .cellBottom,
                    leading: .cellIconLeading,
                    trailing: .standard
                )
            case .textEditorCorrection:
                Config(
                    top: .textEditorVerticalCorrection,
                    bottom: .textEditorVerticalCorrection,
                    leading: .textEditorHorizontalCorrection,
                    trailing: .textEditorHorizontalCorrection
                )
            }
        }

        struct Config {
            let top: Padding?
            let bottom: Padding?
            let leading: Padding?
            let trailing: Padding?
        }
    }
}

// MARK: - Modifiers

extension View {

    @inlinable
    public func paddingStyle(
        _ edges: Edge.Set = .all,
        _ padding: InstUI.Styles.Padding? = nil
    ) -> some View {
        self.padding(edges, padding?.rawValue)
    }

    public func paddingStyle(set: InstUI.Styles.PaddingSet) -> some View {
        self
            .applyPadding(edge: .top, padding: set.config.top)
            .applyPadding(edge: .bottom, padding: set.config.bottom)
            .applyPadding(edge: .leading, padding: set.config.leading)
            .applyPadding(edge: .trailing, padding: set.config.trailing)
    }
}

// MARK: - Helpers

extension View {
    private func applyPadding(edge: Edge.Set, padding: InstUI.Styles.Padding?) -> some View {
        modifier(PaddingModifier(edge: edge, padding: padding))
    }
}

private struct PaddingModifier: ViewModifier {
    private var edge: Edge.Set
    private var padding: InstUI.Styles.Padding?

    init(edge: Edge.Set, padding: InstUI.Styles.Padding?) {
        self.edge = edge
        self.padding = padding
    }

    func body(content: Content) -> some View {
        if let padding {
            content.paddingStyle(edge, padding)
        } else {
            content
        }
    }
}
