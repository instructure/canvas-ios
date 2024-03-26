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
    @IBOutlet weak var indentConstraint: NSLayoutConstraint!
    @IBOutlet weak var completedStatusView: UIImageView!
    @IBOutlet weak var publishMenuButton: UIButton!
    @IBOutlet weak var publishIndicatorView: ModuleItemPublishIndicatorView!

    private let env = AppEnvironment.shared
    private var publishStateObservers = Set<AnyCancellable>()
    private weak var host: UIViewController?
    private var moduleItemId: String?
    private var fileId: String?
    private var moduleId: String?
    private var courseId: String?
    private var publishInteractor: ModulePublishInteractor?

    override func prepareForReuse() {
        super.prepareForReuse()
        publishIndicatorView.prepareForReuse()
        publishStateObservers.removeAll()
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
        let isPublishing: Bool = {
            publishInteractor.moduleItemsUpdating.value.contains(item.id) ||
            publishInteractor.modulesUpdating.value.contains(item.moduleID)
        }()
        updateA11yLabelForPublishState(moduleItem: item, isPublishing: isPublishing)

        accessibilityIdentifier = "ModuleList.\(indexPath.section).\(indexPath.row)"
        nameLabel.accessibilityIdentifier = "ModuleList.\(indexPath.section).\(indexPath.row).nameLabel"
        dueLabel.accessibilityIdentifier = "ModuleList.\(indexPath.section).\(indexPath.row).dueLabel"

        publishMenuButton.isHidden = !publishInteractor.isPublishActionAvailable
        switch item.type {
        case .file: // files open a dedicated dialog and don't use the context menu
            publishMenuButton.showsMenuAsPrimaryAction = false
            accessibilityCustomActions = publishInteractor.isPublishActionAvailable ? [
                .init(
                    name: String(localized: "Edit permissions"),
                    target: self,
                    selector: #selector(presentFilePermissionEditorDialog)
                ),
            ] : []
            publishMenuButton.addTarget(self, action: #selector(presentFilePermissionEditorDialog), for: .primaryActionTriggered)
        default:
            publishMenuButton.showsMenuAsPrimaryAction = true
            publishMenuButton.removeTarget(self, action: #selector(presentFilePermissionEditorDialog), for: .primaryActionTriggered)
        }

        subscribeToPublishStateUpdates(item, publishInteractor: publishInteractor, host: host)
    }

    private func updatePublishedState(_ item: ModuleItem) {
        let availability = item.fileAvailability ?? (item.published == true ? .published : .unpublished)
        publishIndicatorView.update(availability: availability)
    }

    private func updatePublishInProgressState(
        _ item: ModuleItem,
        publishInteractor: ModulePublishInteractor
    ) {
        let isItemUpdating = publishInteractor
            .moduleItemsUpdating
            .value
            .contains(item.id)
        let isParentModuleUpdating = publishInteractor
            .modulesUpdating
            .value
            .contains(item.moduleID)
        let isUpdating = isItemUpdating || isParentModuleUpdating

        publishIndicatorView.update(isPublishInProgress: isUpdating)
        publishMenuButton.isEnabled = !isUpdating
    }

    @objc
    private func presentFilePermissionEditorDialog() {
        guard let host, let fileId, let moduleId, let moduleItemId, let courseId, let publishInteractor else {
            return
        }
        let viewModel = ModuleFilePermissionEditorViewModel(
            fileContext: .init(
                fileId: fileId,
                moduleId: moduleId,
                moduleItemId: moduleItemId,
                courseId: courseId
            ),
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
        guard publishStateObservers.isEmpty else { return }

        // We have to do an instant update because the update via subscription is delayed
        updatePublishedState(item)
        updatePublishInProgressState(item, publishInteractor: publishInteractor)

        Publishers.CombineLatest(
            publishInteractor.moduleItemsUpdating.map { $0.contains(item.id) },
            publishInteractor.modulesUpdating.map { $0.contains(item.moduleID) }
        )
        .map { (itemUpdating, parentModuleUpdating) in
            itemUpdating || parentModuleUpdating
        }
        .removeDuplicates()
        .receive(on: RunLoop.main)
        .sink { [weak self, weak host] isUpdating in
            guard let self, let host else { return }

            if !item.type.isFile {
                updatePublishMenuActions(moduleItem: item, publishInteractor: publishInteractor, isPublishing: isUpdating, host: host)
            }

            publishMenuButton.isEnabled = !isUpdating
            updatePublishedState(item)
            publishIndicatorView.update(isPublishInProgress: isUpdating)
            updateA11yLabelForPublishState(moduleItem: item, isPublishing: isUpdating)
        }
        .store(in: &publishStateObservers)
    }

    private func updatePublishMenuActions(
        moduleItem: ModuleItem,
        publishInteractor: ModulePublishInteractor,
        isPublishing: Bool,
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
            if publishMenuButton.isHidden || isPublishing {
                return []
            }

            return .makePublishModuleItemA11yActions(
                action: action,
                host: host,
                actionDidPerform: performUpdate
            )
        }()
    }

    private func updateA11yLabelForPublishState(moduleItem: ModuleItem, isPublishing: Bool) {
        if !publishIndicatorView.isHidden {
            let publishedText = {
                if isPublishing {
                    return String(localized: "Publish state modification in progress")
                }
                if let availability = moduleItem.fileAvailability {
                    return availability.a11yLabel
                } else {
                    return moduleItem.published == true
                        ? String(localized: "published")
                        : String(localized: "unpublished")
                }
            }()
            accessibilityLabel = [
                moduleItem.type?.label,
                moduleItem.title,
                publishedText,
            ].compactMap { $0 }.joined(separator: ", ")
        }
    }
}
