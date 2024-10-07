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
}

public class SmartSearchHostingController<Content: View>: CoreHostingController<SearchHostingBaseView<Content>>, UITextFieldDelegate {
    @MainActor required dynamic init?(coder aDecoder: NSCoder) { nil }

    let searchContext: SmartSearchContext
    let router: Router

    private var leftItems: [UIBarButtonItem]?

    public init(context: Context, color: UIColor?, mode: SmartSearchMode, router: Router, content: Content) {
        self.searchContext = SmartSearchContext(context: context, color: color)
        self.router = router
        super.init(SearchHostingBaseView(content: content, searchContext: searchContext))
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        leftItems = navigationItem.leftBarButtonItems
        dismissSearchItems()
    }

    func dismissSearchItems() {
        navigationItem.titleView = nil
        navigationItem.hidesBackButton = false
        navigationItem.leftBarButtonItems = leftItems
        navigationItem.rightBarButtonItems = [

        ]

        applyNavBarTransition(.fadeOut)
    }

    func resetSearchItems() {
        let searchView = SearchField(
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
            helpBarItem()
        ]

        applyNavBarTransition(.fadeIn)
    }

    func searchBarItem() -> UIBarButtonItem {
        UIBarButtonItem(
            systemItem: .search,
            primaryAction: UIAction(
                handler: { [weak self] _ in
                    self?.resetSearchItems()
                }
            )
        )
    }

    private var symbolConfig: UIImage.SymbolConfiguration {
        return UIImage.SymbolConfiguration(textStyle: .subheadline)
    }

    func filterBarItem() -> UIBarButtonItem {
        UIBarButtonItem(
            image: UIImage(systemName: "line.3.horizontal.decrease.circle", withConfiguration: symbolConfig),
            primaryAction: UIAction(
                handler: { [weak self] _ in
                    self?.showFiltersView()
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
                    self?.dismissSearchItems()
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

    // Resolving issue of search field to extend over left items
    private var didAppear: Bool = false
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard didAppear == false else { return }
        dismissSearchItems()
        didAppear = true
    }

    private func showFiltersSheet() {

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

public class SmartSearchContext: EnvironmentKey {
    let context: Context
    let color: UIColor?

    var searchTerm = CurrentValueSubject<String, Never>("")
    var didSubmit = PassthroughSubject<String, Never>()

    public init(context: Context, color: UIColor?) {
        self.context = context
        self.color = color
    }

    public static var defaultValue = SmartSearchContext(context: .currentUser, color: nil)
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
        container.alpha = 0
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

        field.becomeFirstResponder()

        UIView.animate(withDuration: 0.3) {
            container.alpha = 1
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

// MARK: - Helpers

protocol Customizable: AnyObject { }
extension NSObject: Customizable { }

extension Customizable {
    func with(_ block: (Self) -> Void) -> Self  {
        block(self)
        return self
    }
}
