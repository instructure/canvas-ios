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

public extension InstUI.Styles {
    enum Text {
        case heading
        /// Text below heading
        case headingInfo
        case infoTitle
        case infoDescription
        case sectionHeader
        case cellLabel
        case cellLabelSubtitle
        case cellValue
        case selectedValue
        case errorMessage
        case dropDownOption
    }
}

public extension View {

    @ViewBuilder
    func textStyle(_ textStyle: InstUI.Styles.Text) -> some View {
        switch textStyle {
        case .heading:
            self
                .font(.semibold22, lineHeight: .fit)
                .foregroundStyle(Color.textDarkest)
                .accessibilityAddTraits(.isHeader)
        case .headingInfo:
            self
                .font(.regular16, lineHeight: .fit)
                .foregroundStyle(Color.textDark)
        case .infoTitle:
            self
                .font(.regular14)
                .foregroundStyle(Color.textDark)
        case .infoDescription:
            self
                .font(.regular16, lineHeight: .fit)
                .foregroundStyle(Color.textDarkest)
        case .sectionHeader:
            self
                .font(.semibold14, lineHeight: .fit)
                .foregroundStyle(Color.textDark)
        case .cellLabel:
            self
                .font(.semibold16, lineHeight: .fit)
                .foregroundStyle(Color.textDarkest)
        case .cellLabelSubtitle:
            self
                .font(.regular14, lineHeight: .fit)
                .foregroundStyle(Color.textDark)
        case .cellValue:
            self
                .font(.regular14, lineHeight: .fontDefault)
                .foregroundStyle(Color.textDark)
        case .selectedValue:
            self
                .font(.regular14, lineHeight: .fontDefault)
                .foregroundStyle(Color.textDarkest)
        case .errorMessage:
            self
                .font(.regular16, lineHeight: .fontDefault)
                .foregroundStyle(Color.textDanger)
        case .dropDownOption:
            self
                .font(.regular16, lineHeight: .fit)
                .foregroundStyle(Color.textDarkest)
        }
    }
}
