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

public enum SmartSearchMode {
    case intro
    case loading
    case noMatch
    case results

    var closable: Bool {
        switch self {
        case .intro:
            return true
        case .loading, .noMatch, .results:
            return false
        }
    }

    var backable: Bool {
        switch self {
        case .intro:
            return false
        case .loading, .noMatch, .results:
            return true
        }
    }

    var autoFocus: Bool {
        return self == .intro
    }
}

public protocol SmartSearchController: UIViewController, UITextFieldDelegate {
    func showInitialState()
}

public class SmartSearchHostingController<Content: View>: CoreHostingController<SearchHostingBaseView<Content>>, SmartSearchController {
    @MainActor required dynamic init?(coder aDecoder: NSCoder) { nil }

    let searchContext: SmartSearchContext
    let router: Router

    private var leftItems: [UIBarButtonItem]?
    private var closed: Bool = true

    public init(context: SmartSearchContext, router: Router, content: Content) {
        self.searchContext = context
        self.router = router
        super.init(SearchHostingBaseView(content: content, searchContext: searchContext))
        self.searchContext.controller = self
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        leftItems = navigationItem.leftBarButtonItems

        self.navigationItem.leftBarButtonItems = []
        self.navigationItem.hidesBackButton = true
        self.navigationItem.backBarButtonItem = nil
        self.navigationItem.backButtonTitle = nil

        print("did load")
    }

    // Resolving issue of search field to extend over left items
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        closed = true
        showInitialState()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        closed = true
        showInitialState(loose: true)
    }

    public func showInitialState() {
        showInitialState(loose: false)
    }

    private func showInitialState(loose: Bool = false) {
        if searchContext.mode.closable, closed {
            showClosedState()
        } else {
            showOpenedState(loose: loose)
        }
    }

    func showClosedState() {
        navigationItem.titleView = nil
        navigationItem.hidesBackButton = false
        navigationItem.leftBarButtonItems = leftItems
        navigationItem.rightBarButtonItems = [
            searchBarItem()
        ]

        applyNavBarTransition(.fadeOut)
        searchContext.searchTerm = ""
        closed = true
    }

    

    func showOpenedState(loose: Bool = false) {
        let searchView = SearchField(
            frame: CGRect(
                origin: .zero,
                size: CGSize(width: CGFloat.greatestFiniteMagnitude, height: .greatestFiniteMagnitude)
            )
        )

        searchView.field.text = searchContext.searchTerm
        searchView.field.delegate = self

        if !loose {
            navigationItem.leftBarButtonItems = searchContext.mode.backable ? leftItems : []
            navigationItem.hidesBackButton = searchContext.mode.backable == false
        }

        navigationItem.titleView = searchView
        navigationItem.setRightBarButtonItems(trailingItems(), animated: true)

        if !loose { applyNavBarTransition(.fadeIn) }
        closed = false

        if searchContext.mode.autoFocus, !loose {
            searchView.field.becomeFirstResponder()
        }
    }

    private var symbolConfig: UIImage.SymbolConfiguration {
        return UIImage.SymbolConfiguration(textStyle: .subheadline)
    }

    func trailingItems() -> [UIBarButtonItem] {
        switch searchContext.mode {
        case .intro:
            return [
                closeBarItem(),
                helpBarItem()
            ]
        case .loading:
            return [
                helpBarItem()
            ]
        case .results, .noMatch:
            return [
                helpBarItem(),
                filterBarItem()
            ]
        }
    }

    func searchBarItem() -> UIBarButtonItem {
        UIBarButtonItem(
            systemItem: .search,
            primaryAction: UIAction(
                handler: { [weak self] _ in
                    self?.showOpenedState()
                }
            )
        )
    }

    func filterBarItem() -> UIBarButtonItem {
        UIBarButtonItem(
            image: UIImage(systemName: "line.3.horizontal.decrease.circle", withConfiguration: symbolConfig),
            primaryAction: UIAction(
                handler: { [weak self] _ in
                    self?.showFiltersSheet()
                }
            )
        )
        .with({ $0.tintColor = .white })
    }

    func closeBarItem() -> UIBarButtonItem {
        UIBarButtonItem(
            image: UIImage(systemName: "xmark", withConfiguration: symbolConfig),
            primaryAction: UIAction(
                handler: { [weak self] _ in
                    self?.showClosedState()
                }
            )
        )
        .with({ $0.tintColor = .white })
    }

    func helpBarItem() -> UIBarButtonItem {
        UIBarButtonItem(
            image: UIImage(systemName: "questionmark.circle", withConfiguration: symbolConfig),
            primaryAction: UIAction(
                handler: { [weak self] _ in
                    self?.showHelpSheet()
                }
            )
        )
        .with({ $0.tintColor = .white })
    }

    private func showFiltersSheet() {
        print("show filters sheet")
    }

    private func showHelpSheet() {
        router.show(
            CoreHostingController(SmartSearchHelpView()),
            from: self,
            options: .modal(.formSheet)
        )
    }

    private func applyNavBarTransition(_ transition: NavBarTransition) {
        navigationController?
            .navigationBar
            .layer
            .add(transition.caTransition, forKey: transition.rawValue)
    }

    // MARK: Delegate Methods

    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
        searchContext.searchTerm = ""
        return true
    }

    public func textFieldDidEndEditing(_ textField: UITextField) {
        searchContext.searchTerm = textField.text ?? ""
    }

    public  func textField(_ textField: UITextField,
                           shouldChangeCharactersIn range: NSRange,
                           replacementString string: String) -> Bool {
        let newValue = NSString(string: textField.text ?? "").replacingCharacters(in: range, with: string)
        searchContext.searchTerm = newValue
        return true
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        searchContext.didSubmit.send(textField.text ?? "")
        return true
    }
}

