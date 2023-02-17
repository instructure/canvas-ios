//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

import Foundation
import UIKit

extension UIColor {
    // MARK: Hex ARGB Handling

    public convenience init?(hexString: String?) {
        guard let hexString = hexString, hexString.hasPrefix("#"), let num = UInt(hexString.dropFirst(), radix: 16) else { return nil }
        var r: UInt = 0, g: UInt = 0, b: UInt = 0, a: UInt = 255
        switch hexString.count - 1 {
        case 8:
            a = (num & 0xff000000) >> 24
            fallthrough
        case 6:
            r = (num & 0xff0000) >> 16
            g = (num & 0x00ff00) >> 8
            b = (num & 0x0000ff) >> 0
        case 4:
            a = ((num & 0xf000) >> 8) + ((num & 0xf000) >> 12)
            fallthrough
        case 3:
            r = ((num & 0xf00) >> 4) + ((num & 0xf00) >> 8)
            g = ((num & 0x0f0) >> 0) + ((num & 0x0f0) >> 4)
            b = ((num & 0x00f) << 4) + ((num & 0x00f) >> 0)
        default:
            return nil
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }

    public var hexString: String { hexString(userInterfaceStyle: .current) }
    public var intValue: UInt32 { intValue(userInterfaceStyle: .current) }
    /** Returns the color for the current app appearance. */
    private var interfaceStyleColor: UIColor { resolvedColor(with: .current) }

    public convenience init(intValue value: UInt32) {
        self.init(
            red: CGFloat((value & 0xff0000) >> 16) / 255,
            green: CGFloat((value & 0x00ff00) >> 8) / 255,
            blue: CGFloat((value & 0x0000ff) >> 0) / 255,
            alpha: CGFloat((value & 0xff000000) >> 24) / 255
        )
    }

    /** Returns the given color for the current interface style. */
    public static func getColor(dark: UIColor, light: UIColor) -> UIColor {
        return UIColor { traitCollection  in
            return traitCollection.isDarkInterface ? dark : light
        }
    }

    public func difference(to other: UIColor) -> CGFloat {
        var ared: CGFloat = 0, agreen: CGFloat = 0, ablue: CGFloat = 0, aalpha: CGFloat = 1
        interfaceStyleColor.getRed(&ared, green: &agreen, blue: &ablue, alpha: &aalpha) // assume success
        var bred: CGFloat = 0, bgreen: CGFloat = 0, bblue: CGFloat = 0, balpha: CGFloat = 1
        other.interfaceStyleColor.getRed(&bred, green: &bgreen, blue: &bblue, alpha: &balpha) // assume success
        return abs(ared - bred) + abs(agreen - bgreen) + abs(ablue - bblue) + abs(aalpha - balpha)
    }

    public func hexString(userInterfaceStyle: UIUserInterfaceStyle) -> String {
        let intValue = intValue(userInterfaceStyle: userInterfaceStyle)
        return "#\(String(intValue, radix: 16))".replacingOccurrences(of: "#ff", with: "#")
    }

    public func intValue(userInterfaceStyle: UIUserInterfaceStyle) -> UInt32 {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 1
        resolvedColor(with: UITraitCollection(userInterfaceStyle: userInterfaceStyle)).getRed(&red, green: &green, blue: &blue, alpha: &alpha) // assume success
        let toInt = { (n: CGFloat) in return UInt32(max(0.0, min(1.0, n)) * 255) }
        return (toInt(alpha) << 24) + (toInt(red) << 16) + (toInt(green) << 8) + toInt(blue)
    }

    // MARK: App Logo Colors
    public static var parentLogoColor = UIColor(hexString: "#008EE2")!
    public static var studentLogoColor = UIColor(hexString: "#D64027")!
    public static var teacherLogoColor = UIColor(hexString: "#FFC100")!

    public static func currentLogoColor(for identifier: String? = Bundle.main.bundleIdentifier) -> UIColor {
        switch identifier {
        case Bundle.teacherBundleID:
            return .teacherLogoColor
        case Bundle.parentBundleID:
            return .parentLogoColor
        default: // .studentBundleID
            return .studentLogoColor
        }
    }

    // MARK: Contrast

    /// Relative luminance as defined by WCAG 2.0
    ///
    /// https://www.w3.org/TR/WCAG20/#relativeluminancedef
    /// `0.0` for darkest black and `1.0` for lightest white.
    public var luminance: CGFloat {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0
        interfaceStyleColor.getRed(&red, green: &green, blue: &blue, alpha: nil) // assume success
        let convert = { (c: CGFloat) -> CGFloat in
            return c <= 0.03928 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4)
        }
        return 0.2126 * convert(red) + 0.7152 * convert(green) + 0.0722 * convert(blue)
    }

    /// Contrast ratio as defined by WCAG 2.0
    ///
    /// http://www.w3.org/TR/WCAG20/#contrast-ratiodef
    /// `1.0` for identical colors and `21.0` for black against white.
    public func contrast(against: UIColor) -> CGFloat {
        let lum1 = luminance + 0.05
        let lum2 = against.luminance + 0.05
        return lum1 > lum2 ? lum1 / lum2 : lum2 / lum1
    }

    public func darkenToEnsureContrast(against: UIColor) -> UIColor {
        return UIColor.getColor(dark: darkenToEnsureStyleContrast(against: against.resolvedColor(with: .dark)),
                                light: darkenToEnsureStyleContrast(against: against.resolvedColor(with: .light)))
    }

    /// Ensures contrast against the given parameter by darkening the source color even if the parameter color is lighter.
    private func darkenToEnsureStyleContrast(against: UIColor) -> UIColor {
        let minRatio: CGFloat = 4.5
        guard contrast(against: against) < minRatio else {
            return self
        }
        var hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0, alpha: CGFloat = 1
        interfaceStyleColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        var color = interfaceStyleColor
        while color.contrast(against: against) < minRatio, saturation >= 0.0, saturation <= 1.0 {
            if brightness >= 0.0, brightness <= 1.0 {
                brightness += -0.01
            } else {
                saturation += 0.01
            }
            color = UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
        }
        return color
    }

    /// Get a sufficiently contrasting color based on the current color.
    ///
    /// This ensures that the corresponding interface style color is being used as an against color.
    public func ensureContrast(against: UIColor) -> UIColor {
        return UIColor.getColor(dark: ensureStyleContrast(against: against.resolvedColor(with: .dark)),
                                light: ensureStyleContrast(against: against.resolvedColor(with: .light)))
    }

    /// Get a sufficiently contrasting color based on the current color.
    ///
    /// If the user asked for more contrast, and there isn't enough, return a high enough contrasting color.
    /// This is intended to be used with branding colors
    private func ensureStyleContrast(against: UIColor) -> UIColor {
        let minRatio: CGFloat = 4.5
        guard contrast(against: against) < minRatio else {
            return self
        }

        // This can iterate up to 200ish times, if performance becomes a problem we can instead
        // return against.luminance < 0.5 ? .white : .black

        var hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0, alpha: CGFloat = 1
        interfaceStyleColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)

        let delta: CGFloat = against.luminance < 0.5 ? 0.01 : -0.01
        var color = interfaceStyleColor
        while color.contrast(against: against) < minRatio, saturation >= 0.0, saturation <= 1.0 {
            if brightness >= 0.0, brightness <= 1.0 {
                brightness += delta // first modify brightness
            } else {
                saturation -= 0.01 // then desaturate if needed
            }
            color = UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
        }
        return color
    }
}
