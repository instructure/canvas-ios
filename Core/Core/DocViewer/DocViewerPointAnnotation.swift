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

import PSPDFKit

class DocViewerPointAnnotation: StampAnnotation {
    override var isResizable: Bool { return false }
    override var shouldMaintainAspectRatio: Bool { return true }

    override func draw(context: CGContext, options: RenderOptions?) {
        context.saveGState()
        let cgColor = color?.cgColor ?? DocViewerAnnotationColor.blue.color.cgColor
        context.setFillColor(cgColor)

        // scale to fit, centered
        let bb = boundingBox
        let scale = min(bb.width / 17, bb.height / 24)
        context.translateBy(x: bb.midX, y: bb.midY)
        context.scaleBy(x: scale, y: -scale)
        context.translateBy(x: -8.5, y: -12) // go back half of new 17x24 box

        /* SVG Path used by original icon: viewBox="0 0 17 24"
        M 8.21 0
        C 3.684 0 0 3.683 0 8.21
        C 0 10.468 1.004 12.56 3.068 14.605
        C 6.065 17.58 7.461 20.325 7.461 23.25
        V 24
        H 8.961
        V 23.25
        C 8.961 20.34 10.341 17.673 13.431 14.607
        C 15.498 12.56 16.501 10.469 16.501 8.211
        C 16.5 3.683 12.816 0 8.21 0
        */
        context.beginPath()
        context.move(to: CGPoint(x: 8.21, y: 0))
        context.addCurve(to: CGPoint(x: 0, y: 8.21), control1: CGPoint(x: 3.684, y: 0), control2: CGPoint(x: 0, y: 3.683))
        context.addCurve(to: CGPoint(x: 3.068, y: 14.605), control1: CGPoint(x: 0, y: 10.468), control2: CGPoint(x: 1.004, y: 12.56))
        context.addCurve(to: CGPoint(x: 7.461, y: 23.25), control1: CGPoint(x: 6.065, y: 17.58), control2: CGPoint(x: 7.461, y: 20.325))
        context.addLine(to: CGPoint(x: 7.461, y: 24))
        context.addLine(to: CGPoint(x: 8.961, y: 24))
        context.addLine(to: CGPoint(x: 8.961, y: 23.25))
        context.addCurve(to: CGPoint(x: 13.431, y: 14.607), control1: CGPoint(x: 8.961, y: 20.34), control2: CGPoint(x: 10.341, y: 17.673))
        context.addCurve(to: CGPoint(x: 16.501, y: 8.211), control1: CGPoint(x: 15.498, y: 12.56), control2: CGPoint(x: 16.501, y: 10.469))
        context.addCurve(to: CGPoint(x: 8.21, y: 0), control1: CGPoint(x: 16.5, y: 3.683), control2: CGPoint(x: 12.816, y: 0))
        context.fillPath()
        context.restoreGState()
    }
}
