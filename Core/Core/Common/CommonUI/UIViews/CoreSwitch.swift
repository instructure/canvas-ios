//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

import Combine
import UIKit
import SwiftUI

public class CoreSwitch: UIControl {

    // MARK: - Public Properties

    public var isOn = false {
        didSet {
            toggleViewModel.isOn = isOn
        }
    }
    public override var isEnabled: Bool {
        didSet { toggleViewModel.isEnabled = isEnabled }
    }
    public override var tintColor: UIColor! {
        didSet { toggleViewModel.tintColor = tintColor?.asColor }
    }
    public override var intrinsicContentSize: CGSize {
        CGSize(width: 44, height: 28)
    }
    public override var accessibilityLabel: String? {
        // If we don't return nil here the label will appear duplicated in the automation elements tree.
        get { nil }
        set { toggleViewModel.accessibilityLabel = newValue ?? "" }
    }
    public override var accessibilityIdentifier: String? {
        // If we don't return nil here the id will appear duplicated in the automation elements tree.
        get { nil }
        set { toggleViewModel.accessibilityIdentifier = newValue }
    }

    // MARK: - Private Properties

    private var viewHost: CoreHostingController<AnyView>?
    private let toggleViewModel = ToggleViewModel()
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Public Methods

    public init() {
        super.init(frame: .zero)
        commonSetup()
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonSetup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonSetup()
    }

    public func setOn(_ isOn: Bool, animated: Bool) {
        self.isOn = isOn
    }

    // MARK: - Private Methods

    private func commonSetup() {
        let toggleWrapper = AnyView(ToggleWrapper().environmentObject(toggleViewModel))
        let host = CoreHostingController(toggleWrapper)
        viewHost = host
        host.view.backgroundColor = .clear

        addSubview(host.view)
        host.view.pin(inside: self)

        toggleViewModel
            .$isOn
            .sink { [unowned self] newValue in
                if isOn != newValue {
                    isOn = newValue
                    sendActions(for: .valueChanged)
                }
            }
            .store(in: &subscriptions)
    }
}

/// Since we can't modify the wrapped view once we passed it to the hosting controller
/// we use this model to communicate with the InstUI.Toggle.
private class ToggleViewModel: ObservableObject {
    @Published var isOn = false
    @Published var isEnabled = true
    @Published var tintColor: Color?
    @Published var accessibilityIdentifier: String?
    @Published var accessibilityLabel: String = ""
}

/// The purpose of this view is just to create a SwiftUI environment from where variables can be passed
/// down to the underlying InstUI.Toggle.
private struct ToggleWrapper: View {
    @EnvironmentObject var toggleViewModel: ToggleViewModel

    var body: some View {
        InstUI.Toggle(isOn: $toggleViewModel.isOn) {}
            .environment(\.isEnabled, toggleViewModel.isEnabled)
            .accentColor(toggleViewModel.tintColor)
            .accessibilityLabel(toggleViewModel.accessibilityLabel)
            .identifier(toggleViewModel.accessibilityIdentifier)
            // Voiceover recognizes the toggle's check icon and adds the image trait automatically.
            // If we hide that image from accessibility the whole switch will be inaccessible,
            // so we just remove the image trait.
            .accessibilityRemoveTraits(.isImage)
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    let createSwitchView: () -> CoreSwitch = {
        let result = CoreSwitch(frame: .zero)
        result.tintColor = .course1
        return result
    }
    let enabledOn = createSwitchView()
    enabledOn.isOn = true
    let enabledOff = createSwitchView()

    let disabledOn = createSwitchView()
    disabledOn.isOn = true
    disabledOn.isEnabled = false
    let disabledOff = createSwitchView()
    disabledOff.isEnabled = false

    let stack = UIStackView(arrangedSubviews: [
        enabledOn,
        enabledOff,
        disabledOn,
        disabledOff
    ])
    stack.axis = .vertical

    return stack
}
