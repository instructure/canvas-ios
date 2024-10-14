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
    }

    public func showSearchField() {
        searchContext.reset()

        let searchView = UISearchField(
            frame: CGRect(
                origin: .zero,
                size: CGSize(width: CGFloat.greatestFiniteMagnitude, height: .greatestFiniteMagnitude)
            )
        )

        searchView.field.clearButtonColor = searchContext.color ?? .secondaryLabel
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

        startSearchExperience(with: searchTerm) { [weak self] in
            self?.hideSearchField()
        }

        return true
    }

    // MARK: Search Experience

    private func startSearchExperience(with searchTerm: String, completion: @escaping () -> Void) {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()

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

public struct SearchDisplayState {
    public static var empty = SearchDisplayState(isLoading: false, isPresented: false, isActive: false)

    public var isLoading: Bool
    public var isFiltersPresented: Bool
    public var isFiltersActive: Bool

    public init(isLoading: Bool, isPresented: Bool, isActive: Bool) {
        self.isLoading = isPresented
        self.isFiltersPresented = isPresented
        self.isFiltersActive = isActive
    }
}

public typealias CoreSearchDisplayProvider<Display: View> = (Binding<SearchDisplayState>) -> Display
public struct SearchableContainerView<Display: View, Action: SearchSupportAction>: View {

    @Environment(\.appEnvironment) private var env
    @Environment(\.viewController) private var controller
    @Environment(\.searchContext) private var searchContext

    @State var searchText: String
    @State var displayState: SearchDisplayState = .empty

    let displayContent: CoreSearchDisplayProvider<Display>
    let support: SearchSupportOption<Action>?

    init(searchText: String, support: SearchSupportOption<Action>?, display: @escaping CoreSearchDisplayProvider<Display>) {
        self.displayContent = display
        self.support = support
        self._searchText = State(initialValue: searchText)
    }

    public var body: some View {
        displayContent($displayState)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {

                ToolbarItem(placement: .principal) {
                    SearchTextField(
                        text: $searchText,
                        clearButtonColor: clearButtonColor
                    ) {
                        print("search submit")
                        searchContext.didSubmit.send(searchText)
                    }
                }

                if displayState.isLoading == false {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            displayState.isFiltersPresented = true
                        } label: {
                            if displayState.isFiltersActive {
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
            .onChange(of: searchText) { newValue in
                searchContext.searchTerm.send(newValue)
            }
    }

    private var clearButtonColor: Color {
        return searchContext.color.flatMap({ Color(uiColor: $0) }) ?? .secondary
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
