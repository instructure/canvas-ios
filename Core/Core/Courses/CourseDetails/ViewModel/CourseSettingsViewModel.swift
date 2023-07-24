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

public class CourseSettingsViewModel: ObservableObject {
    public enum ViewModelState: Equatable {
        case loading
        case saving
        case ready
    }

    @Published public var newName: String = ""
    @Published public var newDefaultView: CourseDefaultView = .wiki
    @Published public var showError: Bool = false
    @Published public private(set) var state: ViewModelState = .loading
    @Published public private(set) var errorText: String?
    @Published public private(set) var courseColor: UIColor?
    @Published public private(set) var courseName: String?
    @Published public private(set) var imageURL: URL?
    @Published public private(set) var hideColorOverlay: Bool?
    public var courseID: String {
        course.first?.id ?? ""
    }

    private let env = AppEnvironment.shared
    private var isFirstAppearance = true
    private var context: Context
    private lazy var colors = env.subscribe(GetCustomColors())
    private lazy var course = env.subscribe(GetCourse(courseID: context.id)) { [weak self] in
        self?.courseDidUpdate()
    }

    private lazy var settings: Store<GetUserSettings> = env.subscribe(GetUserSettings(userID: "self")) { [weak self] in
        self?.hideColorOverlay = self?.settings.first?.hideDashcardColorOverlays == true
    }

    public init(context: Context) {
        self.context = context
    }

    public func viewDidAppear() {
        guard isFirstAppearance else { return }
        isFirstAppearance = false
        settings.refresh()
        course.refresh()
        colors.refresh()
    }

    public func defaultViewSelectorTapped(router: Router, viewController: WeakViewController) {
        let options = CourseDefaultView.allCases
        let sections = [
            ItemPickerSection(items: options.map { ItemPickerItem(title: $0.string) }),
        ]

        let selected: IndexPath? = options.firstIndex(of: newDefaultView).flatMap { IndexPath(row: $0, section: 0) }
        let itemPicker = ItemPickerViewController.create(
            title: NSLocalizedString("Set \"Home\" to...", comment: ""),
            sections: sections,
            selected: selected,
            didSelect: {
                self.newDefaultView = options[$0.row]
            }
        )
        router.show(itemPicker, from: viewController)
    }

    public func doneTapped(router: Router, viewController: WeakViewController) {
        guard newName != courseName || newDefaultView != course.first?.defaultView else {
            router.dismiss(viewController)
            return
        }

        state = .saving
        UpdateCourse(courseID: context.id,
                     name: newName,
                     defaultView: newDefaultView).fetch { [weak self] result, _, error in performUIUpdate {
            guard let self = self else { return }
            self.state = .ready

            if error != nil {
                self.errorText = error?.localizedDescription
                self.showError = true
            }

            if result != nil {
                router.dismiss(viewController)
            }
        } }
    }

    private func courseDidUpdate() {
        guard course.requested, !course.pending, let course = course.first else { return }
        courseColor = course.color
        courseName = course.name
        newName = courseName ?? ""
        imageURL = course.imageDownloadURL
        newDefaultView = course.defaultView ?? .wiki
        state = .ready
    }
}
