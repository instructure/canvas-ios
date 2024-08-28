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

extension UIColor {

    static var defaultContextColor: UIColor { .ash }
    static var defaultElementaryColor: UIColor { .oxford }

    /// - parameters:
    ///   - courseColorHex: The course color assigned to an elementary course by the teacher.
    ///   - contextColorHex: The context's color that can be customized by the user.
    static func contextColor(
        courseColorHex: String?,
        contextColorHex: String?,
        k5State: K5State
    ) -> UIColor {
        let effectiveColorHex = k5State.isK5Enabled ? courseColorHex : contextColorHex

        guard let effectiveColor = UIColor(hexString: effectiveColorHex) else {
            return k5State.isK5Enabled ? defaultElementaryColor : defaultContextColor
        }

        return effectiveColor.ensureContrast(against: backgroundLightest)
    }
}
