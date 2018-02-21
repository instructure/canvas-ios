//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import UIKit
import PSPDFKit
import PSPDFKitUI

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
