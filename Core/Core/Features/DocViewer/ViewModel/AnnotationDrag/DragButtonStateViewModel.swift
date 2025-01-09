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

import Combine
import PSPDFKit
import PSPDFKitUI

/**
 This class synchronizes the selected state between the drag button and the annotation buttons. If an annotation button is selected then the drag
 button gets de-selected but if the drag button is selected then we'll de-select any previously toggled annotation button.
 */
class DragButtonStateViewModel: NSObject {
    public lazy var isButtonSelected: AnyPublisher<Bool, Never> = isButtonSelectedSubject.eraseToAnyPublisher()

    private weak var annotationStateManager: AnnotationStateUpdater?
    private let dragButton: ToolbarSelectableButton
    private let isButtonSelectedSubject = CurrentValueSubject<Bool, Never>(false)

    public init(dragButton: ToolbarSelectableButton, annotationStateManager: AnnotationStateUpdater) {
        self.dragButton = dragButton
        self.annotationStateManager = annotationStateManager
        super.init()

        annotationStateManager.add(self)
        dragButton.actionBlock = { [weak self] _ in
            self?.dragButtonTapped()
        }
    }

    public func anotherAnnotationButtonSelected() {
        dragButton.setSelected(false, animated: true)
        isButtonSelectedSubject.send(false)
    }

    private func dragButtonTapped() {
        annotationStateManager?.setState(nil, variant: nil)
        dragButton.setSelected(!dragButton.isSelected, animated: true)
        isButtonSelectedSubject.send(dragButton.isSelected)
    }
}

extension DragButtonStateViewModel: AnnotationStateManagerDelegate {
    public func annotationStateManager(_ manager: AnnotationStateManager,
                                       didChangeState oldState: Annotation.Tool?,
                                       to newState: Annotation.Tool?,
                                       variant oldVariant: Annotation.Variant?,
                                       to newVariant: Annotation.Variant?) {
        anotherAnnotationButtonSelected()
    }
}

/** This is to hide the PSPDFKit implementation so we can mock it. */
protocol AnnotationStateUpdater: AnyObject {
    func add(_ delegate: AnnotationStateManagerDelegate)
    func setState(_ state: Annotation.Tool?, variant: Annotation.Variant?)
}

extension AnnotationStateManager: AnnotationStateUpdater {
}
