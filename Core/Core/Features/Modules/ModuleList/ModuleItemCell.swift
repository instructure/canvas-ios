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

    @Injected(\.reachability) var reachability: ReachabilityProvider

    @IBOutlet weak var contentStackView: UIStackView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dueLabel: UILabel!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var indentConstraint: NSLayoutConstraint!
    @IBOutlet weak var completedStatusView: UIImageView!
    @IBOutlet weak var publishControl: ModulePublishControl!
    @IBOutlet weak var contentStackViewTrailingConstraint: NSLayoutConstraint!

    var course: Course?
    var item: ModuleItem?
    let downloadButtonHelper = DownloadStatusProvider()
    var onRetryServerError: ((ModuleItem) -> Void)?

    private let env = AppEnvironment.shared
    private var publishStateObservers = Set<AnyCancellable>()
    private weak var host: UIViewController?

    private var publishInteractor: ModulePublishInteractor?
    private var shouldShowPublishControl: Bool = false

    // stored IDs for FilePermissionEditor
    private var moduleItemId: String?
    private var fileId: String?
    private var moduleId: String?
    private var courseId: String?

    // MARK: - Update

    override func prepareForReuse() {
        super.prepareForReuse()
        publishControl.prepareForReuse()
        publishStateObservers.removeAll()
    }

    func update(
        _ item: ModuleItem,
        course: Course?,
        indexPath: IndexPath,
        color: UIColor?,
        publishInteractor: ModulePublishInteractor,
        host: UIViewController
    ) {
        self.course = course
        self.item = item
        self.host = host
        self.publishInteractor = publishInteractor
        shouldShowPublishControl = publishInteractor.isPublishActionAvailable
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

        if item.masteryPath?.locked == true {
            iconView.image = .lockLine
        } else {
            iconView.image = item.displayedType?.icon
        }
        contentStackView.setCustomSpacing(16, after: iconView)
        iconView.isHidden = (iconView.image == nil)

        completedStatusView.isHidden = env.app == .teacher || item.completionRequirement == nil
        completedStatusView.image = item.completed == true ? .checkLine : .emptyLine
        completedStatusView.tintColor = item.completed == true ? .backgroundSuccess : .borderMedium

        indentConstraint.constant = CGFloat(item.indent) * ModuleItemCell.IndentMultiplier

        updateDueLabel(item)

        accessibilityTraits = .button
        accessibilityIdentifier = "ModuleList.\(indexPath.section).\(indexPath.row)"
        nameLabel.accessibilityIdentifier = "ModuleList.\(indexPath.section).\(indexPath.row).nameLabel"
        dueLabel.accessibilityIdentifier = "ModuleList.\(indexPath.section).\(indexPath.row).dueLabel"

        publishControl.isHidden = !shouldShowPublishControl
        contentStackViewTrailingConstraint.constant = shouldShowPublishControl ? 0 : 16

        // We have to do an instant update because the update via subscription is delayed
        updatePublishControl(item)
        updatePublishInProgressState(item, isUpdating: publishInteractor.isModuleItemPublishInProgress(item))

        subscribeToPublishStateUpdates(item, publishInteractor: publishInteractor, host: host)
    }

    private func updateDueLabel(_ item: ModuleItem) {
        let dueAt = item.dueAt.flatMap { DateFormatter.localizedString(from: $0, dateStyle: .medium, timeStyle: .none) }
        let points: String? = item.pointsPossible.flatMap {
            if item.hideQuantitativeData {
                return nil
            } else {
                return String.localizedStringWithFormat(
                    String(localized: "%@ pts", bundle: .core),
                    NSNumber(value: $0)
                )
            }
        }
        let requirement = item.completionRequirement?.description
        if let masteryPath = item.masteryPath, masteryPath.needsSelection, !masteryPath.locked {
            let format = String(localized: "d_options", bundle: .core)
            dueLabel.setText(String.localizedStringWithFormat(format, masteryPath.numberOfOptions), style: .textCellSupportingText)
            dueLabel.textColor = tintColor
            accessoryView = UIImageView(image: .masteryPathsLine)
        } else {
            dueLabel.setText([dueAt, points, requirement].compactMap { $0 }.joined(separator: " | "), style: .textCellSupportingText)
            dueLabel.textColor = .textDark
            accessoryView = nil
        }
        dueLabel.isHidden = dueLabel.text == nil
        prepareForDownload()
    }

    private func updateA11yLabel(_ item: ModuleItem, isPublishing: Bool) {
        var a11yLabels: [String?] = [
            item.displayedType?.label,
            item.title
        ]

        if shouldShowPublishControl {
            let publishedText = {
                if isPublishing {
                    return String(localized: "Publish state modification in progress", bundle: .core)
                }

                if let availability = item.fileAvailability {
                    return availability.a11yLabel
                } else {
                    return item.published == true
                        ? String(localized: "published", bundle: .core)
                        : String(localized: "unpublished", bundle: .core)
                }
            }()
            a11yLabels.append(publishedText)
        } else {
            a11yLabels.append(contentsOf: [
                dueLabel.text,
                item.isLocked ? String(localized: "locked", bundle: .core) : nil
            ])
        }

        accessibilityLabel = a11yLabels.compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: ", ")
    }

    // MARK: - Publish

    private func subscribeToPublishStateUpdates(
        _ item: ModuleItem,
        publishInteractor: ModulePublishInteractor,
        host: UIViewController
    ) {
        guard publishStateObservers.isEmpty else { return }

        Publishers.CombineLatest(
            publishInteractor.moduleItemsUpdating.map { $0.contains(item.id) },
            publishInteractor.modulesUpdating.map { $0.contains(item.moduleID) }
        )
        .map { (itemUpdating, parentModuleUpdating) in
            itemUpdating || parentModuleUpdating
        }
        .removeDuplicates()
        .receive(on: RunLoop.main)
        .sink { [weak self] isUpdating in
            guard let self else { return }

            updatePublishControl(item)
            updatePublishInProgressState(item, isUpdating: isUpdating)
        }
        .store(in: &publishStateObservers)
    }

    private func updatePublishControl(_ item: ModuleItem) {
        publishControl.isEnabled = item.shouldEnablePublishControl
        updatePublishedState(item)
    }

    private func updatePublishedState(_ item: ModuleItem) {
        let availability = item.fileAvailability ?? (item.published == true ? .published : .unpublished)
        publishControl.update(availability: availability)
    }

    private func updatePublishInProgressState(_ item: ModuleItem, isUpdating: Bool) {
        updatePublishButtonAction(item, isPublishing: isUpdating)
        publishControl.update(isPublishInProgress: isUpdating)
        updateA11yLabel(item, isPublishing: isUpdating)
    }

    private func updatePublishButtonAction(_ item: ModuleItem, isPublishing: Bool) {
        guard let host else { return }

        if !shouldShowPublishControl || isPublishing {
            publishControl.setPrimaryAction(nil)
            accessibilityCustomActions = []
            return
        }

        switch item.type {
        case .file: // files open a dedicated dialog and don't use the context menu
            publishControl.setPrimaryAction { [weak self] in
                self?.presentFilePermissionEditorDialog()
            }
            accessibilityCustomActions = [
                .init(
                    name: String(localized: "Edit permissions", bundle: .core),
                    target: self,
                    selector: #selector(presentFilePermissionEditorDialog)
                )
            ]
        default:
            if item.shouldEnablePublishControl {
                let action: ModulePublishAction = item.published == true ? .unpublish : .publish
                let performUpdate: () -> Void = { [weak publishInteractor] in
                    publishInteractor?.changeItemPublishedState(
                        moduleId: item.moduleID,
                        moduleItemId: item.id,
                        action: action
                    )
                }

                publishControl.setPrimaryActionToMenu(
                    .makePublishModuleItemMenu(
                        action: action,
                        host: host,
                        actionDidPerform: performUpdate
                    )
                )
                accessibilityCustomActions = .makePublishModuleItemA11yActions(
                    action: action,
                    host: host,
                    actionDidPerform: performUpdate
                )
            } else {
                publishControl.setPrimaryAction { [weak self] in
                    self?.showCantUnpublishSnackBar()
                }
                accessibilityCustomActions = []
            }
        }
    }

    @objc
    private func showCantUnpublishSnackBar() {
        let message = String(localized: "Can’t unpublish, if there are student submissions.", bundle: .core)
        host?.findSnackBarViewModel()?.showSnack(message)
    }

    // MARK: - File Permissions

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
}

private extension ModuleItem {
    var shouldEnablePublishControl: Bool {
        type.isFile || published == false || canBeUnpublished
    }

    var displayedType: ModuleItemType? {
        isQuizLTI ? .quiz("") : type
    }
}

private extension FileAvailability {
    var a11yLabel: String {
        switch self {
        case .published: return String(localized: "published", bundle: .core)
        case .unpublished: return String(localized: "unpublished", bundle: .core)
        case .hidden: return String(localized: "only available with link", bundle: .core)
        case .scheduledAvailability: return String(localized: "scheduled availability", bundle: .core)
        }
    }
}
