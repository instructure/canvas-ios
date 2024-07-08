//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

class ModuleSectionHeaderView: UITableViewHeaderFooterView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collapsableIndicator: UIImageView!
    @IBOutlet weak var lockedButton: UIButton!
    @IBOutlet weak var publishControl: ModulePublishControl!
    @IBOutlet weak var publishControlGuide: UIView!
    @IBOutlet weak var contentStackViewTrailingConstraint: NSLayoutConstraint!

    var isExpanded = true
    var onTap: (() -> Void)?
    var onLockTap: (() -> Void)?

    private var publishInteractor: ModulePublishInteractor?
    private var shouldShowPublishControl: Bool = false
    private var module: Module?
    private var publishStateObserver: AnyCancellable?
    private weak var host: UIViewController?

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        loadFromXib().backgroundColor = .backgroundLight
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        publishStateObserver = nil
        publishControl.prepareForReuse()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadFromXib().backgroundColor = .backgroundLight
    }

    func update(
        _ module: Module,
        section: Int,
        isExpanded: Bool,
        host: UIViewController,
        publishInteractor: ModulePublishInteractor,
        onTap: @escaping () -> Void
    ) {
        self.module = module
        self.isExpanded = isExpanded
        self.publishInteractor = publishInteractor
        shouldShowPublishControl = publishInteractor.isPublishActionAvailable
        self.onTap = onTap
        self.host = host
        titleLabel.text = module.name

        lockedButton.isHidden = module.state != .locked
        collapsableIndicator.transform = CGAffineTransform(rotationAngle: isExpanded ? 0 : .pi)

        accessibilityTraits.insert(.button)
        accessibilityIdentifier = "ModuleList.\(section)"

        publishControl.isHidden = !shouldShowPublishControl
        publishControlGuide.isHidden = !shouldShowPublishControl
        contentStackViewTrailingConstraint.constant = shouldShowPublishControl ? 0 : 16
        publishControl.constrainIconsCenterTo(publishControlGuide)
        updatePublishedState(module)

        // Do an instant update because the subscription is delayed
        updatePublishInProgressState(module, isUpdating: publishInteractor.isModulePublishInProgress(module))

        subscribeToPublishStateUpdates(module, publishInteractor: publishInteractor)
    }

    @IBAction func handleTap() {
        isExpanded = !isExpanded
        UIView.animate(withDuration: 0.3) {
            self.collapsableIndicator.transform = CGAffineTransform(rotationAngle: self.isExpanded ? 0 : .pi)
            self.collapsableIndicator.layoutIfNeeded()
        }
        onTap?()
    }

    @IBAction func lockTapped() {
        onLockTap?()
    }

    private func updateA11yLabel(_ module: Module, isPublishing: Bool) {
        let publishedState: String? = {
            if isPublishing {
                return String(localized: "Publish state modification in progress", bundle: .core)
            }

            guard let published = module.published, shouldShowPublishControl else {
                return nil
            }

            return published
                ? String(localized: "published", bundle: .core)
                : String(localized: "unpublished", bundle: .core)
        }()

        accessibilityLabel = [
            module.name,
            publishedState,
            isExpanded
                ? String(localized: "expanded", bundle: .core)
                : String(localized: "collapsed", bundle: .core)
        ].compactMap { $0 }.joined(separator: ", ")
    }

    private func updatePublishedState(_ module: Module) {
        publishControl.update(availability: module.published.map({ $0 ? .published : .unpublished }))
    }

    private func updatePublishInProgressState(_ module: Module, isUpdating: Bool) {
        updatePublishButtonAction(module, isPublishing: isUpdating)
        publishControl.update(isPublishInProgress: isUpdating)
        updateA11yLabel(module, isPublishing: isUpdating)
    }

    private func updatePublishButtonAction(_ module: Module, isPublishing: Bool) {
        guard let host else { return }

        if !shouldShowPublishControl || isPublishing {
            publishControl.setPrimaryAction(nil)
            accessibilityCustomActions = []
            return
        }

        guard publishControl.menu == nil else { return }

        publishControl.setPrimaryActionToMenu(
            .makePublishModuleMenu(host: host) { [weak self] action in
                self?.didPerformPublishAction(action: action)
            }
        )
        accessibilityCustomActions = .makePublishModuleA11yActions(host: host) { [weak self] action in
            self?.didPerformPublishAction(action: action)
        }
    }

    private func didPerformPublishAction(action: ModulePublishAction) {
        guard let sourceViewController = viewController,
              let publishInteractor,
              let module
        else { return }

        let viewModel = ModulePublishProgressViewModel(
            action: action,
            allModules: false,
            moduleIds: [module.id],
            interactor: publishInteractor
        )
        let viewController = CoreHostingController(ModulePublishProgressView(viewModel: viewModel))
        AppEnvironment.shared.router.show(viewController, from: sourceViewController, options: .modal(isDismissable: true, embedInNav: true))
    }

    private func subscribeToPublishStateUpdates(
        _ module: Module,
        publishInteractor: ModulePublishInteractor
    ) {
        guard publishStateObserver == nil else { return }

        publishStateObserver = publishInteractor
            .modulesUpdating
            .map { $0.contains(module.id) }
            .receive(on: RunLoop.main)
            .sink { [weak self] isPublishing in
                self?.updatePublishInProgressState(module, isUpdating: isPublishing)
            }
    }
}