// MARK: - Environment

public struct SearchHostingBaseView<Content: View>: View {
    public var content: Content
    let searchContext: SmartSearchContext

    public var body: some View {
        content
            .environment(\.smartSearchContext, searchContext)
    }
}

public class SmartSearchContext: EnvironmentKey, ObservableObject {
    let context: Context
    let color: UIColor?

    var mode: SmartSearchMode = .intro {
        didSet {
            self.controller?.showInitialState()
        }
    }

    @Published var searchTerm: String = ""

    var didSubmit = PassthroughSubject<String, Never>()

    private var store = Set<AnyCancellable>()
    fileprivate weak var controller: SmartSearchController?

    public init(context: Context, color: UIColor?, mode: SmartSearchMode) {
        self.context = context
        self.color = color
        self.mode = mode
    }

    public static var defaultValue = SmartSearchContext(context: .currentUser, color: nil, mode: .intro)
}

extension EnvironmentValues {

    var smartSearchContext: SmartSearchContext {
        get { self[SmartSearchContext.self] }
        set {
            self[SmartSearchContext.self] = newValue
        }
    }
}

// MARK: - Subviews

class RoundedView: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = min(frame.height, frame.width) * 0.5
    }
}

private class SearchField: UIView {
    required init?(coder: NSCoder) { nil }

    let field = UITextField()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setContentHuggingPriority(.defaultLow, for: .horizontal)
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard subviews.isEmpty else { return }

        let container = RoundedView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .systemBackground
        addSubview(container)

        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            container.centerYAnchor.constraint(equalTo: centerYAnchor).with({ $0.priority = .defaultHigh }),
            container.topAnchor.constraint(greaterThanOrEqualTo: topAnchor),
            container.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor)
        ])

        let config = UIImage.SymbolConfiguration(textStyle: .caption1)
        let icon = UIImageView(
            image: UIImage(systemName: "magnifyingglass")?.applyingSymbolConfiguration(config)
        )
        icon.tintColor = .secondaryLabel
        icon.contentMode = .center
        icon.setContentHuggingPriority(.required, for: .horizontal)

        field.placeholder = "Enter text here"
        field.translatesAutoresizingMaskIntoConstraints = false
        field.setContentHuggingPriority(.defaultLow, for: .horizontal)
        field.clearButtonMode = .always
        field.font = .preferredFont(forTextStyle: .subheadline)
        field.returnKeyType = .search
        field.tintColor = .blue // caret color

        let stack = UIStackView(arrangedSubviews: [icon, field])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.spacing = 10

        container.addSubview(stack)
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.2
        container.layer.shadowRadius = 2
        container.layer.shadowOffset = CGSize(width: 0, height: 2)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 10),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -10),
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 7.5),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -7.5)
        ])
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

// MARK: - Helpers

protocol Customizable: AnyObject { }
extension NSObject: Customizable { }

extension Customizable {
    func with(_ block: (Self) -> Void) -> Self  {
        block(self)
        return self
    }
}
