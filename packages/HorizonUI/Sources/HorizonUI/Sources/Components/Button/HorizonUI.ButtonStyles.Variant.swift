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

extension HorizonUI.ButtonStyles {
    enum Variant {
        case ai
        case beige
        case black
        case blue
        case white
        
        var background: any ShapeStyle {
            switch self {
            case .ai: return .black
            case .beige: return .black
            case .black: return .black
            case .blue: return .black
            case .white: return .black
            }
        }
        
        var foregroundColor: Color {
            switch self {
            case .ai: return .white
            case .beige: return .white
            case .black: return .white
            case .blue: return .white
            case .white: return .white
            }
        }
    }
    
    static func ai(
        isSmall: Bool = false,
        fillsWidth: Bool = false,
        leading: some View = EmptyView(),
        trailing: some View = EmptyView()
    ) -> HorizonUI.ButtonStyles {
        self.init(
            variant: .ai,
            fillsWidth: fillsWidth,
            leading: leading,
            trailing: trailing
        )
    }
    
    static func beige(
        isSmall: Bool = false,
        fillsWidth: Bool = false,
        leading: some View = EmptyView(),
        trailing: some View = EmptyView()
    ) -> HorizonUI.ButtonStyles {
        self.init(
            variant: .beige,
            fillsWidth: fillsWidth,
            leading: leading,
            trailing: trailing
        )
    }
}
