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

import Foundation

class ModuleSectionHeaderView: UITableViewHeaderFooterView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var publishedIconView: PublishedIconView!
    @IBOutlet weak var collapsableIndicator: UIImageView!
    @IBOutlet weak var lockedButton: UIButton!
    @IBOutlet weak var publishMenuButton: UIButton!

    var isExpanded = true
    var onTap: (() -> Void)?
    var onLockTap: (() -> Void)?

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        loadFromXib().backgroundColor = .backgroundLight
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
        self.isExpanded = isExpanded
        self.onTap = onTap
        titleLabel.text = module.name
        publishedIconView.published = module.published
        lockedButton.isHidden = module.state != .locked
        collapsableIndicator.transform = CGAffineTransform(rotationAngle: isExpanded ? 0 : .pi)
        setupPublishMenu(host: host, publishInteractor: publishInteractor)
        accessibilityLabel = [
            module.name,
            publishedIconView.isHidden ? "" :
            module.published == true
                ? NSLocalizedString("published", bundle: .core, comment: "")
                : NSLocalizedString("unpublished", bundle: .core, comment: ""),
            isExpanded
                ? NSLocalizedString("expanded", bundle: .core, comment: "")
                : NSLocalizedString("collapsed", bundle: .core, comment: ""),
        ].joined(separator: ", ")
        accessibilityTraits.insert(.button)
        accessibilityIdentifier = "ModuleList.\(section)"

        if publishMenuButton.menu == nil {
            publishMenuButton.menu = .makePublishModuleMenu(host: host) { [weak self] action in
                self?.didPerformPublishAction(action: action)
            }
            publishMenuButton.showsMenuAsPrimaryAction = true
        }

        publishMenuButton.isHidden = !publishInteractor.isPublishActionAvailable
        accessibilityCustomActions = publishMenuButton.isHidden ? [] : .makePublishModuleA11yActions(host: host) { [weak self] action in
            self?.didPerformPublishAction(action: action)
        }
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

    private func setupPublishMenu(
        host: UIViewController,
        publishInteractor: ModulePublishInteractor
    ) {
        if publishMenuButton.menu == nil {
            publishMenuButton.menu = .makePublishModuleMenu(host: host) { [weak self] action in
                self?.didPerformPublishAction(action: action)
            }
            publishMenuButton.showsMenuAsPrimaryAction = true
        }

        publishMenuButton.isHidden = !publishInteractor.isPublishActionAvailable
    }

    private func didPerformPublishAction(action: ModulePublishAction) {
        guard let sourceViewController = viewController else { return }

        let router = AppEnvironment.shared.router
        let viewModel = ModulePublishProgressViewModel(action: action, allModules: false, router: router)
        let viewController = CoreHostingController(ModulePublishProgressView(viewModel: viewModel))
        router.show(viewController, from: sourceViewController, options: .modal(isDismissable: true, embedInNav: true))
    }
}
