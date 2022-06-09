//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

extension AnnotationDragGestureViewModel {
    class DragInfo {
        /** In the gesture view's coordinate space. */
        public let dragPointWithinAnnotation: CGPoint
        public let draggedAnnotation: Annotation
        /** Added as a subview to the the gesture's view. */
        public let annotationClone: UIImageView

        public init(dragPointWithinAnnotation: CGPoint, draggedAnnotation: Annotation, annotationClone: UIImageView) {
            self.dragPointWithinAnnotation = dragPointWithinAnnotation
            self.draggedAnnotation = draggedAnnotation
            self.annotationClone = annotationClone
        }

        deinit {
            // Re-rendering the moved annotation to its new place takes some time so we keep the clone on screen to avoid a blink
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [annotationClone] in
                annotationClone.removeFromSuperview()
            }
        }
    }
}
