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

import SwiftUI

/**
 Each course card's onDrop action uses this delegate to calculate the new order of cards.
 */
class CourseCardDropToReorderDelegate {
    public typealias CardID = String
    public static let DropID = "DashboardCardID"

    @Binding private var draggedCourseCardId: String?
    private let receiverCardId: String
    private var order: [CardID]
    private weak var delegate: CourseCardOrderChangeDelegate?

    public init(receiverCardId: String,
                draggedCourseCardId: Binding<String?>,
                order: [CardID],
                delegate: CourseCardOrderChangeDelegate) {
        self.receiverCardId = receiverCardId
        self._draggedCourseCardId = draggedCourseCardId
        self.order = order
        self.delegate = delegate
    }

    func dropUpdated() -> DropProposal? {
        DropProposal(operation: .move)
    }

    func performDrop() -> Bool {
        delegate?.reorderDidFinish()
        return true
    }

    func dropEntered() {
        guard let draggedCourseCardId,
              // If we dragged the card over itself do nothing as the order doesn't change
              receiverCardId != draggedCourseCardId,
              let draggedIndex = order.firstIndex(of: draggedCourseCardId),
              let insertIndex = order.firstIndex(of: receiverCardId)
        else { return }

        order.move(fromOffsets: IndexSet(integer: draggedIndex),
                   toOffset: insertIndex > draggedIndex ? insertIndex + 1 : insertIndex)
        delegate?.orderDidChange(order)
    }
}

extension CourseCardDropToReorderDelegate: DropDelegate {

    func dropUpdated(info: DropInfo) -> DropProposal? {
        dropUpdated()
    }

    func performDrop(info: DropInfo) -> Bool {
        performDrop()
    }

    func dropEntered(info: DropInfo) {
        dropEntered()
    }
}
