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

import UIKit

<<<<<<<< HEAD:packages/HorizonUI/Sources/HorizonUI/Sources/HorizonUI.swift
public struct HorizonUI {
    private init() {}
    
    public static func registerCustomFonts() {
        for font in Fonts.Variants.allCases {
            guard let url = Bundle.module.url(forResource: font.rawValue, withExtension: "ttf") else { continue }
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
========
extension Array where Element: UIBarButtonItem {
    func removeDuplicates() -> [Element] {
        return reduce([]) { result, element in
            result.contains { $0.action == element.action } ? result : result + [element]
>>>>>>>> origin/master:Core/Core/Common/Extensions/UIKit/Array+UIBarButtonItem.swift
        }
    }
}
