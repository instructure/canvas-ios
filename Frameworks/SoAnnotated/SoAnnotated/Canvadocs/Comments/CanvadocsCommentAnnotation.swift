//
//  CanvadocsCommentAnnotation.swift
//  SoAnnotated
//
//  Created by Ben Kraus on 7/12/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

import UIKit
import PSPDFKit

class CanvadocsCommentAnnotation: PSPDFNoteAnnotation {
    override var renderAnnotationIcon: UIImage? {
        return UIImage(named: "pointer", in: Bundle(for: CanvadocsCommentAnnotation.self), compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
    }
}

class CanvadocsCommentAnnotationView: PSPDFNoteAnnotationView {
    override var renderNoteImage: UIImage? {
        return UIImage(named: "pointer", in: Bundle(for: CanvadocsCommentAnnotation.self), compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
    }
}

class CanvadocsCommentReplyAnnotation: CanvadocsCommentAnnotation {
    var inReplyTo: String?
}
