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

class DocViewerCommentReplyAnnotation: NoteAnnotation {
    var inReplyToName: String?
}

extension Annotation {
    func drawRepliesIcon(in context: CGContext, options: RenderOptions?) {
        guard hasReplies == true else { return }
        let bb = CGRect(x: boundingBox.maxX - 7, y: boundingBox.maxY - 8, width: 24, height: 24)
        context.saveGState()
        context.setFillColor(DocViewerAnnotationColor.blue.color.cgColor)
        context.clip(to: bb, mask: UIImage.commentLine.cgImage!)
        context.addRect(bb)
        context.fillPath()
        context.restoreGState()
    }
}

class DocViewerHighlightAnnotation: HighlightAnnotation {
    open override func draw(context: CGContext, options: RenderOptions?) {
        super.draw(context: context, options: options)
        drawRepliesIcon(in: context, options: options)
    }
}

class DocViewerStrikeOutAnnotation: StrikeOutAnnotation {
    open override func draw(context: CGContext, options: RenderOptions?) {
        super.draw(context: context, options: options)
        drawRepliesIcon(in: context, options: options)
    }
}

class DocViewerFreeTextAnnotation: FreeTextAnnotation {
    open override func draw(context: CGContext, options: RenderOptions?) {
        super.draw(context: context, options: options)
        drawRepliesIcon(in: context, options: options)
    }
}

class DocViewerInkAnnotation: InkAnnotation {
    open override func draw(context: CGContext, options: RenderOptions?) {
        super.draw(context: context, options: options)
        drawRepliesIcon(in: context, options: options)
    }
}

class DocViewerSquareAnnotation: SquareAnnotation {
    open override func draw(context: CGContext, options: RenderOptions?) {
        super.draw(context: context, options: options)
        drawRepliesIcon(in: context, options: options)
    }
}
