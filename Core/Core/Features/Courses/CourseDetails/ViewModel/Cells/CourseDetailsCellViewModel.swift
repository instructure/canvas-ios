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
import SwiftUI

public class CourseDetailsCellViewModel: Equatable, Identifiable, ObservableObject {
    public enum AccessoryType {
        case disclosure
        case externalLink
        case loading
    }

    @Published public var showGenericError: Bool = false
    @Published public internal(set) var accessoryIconType: AccessoryType
    @Published public var isHighlighted = false
    @Published public var isSupportedOffline: Bool = false
    @Published public var isAvailable = true

    public let a11yIdentifier: String
    public let courseColor: UIColor
    public let iconImage: UIImage
    public let label: String
    public let subtitle: String?
    public let tabID: String
    public let selectedCallback: (() -> Void)?

    private let offlineModeInteractor: OfflineModeInteractor

    public init(courseColor: UIColor,
                iconImage: UIImage,
                label: String,
                subtitle: String?,
                accessoryIconType: AccessoryType,
                tabID: String,
                offlineModeInteractor: OfflineModeInteractor = OfflineModeAssembly.make(),
                selectedCallback: (() -> Void)?) {
        self.a11yIdentifier = "courses-details.\(tabID)-cell"
        self.courseColor = courseColor
        self.iconImage = iconImage
        self.label = label
        self.subtitle = subtitle
        self.accessoryIconType = accessoryIconType
        self.tabID = tabID
        self.offlineModeInteractor = offlineModeInteractor
        self.selectedCallback = selectedCallback

        offlineModeInteractor
            .observeIsOfflineMode()
            .map { [unowned self] isOffline in
                !isOffline || self.isSupportedOffline
            }
            .assign(to: &$isAvailable)
    }

    open func selected(router: Router, viewController: WeakViewController) {
        selectedCallback?()
    }
}

extension CourseDetailsCellViewModel {

    public static func == (lhs: CourseDetailsCellViewModel, rhs: CourseDetailsCellViewModel) -> Bool {
        lhs.tabID == rhs.tabID
    }
}
