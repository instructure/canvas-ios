//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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
import UIKit
import Combine

public protocol CoreSearchController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate {}
public class CoreSearchHostingController<Info: SearchContextInfo, Descriptor: SearchDescriptor, Content: View>:
    CoreHostingController<SearchHostingBaseView<Info, Content>>,
    CoreSearchController {

    @MainActor required dynamic init?(coder aDecoder: NSCoder) { nil }
    private enum SearchFieldState { case visible, hidden, removed }

    let searchContext: CoreSearchContext<Info>
    let searchDescriptor: Descriptor
    private let router: Router

    private(set) var selectedFilter: Descriptor.Filter?
    private var leftItems: [UIBarButtonItem]?

    private var searchFieldState: SearchFieldState = .removed
    private var subscriptions: Set<AnyCancellable> = []

    // MARK: Bar Button Items

    private lazy var searchBarItem = UIBarButtonItem(
        image: .smartSearchLine,
        primaryAction: UIAction(
            handler: { [weak self] _ in
                self?.showSearchField()
            }
        )
    ).with({ $0.accessibilityIdentifier = "search_bar_button" })

    private lazy var closeBarItem = UIBarButtonItem(
        image: .xLine,
        primaryAction: UIAction(
            handler: { [weak self] _ in
                self?.hideSearchField()
            }
        )
    ).with({
        $0.tintColor = .textLightest
        $0.accessibilityIdentifier = "close_bar_button"
    })

    private lazy var filterBarItem = UIBarButtonItem(
        image: .filterLine,
        primaryAction: UIAction(
            handler: { [weak self] _ in
                self?.showFilterEditor()
            }
        )
    ).with({
        $0.tintColor = .textLightest
        $0.accessibilityIdentifier = "filter_bar_button"
    })

    private lazy var supportBarItem: UIBarButtonItem? = {
        guard let support = searchDescriptor.support else { return nil }
        return UIBarButtonItem(
            image: support.icon.uiImage(),
            primaryAction: UIAction(
                handler: { [weak self] _ in
                    guard let self else { return }
                    support
                        .action
                        .trigger(for: self.searchContext, with: self.router, from: self)
                }
            )
        )
        .with({
            $0.tintColor = .textLightest
            $0.accessibilityIdentifier = "support_bar_button"
        })
    }()

    // MARK: Initialization & Setup

    public init(
        router: Router = AppEnvironment.shared.router,
        info: Info,
        descriptor: Descriptor,
        content: Content
    ) {
        self.router = router
        self.searchContext = CoreSearchContext(info: info)
        self.searchDescriptor = descriptor

        super.init(SearchHostingBaseView(content: content, searchContext: searchContext))
        self.searchContext.controller = self
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        leftItems = navigationItem.leftBarButtonItems

        self.searchDescriptor
            .isEnabled
            .sink { [weak self] isEnabled in
                self?.setupSearchItem(isEnabled)
            }
            .store(in: &subscriptions)
    }

    private func setupSearchItem(_ installed: Bool) {
        if installed == (searchFieldState != .removed) { return }
        if installed {
            hideSearchField()
        } else {
            removeSearchField()
        }
    }

    // MARK: Show/Hide Search Bar

    private func showSearchField() {
        selectedFilter = nil
        filterBarItem.image = .filterLine
        searchContext.reset()

        let searchView = UISearchField(
            frame: CGRect(
                origin: .zero,
                size: CGSize(width: CGFloat.greatestFiniteMagnitude, height: .greatestFiniteMagnitude)
            )
        )

        searchView.field.accessibilityIdentifier = "ui_search_field"
        searchView.field.placeholder = searchContext.searchPrompt
        searchView.field.text = searchContext.searchText.value
        searchView.field.delegate = self

        if let clearColor = searchContext.clearButtonColor {
            searchView.field.clearButtonColor = clearColor
        }

        navigationItem.leftBarButtonItems = [closeBarItem]
        navigationItem.hidesBackButton = true
        navigationItem.titleView = searchView
        navigationItem.rightBarButtonItems = [
            supportBarItem,
            filterBarItem
        ].compactMap({ $0 })

        searchFieldState = .visible
        applyNavBarTransition(.fadeIn)
        searchView.field.becomeFirstResponder()
    }

    private func hideSearchField() {
        navigationItem.titleView = nil
        navigationItem.hidesBackButton = false
        navigationItem.leftBarButtonItems = leftItems
        navigationItem.rightBarButtonItems = [searchBarItem]

        searchFieldState = .hidden
        applyNavBarTransition(.fadeOut)
    }

    private func removeSearchField() {
        navigationItem.titleView = nil
        navigationItem.hidesBackButton = false
        navigationItem.leftBarButtonItems = leftItems
        navigationItem.rightBarButtonItems = nil
        searchFieldState = .removed
    }

    private func showFilterEditor() {

        let filter: Binding<Descriptor.Filter?> = Binding { [ weak self] in
            self?.selectedFilter
        } set: { [weak self] newFilter in
            guard let self else { return }
            selectedFilter = newFilter
            filterBarItem.image = newFilter != nil ? .filterSolid : .filterLine
        }

        let filterEditorVC = CoreHostingController(
            searchDescriptor
                .filterEditorView(filter)
                .environment(Info.environmentKeyPath, searchContext)
        )
        filterEditorVC.view.accessibilityIdentifier = "filter_editor_view"
        router.show(filterEditorVC, from: self, options: .modal(.formSheet, animated: true))
    }

    private func applyNavBarTransition(_ transition: NavBarTransition) {
        navigationController?
            .navigationBar
            .layer
            .add(transition.caTransition, forKey: transition.rawValue)
    }

    // MARK: Search Experience

    private func startSearchExperience(with searchTerm: String) {
        let coverVC = CoreHostingController(
            SearchDisplayContainerView(
                ofInfoType: Info.self,
                router: router,
                descriptor: searchDescriptor,
                searchText: searchTerm,
                filter: selectedFilter
            )
            .environment(Info.environmentKeyPath, searchContext)
        )

        if let contextColor = searchContext.navBarColor {
            coverVC.navigationBarStyle = .color(contextColor)
        }

        let splitView = CoreSplitViewController()
        let containerNav = CoreNavigationController(rootViewController: coverVC)
        containerNav.delegate = self

        splitView.viewControllers = [
            containerNav,
            CoreNavigationController(rootViewController: EmptyViewController())
        ]

        splitView.modalTransitionStyle = .crossDissolve

        router.show(
            splitView,
            from: self,
            options: .modal(.overFullScreen, animated: true),
            completion: { [weak self] in
                self?.hideSearchField()
            }
        )
    }

    // MARK: Delegate Methods

    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
        searchContext.searchText.send("")
        return true
    }

    public func textFieldDidEndEditing(_ textField: UITextField) {
        searchContext.searchText.send(textField.text ?? "")
    }

    public  func textField(_ textField: UITextField,
                           shouldChangeCharactersIn range: NSRange,
                           replacementString string: String) -> Bool {
        let newValue = NSString(string: textField.text ?? "").replacingCharacters(in: range, with: string)
        searchContext.searchText.send(newValue)
        return true
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        let searchTerm = textField.text ?? ""
        guard searchTerm.isSearchValid else { return false }

        searchContext.didSubmit.send(searchTerm)
        startSearchExperience(with: searchTerm)
        return true
    }

    public func navigationController(
        _ navigationController: UINavigationController,
        willShow viewController: UIViewController,
        animated: Bool
    ) {
        let backItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)
        viewController.navigationItem.backBarButtonItem = backItem
    }
}

// MARK: - Base View

public struct SearchHostingBaseView<Info: SearchContextInfo, Content: View>: View {
    public var content: Content
    let searchContext: CoreSearchContext<Info>

    public var body: some View {
        content.environment(Info.environmentKeyPath, searchContext)
    }
}

// MARK: - Transitions

private enum NavBarTransition: String {
    case fadeIn
    case fadeOut

    var caTransition: CATransition {
        switch self {
        case .fadeIn:

            let fade = CATransition()
            fade.duration = 0.2
            fade.timingFunction = CAMediaTimingFunction(name: .easeIn)
            fade.type = .fade
            return fade

        case .fadeOut:

            let fade = CATransition()
            fade.duration = 0.2
            fade.timingFunction = CAMediaTimingFunction(name: .easeOut)
            fade.type = .fade
            return fade
        }
    }
}
