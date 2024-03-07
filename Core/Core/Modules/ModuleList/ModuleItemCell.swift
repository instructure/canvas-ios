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
import Foundation
import UIKit

class ModuleItemCell: UITableViewCell {
    static let IndentMultiplier: CGFloat = 10

    @IBOutlet weak var contentStackView: UIStackView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dueLabel: UILabel!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var publishedIconView: PublishedIconView!
    @IBOutlet weak var publishInProgressIndicator: CircleProgressView!
    @IBOutlet weak var indentConstraint: NSLayoutConstraint!
    @IBOutlet weak var completedStatusView: UIImageView!
    @IBOutlet weak var publishMenuButton: UIButton!

    private let env = AppEnvironment.shared
    private var publishStateObserver: AnyCancellable?
    private var isFirstUpdate = true
    private weak var host: UIViewController?
    private var moduleItemId: String?
    private var fileId: String?
    private var moduleId: String?
    private var courseId: String?
    private var publishInteractor: ModulePublishInteractor?

    override func prepareForReuse() {
        super.prepareForReuse()
        publishStateObserver = nil
        isFirstUpdate = true
    }

    func update(
        _ item: ModuleItem,
        indexPath: IndexPath,
        color: UIColor?,
        publishInteractor: ModulePublishInteractor,
        host: UIViewController
    ) {
        self.host = host
        self.publishInteractor = publishInteractor
        moduleId = item.moduleID
        moduleItemId = item.id
        fileId = item.type.fileId
        courseId = item.courseID
        backgroundColor = .backgroundLightest
        selectedBackgroundView = ContextCellBackgroundView.create(color: color)
        let isLocked = item.isLocked || item.masteryPath?.locked == true
        isUserInteractionEnabled = env.app == .teacher || !isLocked
        nameLabel.setText(item.title, style: .textCellTitle)
        nameLabel.isEnabled = isUserInteractionEnabled
        nameLabel.textColor = nameLabel.isEnabled ? .textDarkest : .textLight
        iconView.image = item.masteryPath?.locked == true ? UIImage.lockLine : item.type?.icon
        contentStackView.setCustomSpacing(16, after: iconView)
        iconView.isHidden = (iconView.image == nil)
        publishedIconView.published = item.published

        completedStatusView.isHidden = env.app == .teacher || item.completionRequirement == nil
        completedStatusView.image = item.completed == true ? .checkLine : .emptyLine
        completedStatusView.tintColor = item.completed == true ? .backgroundSuccess : .borderMedium
        indentConstraint.constant = CGFloat(item.indent) * ModuleItemCell.IndentMultiplier
        let dueAt = item.dueAt.flatMap { DateFormatter.localizedString(from: $0, dateStyle: .medium, timeStyle: .none) }
        let points: String? = item.pointsPossible.flatMap {
            if item.hideQuantitativeData {
                return nil
            } else {
                return String.localizedStringWithFormat(
                    NSLocalizedString("%@ pts", bundle: .core, comment: ""),
                    NSNumber(value: $0)
                )
            }
        }
        let requirement = item.completionRequirement?.description
        if let masteryPath = item.masteryPath, masteryPath.needsSelection, !masteryPath.locked {
            let format = NSLocalizedString("d_options", bundle: .core, comment: "")
            dueLabel.setText(String.localizedStringWithFormat(format, masteryPath.numberOfOptions), style: .textCellSupportingText)
            dueLabel.textColor = tintColor
            accessoryView = UIImageView(image: .masteryPathsLine)
        } else {
            dueLabel.setText([dueAt, points, requirement].compactMap { $0 }.joined(separator: " | "), style: .textCellSupportingText)
            dueLabel.textColor = .textDark
            accessoryView = nil
        }
        dueLabel.isHidden = dueLabel.text == nil
        var a11yLabels = [item.type?.label, item.title, dueLabel.text]
        if item.isLocked {
            a11yLabels.append(NSLocalizedString("locked", bundle: .core, comment: ""))
        }
        accessibilityLabel = a11yLabels.compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: ", ")
        updateA11yLabelForPublishState(moduleItem: item)

        accessibilityIdentifier = "ModuleList.\(indexPath.section).\(indexPath.row)"
        nameLabel.accessibilityIdentifier = "ModuleList.\(indexPath.section).\(indexPath.row).nameLabel"
        dueLabel.accessibilityIdentifier = "ModuleList.\(indexPath.section).\(indexPath.row).dueLabel"

