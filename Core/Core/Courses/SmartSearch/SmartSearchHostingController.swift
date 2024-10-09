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

public struct SupportAction {
    let action: (Router, SmartSearchController) -> Void
    let icon: () -> UIImage?

    public init(action: @escaping (Router, SmartSearchController) -> Void,
                icon: @escaping () -> UIImage?) {
        self.action = action
        self.icon = icon
    }
}

public protocol SmartSearchController: UIViewController, UITextFieldDelegate {
    func showSearchField()
    func hideSearchField()
}

public class SmartSearchHostingController<Content: View, SearchDisplay: View>:
    CoreHostingController<SearchHostingBaseView<Content>>,
    SmartSearchController {
    @MainActor required dynamic init?(coder aDecoder: NSCoder) { nil }

    let searchContext: SmartSearchContext
    let router: Router
    let support: SupportAction?
    let display: () -> SearchDisplay

    private var leftItems: [UIBarButtonItem]?

    public init(
        router: Router = AppEnvironment.shared.router,
        context: Context,
        color: UIColor?,
        support: SupportAction? = nil,
        content: Content,
        display: @escaping () -> SearchDisplay
    ) {
        self.searchContext = SmartSearchContext(context: context, color: color)
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
            supportBarItem(),
            closeBarItem()
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
            image: support.icon(),
            primaryAction: UIAction(
                handler: { [weak self] _ in
                    guard let self else { return }
                    support.action(self.router, self)
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
                details: display
            )
            .environment(\.smartSearchContext, searchContext)
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

    var didSubmit = PassthroughSubject<String, Never>()
    var searchTerm = CurrentValueSubject<String, Never>("")

    private var store = Set<AnyCancellable>()
    weak var controller: SmartSearchController?

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

// MARK: -

struct SearchableContainerView<Details: View>: View {

    @Environment(\.appEnvironment) private var env
    @Environment(\.viewController) private var controller
    @Environment(\.smartSearchContext) private var searchContext

    @State var searchText: String

    let detailsContent: () -> Details

    init(searchText: String, details: @escaping () -> Details) {
        self.detailsContent = details
        self._searchText = State(initialValue: searchText)
    }

    var body: some View {
        detailsContent()
            .environment(\.smartSearchContext, searchContext)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Results")
            .toolbar {

                ToolbarItem(placement: .principal) {
                    SearchTextField(text: $searchText) {
                        print("search submit")
                        searchContext.didSubmit.send(searchText)
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

struct SearchTextField: View {

    @FocusState var isFocused: Bool
    @Binding var text: String

    let onSubmit: () -> Void

    init(text: Binding<String>, isFocused: FocusState<Bool>? = nil, onSubmit: @escaping () -> Void) {
        self._text = text
        self.onSubmit = onSubmit

        if let state = isFocused {
            self._isFocused = state
        }
    }

    @State var minWidth = DeferredValue<CGFloat?>(value: nil)

    var body: some View {
        HStack(spacing: 0) {
            Image(systemName: "magnifyingglass")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize()

            Spacer(minLength: 5)

            TextField("Search in this course", text: $text)
                .focused($isFocused)
                .font(.subheadline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .onSubmit {
                    minWidth.update()
                    onSubmit()
                }
            
            if text.isEmpty == false {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(Color.pink)
                }
                .fixedSize()
            }
        }
        .padding(.horizontal, 10)
        .background(Color.white)
        .clipShape(Capsule())
        .shadow(radius: 2, y: 2)
        .frame(idealWidth: minWidth.value, maxWidth: .infinity)
        .measuringSize { size in
            minWidth.deferred = size.width
        }
        .onDisappear {
            // This is to resolve issue of field size when pushing to result details
            minWidth.update()
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
