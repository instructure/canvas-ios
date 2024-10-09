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

public protocol CoreSearchController: UIViewController, UITextFieldDelegate {}
public class CoreSearchHostingController<Content: View, SearchDisplay: View, Support: SearchSupportAction>:
    CoreHostingController<SearchHostingBaseView<Content>>,
    CoreSearchController {
    @MainActor required dynamic init?(coder aDecoder: NSCoder) { nil }

    let searchContext: CoreSearchContext
    let router: Router
    let support: SearchSupportOption<Support>?
    let display: CoreSearchDisplayProvider<SearchDisplay>

    private var leftItems: [UIBarButtonItem]?

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

    @objc func didTapBack() {
        router.dismiss(self)
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
        searchContext.searchTerm.send("")
    }

    public func showSearchField() {
        let searchView = UISearchField(
            frame: CGRect(
                origin: .zero,
                size: CGSize(width: CGFloat.greatestFiniteMagnitude, height: .greatestFiniteMagnitude)
            )
        )

        searchView.field.text = searchContext.searchTerm.value
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

    private var symbolConfig: UIImage.SymbolConfiguration {
        return UIImage.SymbolConfiguration(textStyle: .subheadline)
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
            image: UIImage(systemName: "xmark", withConfiguration: symbolConfig),
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
        searchContext.searchTerm.send("")
        return true
    }

    public func textFieldDidEndEditing(_ textField: UITextField) {
        searchContext.searchTerm.send(textField.text ?? "")
    }

    public  func textField(_ textField: UITextField,
                           shouldChangeCharactersIn range: NSRange,
                           replacementString string: String) -> Bool {
        let newValue = NSString(string: textField.text ?? "").replacingCharacters(in: range, with: string)
        searchContext.searchTerm.send(newValue)
        return true
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        let searchTerm = textField.text ?? ""
        searchContext.didSubmit.send(textField.text ?? "")

        let coverVC = CoreHostingController(
            SearchableContainerView(
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
        splitView.viewControllers = [
            CoreNavigationController(rootViewController: coverVC),
            CoreNavigationController(rootViewController: EmptyViewController())
        ]

        splitView.modalTransitionStyle = .crossDissolve

        router.show(
            splitView,
            from: self,
            options: .modal(.overFullScreen, animated: true)) { [weak self] in
                self?.hideSearchField()
            }

        return true
    }
}

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

// MARK: - Environment

public struct SearchHostingBaseView<Content: View>: View {
    public var content: Content
    let searchContext: CoreSearchContext

    public var body: some View {
        content
            .environment(\.searchContext, searchContext)
    }
}

// MARK: - Container

public enum SearchPhase {
    case start
    case loading
    case noMatch
    case results
    case filteredResults
}

public struct FiltersState {
    public static var empty = FiltersState(isPresented: false, isActive: false)

    public var isPresented: Bool
    public var isActive: Bool

    public init(isPresented: Bool, isActive: Bool) {
        self.isPresented = isPresented
        self.isActive = isActive
    }
}

public typealias CoreSearchDisplayProvider<Display: View> = (Binding<SearchPhase>, Binding<FiltersState>) -> Display
public struct SearchableContainerView<Display: View, Action: SearchSupportAction>: View {

    @Environment(\.appEnvironment) private var env
    @Environment(\.viewController) private var controller
    @Environment(\.searchContext) private var searchContext

    @State var searchText: String
    @State var phase: SearchPhase = .start
    @State var filters: FiltersState = .empty

    let displayContent: CoreSearchDisplayProvider<Display>
    let support: SearchSupportOption<Action>?

    init(searchText: String, support: SearchSupportOption<Action>?, display: @escaping CoreSearchDisplayProvider<Display>) {
        self.displayContent = display
        self.support = support
        self._searchText = State(initialValue: searchText)
    }

    public var body: some View {
        displayContent($phase, $filters)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Results")
            .toolbar {

                ToolbarItem(placement: .principal) {
                    SearchTextField(text: $searchText) {
                        print("search submit")
                        searchContext.didSubmit.send(searchText)
                    }
                }

                if phase != .loading {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            filters.isPresented = true
                        } label: {
                            if filters.isActive {
                                Image.filterSolid
                            } else {
                                Image.filterLine
                            }
                        }
                        .tint(.white)
                    }
                }

                if let support {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            support.action.triggered(with: env.router, from: controller.value)
                        } label: {
                            support.icon.image()
                        }
                        .tint(.white)
                    }
                }

                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        env.router.dismiss(controller.value)
                    } label: {
                        Image(systemName: "chevron.backward")
                    }
                    .tint(.white)
                }
            }
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
