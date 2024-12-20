//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
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
import UIKit
import PSPDFKit
import PSPDFKitUI

public class DocViewerAnnotationToolbar: AnnotationToolbar {
    public var showDoneButton: Bool = true
    public var isDragButtonSelected: AnyPublisher<Bool, Never> { dragButtonStateUpdater.isButtonSelected }
    private var dragButtonStateUpdater: DragButtonStateViewModel

    override public var doneButton: UIButton? {
        return showDoneButton ? super.doneButton : nil
    }

    public override init(annotationStateManager: AnnotationStateManager) {
        let dragButton = ToolbarSelectableButton()
        dragButton.image = .grab
        dragButton.isCollapsible = false
        dragButton.accessibilityLabel = String(localized: "Move Annotation", bundle: .core)
        dragButton.selectionPadding = 4
        dragButtonStateUpdater = DragButtonStateViewModel(dragButton: dragButton, annotationStateManager: annotationStateManager)

        super.init(annotationStateManager: annotationStateManager)

        self.configurations = [Self.makeToolbarConfiguration()]
        self.additionalButtons = [dragButton]
        self.supportedToolbarPositions = .inTopBar
        self.isDragEnabled = false
        self.showDoneButton = false

        // Only at this point is when the button is fully set up
        // so we override the default corner radius to match toolbar buttons
        dragButton.layer.sublayers?.first?.cornerRadius = 13
    }

    private static func makeToolbarConfiguration() -> AnnotationToolConfiguration {
        typealias Item = AnnotationToolConfiguration.ToolItem
        let items: [Item] = [
            Item(type: .stamp, variant: nil) { _, _, _ in .markerSolid }, // comment pin
            Item(type: .highlight, variant: nil) { _, _, _ in .highlighterSolid },
            Item(type: .freeText, variant: nil) { _, _, _ in .textLine },
            Item(type: .strikeOut, variant: nil) { _, _, _ in .strikethroughSolid },
            Item(type: .ink, variant: nil) { _, _, _ in .paintSolid },
            Item(type: .square, variant: nil) { _, _, _ in .boxSolid },
            Item(type: .eraser, variant: nil)
        ]
        let groups = items.map { AnnotationToolConfiguration.ToolGroup(items: [$0]) }
        return AnnotationToolConfiguration(annotationGroups: groups)
    }
}