        publishMenuButton.isHidden = !publishInteractor.isPublishActionAvailable
        switch item.type {
        case .file:
            publishMenuButton.showsMenuAsPrimaryAction = false
            accessibilityCustomActions = []
            publishMenuButton.addTarget(self, action: #selector(presentFilePermissionEditorDialog), for: .primaryActionTriggered)
        default:
            publishMenuButton.showsMenuAsPrimaryAction = true
            publishMenuButton.removeTarget(self, action: #selector(presentFilePermissionEditorDialog), for: .primaryActionTriggered)
        }

        subscribeToPublishStateUpdates(item, publishInteractor: publishInteractor, host: host)
    }

    @objc
    private func presentFilePermissionEditorDialog() {
        guard let host, let fileId, let moduleId, let moduleItemId, let courseId, let publishInteractor else {
            return
        }
        let viewModel = ModuleFilePermissionEditorViewModel(
            fileId: fileId,
            moduleId: moduleId,
            moduleItemId: moduleItemId,
            courseId: courseId,
            interactor: publishInteractor,
            router: env.router
        )
        let editorView = ModuleFilePermissionEditorView(viewModel: viewModel)
        let hostController = CoreHostingController(editorView)
        env.router.show(hostController, from: host, options: .modal(isDismissable: false, embedInNav: true))
    }

    private func subscribeToPublishStateUpdates(
        _ item: ModuleItem,
        publishInteractor: ModulePublishInteractor,
        host: UIViewController
    ) {
        guard publishStateObserver == nil else { return }

        publishStateObserver = publishInteractor
            .moduleItemsUpdating
            .map { $0.contains(item.id) }
            .removeDuplicates()
            .sink { [weak self, weak host] isUpdating in
                guard let self, let host else { return }
                let animated = !isFirstUpdate
                isFirstUpdate = false

                if !item.type.isFile {
                    updatePublishMenuActions(moduleItem: item, publishInteractor: publishInteractor, host: host)
                }

                updatePublishedUIState(isUpdating: isUpdating, isItemPublished: item.published ?? false, animated: animated)
                updateA11yLabelForPublishState(moduleItem: item)
            }
    }

    private func updatePublishMenuActions(
        moduleItem: ModuleItem,
        publishInteractor: ModulePublishInteractor,
        host: UIViewController
    ) {
        let action: ModulePublishAction = moduleItem.published == true ? .unpublish : .publish
        let performUpdate = {
            publishInteractor.changeItemPublishedState(
                moduleId: moduleItem.moduleID,
                moduleItemId: moduleItem.id,
                action: action
            )
        }
        publishMenuButton.menu = .makePublishModuleItemMenu(action: action, host: host, actionDidPerform: performUpdate)

        accessibilityCustomActions = {
            if publishMenuButton.isHidden {
                return []
            }

            return .makePublishModuleItemA11yActions(
                action: action,
                host: host,
                actionDidPerform: performUpdate
            )
        }()
    }

    private func updatePublishedUIState(isUpdating: Bool, isItemPublished: Bool, animated: Bool) {
        if isUpdating {
            publishInProgressIndicator?.startAnimating()
        }

        publishInProgressIndicator?.alpha = isUpdating ? 0 : 1
        publishedIconView?.published = isItemPublished
        publishedIconView?.alpha = isUpdating ? 1 : 0

        UIView.animate(withDuration: animated ? 0.3 : 0.0) { [weak publishInProgressIndicator, weak publishedIconView] in
            publishInProgressIndicator?.alpha = isUpdating ? 1 : 0
            publishedIconView?.alpha = isUpdating ? 0 : 1
        } completion: { [weak publishInProgressIndicator] _ in
            if !isUpdating {
                publishInProgressIndicator?.stopAnimating()
            }
        }
    }

    private func updateA11yLabelForPublishState(moduleItem: ModuleItem) {
        if !publishedIconView.isHidden {
            accessibilityLabel = [
                moduleItem.type?.label,
                moduleItem.title,
                moduleItem.published == true
                    ? String(localized: "published")
                    : String(localized: "unpublished"),
            ].compactMap { $0 }.joined(separator: ", ")
        }
    }
}
