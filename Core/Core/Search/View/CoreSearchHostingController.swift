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

public protocol CoreSearchController: UIViewController,
                                        UITextFieldDelegate,
                                        UINavigationControllerDelegate,
                                        UISplitViewControllerDelegate {}

public class CoreSearchHostingController<
        Attributes: SearchViewAttributes,
        ViewsProvider: SearchViewsProvider,
        Interactor: SearchInteractor,
        Content: View
    >: CoreHostingController<SearchHostingBaseView<Attributes, Content>>, CoreSearchController {

    private enum SearchFieldState { case visible, hidden, removed }
    private let minSearchTermLength: Int = 2

    let searchContext: SearchViewContext<Attributes>
    let searchViewsProvider: ViewsProvider
    let searchInteractor: Interactor
    private let router: Router

    private(set) var selectedFilter: ViewsProvider.Filter?
    private var leftBarButtonItemsToRestore: [UIBarButtonItem]?

    private var searchFieldState: SearchFieldState = .removed
    private var subscriptions: Set<AnyCancellable> = []

    // MARK: Bar Button Items

    private lazy var searchBarItem = UIBarButtonItem(
        image: .smartSearchLine,
        primaryAction: UIAction(
            handler: { [weak self] _ in
                self?.showSearchBar()
            }
        )
    ).with { $0.accessibilityIdentifier = "search_bar_button" }

    private lazy var closeBarItem = UIBarButtonItem(
        image: .xLine,
        primaryAction: UIAction(
            handler: { [weak self] _ in
                self?.hideSearchBarAndShowSearchButton()
            }
        )
    ).with {
        $0.tintColor = .textLightest
        $0.accessibilityIdentifier = "close_bar_button"
    }

    private lazy var filterBarItem = UIBarButtonItem(
        image: .filterLine,
        primaryAction: UIAction(
            handler: { [weak self] _ in
                self?.showFilterEditor()
            }
        )
    ).with {
        $0.tintColor = .textLightest
        $0.accessibilityIdentifier = "filter_bar_button"
    }

    private lazy var supportBarItem: UIBarButtonItem? = {
        guard let support = searchViewsProvider.supportButtonModel else { return nil }
        return UIBarButtonItem(
            image: support.icon.uiImage(),
            primaryAction: UIAction(
                handler: { [weak self] _ in
                    guard let self else { return }
                    support.action
                        .trigger(for: self.searchContext, with: self.router, from: self)
                }
            )
        )
        .with {
            $0.tintColor = .textLightest
            $0.accessibilityIdentifier = "support_bar_button"
        }
    }()

    private lazy var searchFieldView: UISearchField = {
        let searchView = UISearchField()
        searchView.field.placeholder = searchContext.searchPrompt
        searchView.field.accessibilityIdentifier = "ui_search_field"
        searchView.field.delegate = self

        if let clearColor = searchContext.accentColor {
            searchView.field.clearButtonColor = clearColor
        }
        return searchView
    }()

    // MARK: Initialization & Setup

    public init(
        router: Router = AppEnvironment.shared.router,
        attributes: Attributes,
        provider: ViewsProvider,
        interactor: Interactor,
        content: Content
    ) {
        self.router = router
        self.searchContext = SearchViewContext(attributes: attributes)
        self.searchViewsProvider = provider
        self.searchInteractor = interactor

        super.init(SearchHostingBaseView(content: content, searchContext: searchContext))

        if let contextColor = attributes.accentColor {
            navigationBarStyle = .color(contextColor)
        }
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) { nil }

    public override func viewDidLoad() {
        super.viewDidLoad()
        leftBarButtonItemsToRestore = navigationItem.leftBarButtonItems

        searchInteractor
            .isEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEnabled in
                self?.setupOrRemoveSearchBar(isEnabled)
            }
            .store(in: &subscriptions)
    }

    private func setupOrRemoveSearchBar(_ isSearchEnabled: Bool) {
        if isSearchEnabled == (searchFieldState != .removed) { return }
        if isSearchEnabled {
            hideSearchBarAndShowSearchButton()
        } else {
            removeSearchBarAndButton()
        }
    }

    // MARK: Show/Hide Search Bar

    private func showSearchBar() {
        selectedFilter = nil
        filterBarItem.image = .filterLine

        searchFieldView.field.text = searchContext.searchText.value
        searchFieldView.frame.size = CGSize(
            width: CGFloat.greatestFiniteMagnitude,
            height: CGFloat.greatestFiniteMagnitude
        )

        navigationItem.leftBarButtonItems = [closeBarItem]
        navigationItem.hidesBackButton = true
        navigationItem.titleView = searchFieldView
        navigationItem.rightBarButtonItems = [
            supportBarItem,
            filterBarItem
        ].compactMap({ $0 })

        searchFieldState = .visible
        applyNavBarTransition(.fadeIn)
        searchFieldView.field.becomeFirstResponder()
    }

    private func hideSearchBarAndShowSearchButton() {
        navigationItem.titleView = nil
        navigationItem.hidesBackButton = false
        navigationItem.leftBarButtonItems = leftBarButtonItemsToRestore
        navigationItem.rightBarButtonItems = [searchBarItem]

        searchFieldState = .hidden
        applyNavBarTransition(.fadeOut)
    }

    private func removeSearchBarAndButton() {
        navigationItem.titleView = nil
        navigationItem.hidesBackButton = false
        navigationItem.leftBarButtonItems = leftBarButtonItemsToRestore
        navigationItem.rightBarButtonItems = nil
        searchFieldState = .removed
    }

    private func applyNavBarTransition(_ transition: NavBarTransition) {
        navigationController?.navigationBar.layer
            .add(transition.caTransition, forKey: transition.rawValue)
    }

    // MARK: Search Experience

    private func startSearchExperience(with searchTerm: String) {
        let coverVC = CoreHostingController(
            SearchContentContainerView(
                ofAttributesType: Attributes.self,
                router: router,
                provider: searchViewsProvider,
                searchText: searchTerm,
                filter: selectedFilter
            )
            .environment(Attributes.Environment.keyPath, searchContext)
        )

        if let contextColor = searchContext.accentColor {
            coverVC.navigationBarStyle = .color(contextColor)
        }

        let splitView = CoreSplitViewController()
        let containerNav = CoreNavigationController(rootViewController: coverVC)
        containerNav.delegate = self

        splitView.delegate = self
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
                self?.hideSearchBarAndShowSearchButton()
            }
        )
    }

    private func showFilterEditor() {

        let filter: Binding<ViewsProvider.Filter?> = Binding { [ weak self] in
            self?.selectedFilter
        } set: { [weak self] newFilter in
            guard let self else { return }
            selectedFilter = newFilter
            filterBarItem.image = (newFilter?.isActive ?? false) ? .filterSolid : .filterLine
        }

        let filterEditorVC = CoreHostingController(
            searchViewsProvider
                .filterEditorView(filter)
                .environment(Attributes.Environment.keyPath, searchContext)
        )
        filterEditorVC.view.accessibilityIdentifier = "filter_editor_view"
        router.show(filterEditorVC, from: self, options: .modal(.formSheet, animated: true))
    }

    // MARK: Delegate Methods

    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
        searchContext.searchText.send("")
        return true
    }

    public func textFieldDidEndEditing(_ textField: UITextField) {
        searchContext.searchText.send(textField.text ?? "")
    }

    public  func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        let newValue = NSString(string: textField.text ?? "").replacingCharacters(in: range, with: string)
        searchContext.searchText.send(newValue)
        return true
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        let searchTerm = textField.text ?? ""
        let isSearchTermValid = searchTerm.count >= minSearchTermLength
        guard isSearchTermValid else { return false }

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

public struct SearchHostingBaseView<Attributes: SearchViewAttributes, Content: View>: View {
    let content: Content
    let searchContext: SearchViewContext<Attributes>

    public var body: some View {
        content.environment(Attributes.Environment.keyPath, searchContext)
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
