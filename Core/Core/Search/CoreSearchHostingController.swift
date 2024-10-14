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
public class CoreSearchHostingController<Content: View, SearchDisplay: View, Support: SearchSupportAction>:
    CoreHostingController<SearchHostingBaseView<Content>>,
    CoreSearchController {
    @MainActor required dynamic init?(coder aDecoder: NSCoder) { nil }

    private let searchContext: CoreSearchContext
    private let router: Router
    private let support: SearchSupportOption<Support>?
    private let display: CoreSearchDisplayProvider<SearchDisplay>
    private var leftItems: [UIBarButtonItem]?
    private lazy var feedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)

    public init(
        router: Router = AppEnvironment.shared.router,
        context: Context,
        color: UIColor?,
        support: SearchSupportOption<Support>?,
        content: Content,
        display: @escaping CoreSearchDisplayProvider<SearchDisplay>
    ) {
        self.searchContext = CoreSearchContext(context: context, color: color)
        self.router = router
        self.support = support
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
        navigationItem.rightBarButtonItems = [searchBarItem()]

        applyNavBarTransition(.fadeOut)
    }

    public func showSearchField() {
        searchContext.reset()

        let searchView = UISearchField(
            frame: CGRect(
                origin: .zero,
                size: CGSize(width: CGFloat.greatestFiniteMagnitude, height: .greatestFiniteMagnitude)
            )
        )

        searchView.field.placeholder = String(localized: "Search in this course", bundle: .core)
        searchView.field.clearButtonColor = searchContext.color ?? .secondaryLabel
        searchView.field.text = searchContext.searchText.value
        searchView.field.delegate = self

        navigationItem.leftBarButtonItems = []
        navigationItem.hidesBackButton = true
        navigationItem.titleView = searchView
        navigationItem.rightBarButtonItems = [
            closeBarItem(),
            supportBarItem()
        ].compactMap({ $0 })

        applyNavBarTransition(.fadeIn)
        searchView.field.becomeFirstResponder()
    }

    func searchBarItem() -> UIBarButtonItem {
        UIBarButtonItem(
            systemItem: .search,
            primaryAction: UIAction(
                handler: { [weak self] _ in
                    self?.showSearchField()
                }
            )
        )
    }

    func closeBarItem() -> UIBarButtonItem {
        UIBarButtonItem(
            image: .xLine,
            primaryAction: UIAction(
                handler: { [weak self] _ in
                    self?.hideSearchField()
                }
            )
        )
        .with({ $0.tintColor = .white })
    }

    func supportBarItem() -> UIBarButtonItem? {
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
        .with({ $0.tintColor = .white })
    }

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
        searchContext.didSubmit.send(textField.text ?? "")

        startSearchExperience(with: searchTerm) { [weak self] in
            self?.hideSearchField()
        }

        return true
    }

    // MARK: Search Experience

    private func startSearchExperience(with searchTerm: String, completion: @escaping () -> Void) {
        feedbackGenerator.impactOccurred()

        let coverVC = CoreHostingController(
            SearchDisplayContainerView(
                searchText: searchTerm,
                support: support,
                display: display
            )
            .environment(\.searchContext, searchContext)
        )

        if let contextColor = searchContext.color {
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
            completion: completion
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
}

// MARK: - Convenience Initializer

extension CoreSearchHostingController where Support == NoSearchSupportAction {
    public convenience init(
        router: Router = AppEnvironment.shared.router,
        context: Context,
        color: UIColor?,
        content: Content,
        display: @escaping CoreSearchDisplayProvider<SearchDisplay>
    ) {
        self.init(
            router: router,
            context: context,
            color: color,
            support: nil,
            content: content,
            display: display
        )
    }
}

// MARK: - Base View

public struct SearchHostingBaseView<Content: View>: View {
    public var content: Content
    let searchContext: CoreSearchContext

    public var body: some View {
        content.environment(\.searchContext, searchContext)
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
