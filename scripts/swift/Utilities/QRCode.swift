//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

import AppKit
import CoreImage

enum QRCode {
    static func generatePng(_ data: Data, scale: Int) -> Data? {
        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        qrFilter.setValue(data, forKey: "inputMessage")
        let transform = CGAffineTransform(scaleX: CGFloat(scale), y: CGFloat(scale))
        guard let ciImage = qrFilter.outputImage?.transformed(by: transform) else { return nil }
        return CIContext().pngRepresentation(of: ciImage, format: .L8, colorSpace: CGColorSpaceCreateDeviceGray())
    }

    static func generatePng(_ string: String, scale: Int) -> Data? {
        generatePng(string.data(using: .utf8)!, scale: scale)
    }
}
