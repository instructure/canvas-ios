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

public protocol CoreSearchController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate {}
public class CoreSearchHostingController<
    Info: SearchContextInfo, Filter, Content: View, Display: View, FilterEditor: View, Support: SearchSupportAction
>: CoreHostingController<SearchHostingBaseView<Info, Content>>,
   CoreSearchController {
    @MainActor required dynamic init?(coder aDecoder: NSCoder) { nil }

    private let searchContext: CoreSearchContext<Info>
    private let router: Router
    private let support: SearchSupportOption<Support>?
    private let display: SearchDisplayProvider<Filter, Display>
    private let filterEditor: SearchFilterEditorProvider<Filter, FilterEditor>

    private var leftItems: [UIBarButtonItem]?

    public init(
        router: Router = AppEnvironment.shared.router,
        info: Info,
        support: SearchSupportOption<Support>?,
        content: Content,
        filterEditor: @escaping SearchFilterEditorProvider<Filter, FilterEditor>,
        display: @escaping SearchDisplayProvider<Filter, Display>
    ) {
        self.searchContext = CoreSearchContext(info: info)
        self.router = router
        self.support = support
        self.filterEditor = filterEditor
        self.display = display
        super.init(SearchHostingBaseView(content: content, searchContext: searchContext))
        self.searchContext.controller = self
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        leftItems = navigationItem.leftBarButtonItems
        hideSearchField()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        hideSearchField()
    }

    public func hideSearchField() {
        navigationItem.titleView = nil
        navigationItem.hidesBackButton = false
        navigationItem.leftBarButtonItems = leftItems
        navigationItem.rightBarButtonItems = [searchBarItem]

        applyNavBarTransition(.fadeOut)
    }

    public func showSearchField() {
        selectedFilter = nil
        filterBarItem.image = .filterLine
        searchContext.reset()

        let searchView = UISearchField(
            frame: CGRect(
                origin: .zero,
                size: CGSize(width: CGFloat.greatestFiniteMagnitude, height: .greatestFiniteMagnitude)
            )
        )

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

        applyNavBarTransition(.fadeIn)
        searchView.field.becomeFirstResponder()
    }

    // MARK: Bar Button Items

    private lazy var searchBarItem = UIBarButtonItem(
        systemItem: .search,
        primaryAction: UIAction(
            handler: { [weak self] _ in
                self?.showSearchField()
            }
        )
    )

    private lazy var closeBarItem = UIBarButtonItem(
        image: .xLine,
        primaryAction: UIAction(
            handler: { [weak self] _ in
                self?.hideSearchField()
            }
        )
    ).with({ $0.tintColor = .textLightest })

    private lazy var filterBarItem = UIBarButtonItem(
        image: .filterLine,
        primaryAction: UIAction(
            handler: { [weak self] _ in
                self?.showFilterEditor()
            }
        )
    ).with({ $0.tintColor = .textLightest })

    private lazy var supportBarItem: UIBarButtonItem? = {
        guard let support else { return nil }
        return UIBarButtonItem(
            image: support.icon.uiImage(),
            primaryAction: UIAction(
                handler: { [weak self] _ in
                    guard let self else { return }
                    support.action.triggered(with: self.router, from: self)
                }
            )
        )
        .with({ $0.tintColor = .textLightest })
    }()

    private func applyNavBarTransition(_ transition: NavBarTransition) {
        navigationController?
            .navigationBar
            .layer
            .add(transition.caTransition, forKey: transition.rawValue)
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

    // MARK: Search Experience

    private func startSearchExperience(with searchTerm: String) {
        let coverVC = CoreHostingController(
            SearchDisplayContainerView(
                of: Info.self,
                searchText: searchTerm,
                support: support,
                filter: selectedFilter,
                filterEditor: filterEditor,
                display: display
            )
            .environment(Info.environmentKeyPath, searchContext)
        )

        if let contextColor = searchContext.navBarColor {
            coverVC.navigationBarStyle = .color(contextColor)
        }

        let splitView = CoreSplitViewController()
        let containeNav = CoreNavigationController(rootViewController: coverVC)
        containeNav.delegate = self

        splitView.viewControllers = [
            containeNav,
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

    public func navigationController(
        _ navigationController: UINavigationController,
        willShow viewController: UIViewController,
        animated: Bool
    ) {
        let backItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)
        viewController.navigationItem.backBarButtonItem = backItem
    }

    private var selectedFilter: Filter?

    private func showFilterEditor() {

        let filter: Binding<Filter?> = Binding { [ weak self] in
            self?.selectedFilter
        } set: { [weak self] newFilter in
            guard let self else { return }
            selectedFilter = newFilter
            filterBarItem.image = newFilter != nil ? .filterSolid : .filterLine
        }

        let filterEditorVC = CoreHostingController(
            filterEditor(filter).environment(Info.environmentKeyPath, searchContext)
        )

        router.show(filterEditorVC, from: self, options: .modal(.formSheet, animated: true))
    }
}

// MARK: - Convenience Initializer

extension CoreSearchHostingController where Support == NoSearchSupportAction {
    public convenience init(
        router: Router = AppEnvironment.shared.router,
        info: Info,
        content: Content,
        filterEditor: @escaping SearchDisplayProvider<Filter, FilterEditor>,
        display: @escaping SearchDisplayProvider<Filter, Display>
    ) {
        self.init(
            router: router,
            info: info,
            support: nil,
            content: content,
            filterEditor: filterEditor,
            display: display
        )
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
