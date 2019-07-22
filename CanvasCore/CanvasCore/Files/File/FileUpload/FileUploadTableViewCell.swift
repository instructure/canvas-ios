//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
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

import ReactiveSwift
import Cartography
import CoreData

protocol FileUploadTableViewCellDelegate: class {
    func fileUploadTableViewCell(_ cell: FileUploadTableViewCell, needsToDisplay errorMessage: String)
}

class FileUploadTableViewCell: UITableViewCell {
    fileprivate let viewModel: FileUploadViewModelType = FileUploadViewModel()
    weak var delegate: FileUploadTableViewCellDelegate?

    // Icon
    @objc let iconImageView = UIImageView()

    // Labels
    @objc let nameLabel = UILabel()
    @objc let statusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        return label
    }()
    @objc lazy var labelStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 1

        stack.addArrangedSubview(self.nameLabel)
        stack.addArrangedSubview(self.statusLabel)

        return stack
    }()

    // Actions
    @objc let errorInfoButton = UIButton(type: .infoLight)
    @objc let statusButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
        return btn
    }()
    @objc lazy var actionStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12

        stack.addArrangedSubview(self.errorInfoButton)
        stack.addArrangedSubview(self.statusButton)

        return stack
    }()

    // Progress
    @objc let progressView: GradientView = {
        let view = GradientView()
        let left = UIColor(r: 0, g: 142, b: 226)
        let right = UIColor(r: 0, g: 193, b: 243)
        view.colors = [left, right]
        view.direction = (CGPoint(x: 0, y: 0.5), CGPoint(x: 1, y: 0.5))
        return view
    }()
    @objc var progressWidthConstraint: NSLayoutConstraint!

    // Constants
    @objc let iconSize: CGFloat = 24
    @objc let progressHeight: CGFloat = 4
    @objc let minimumProgress = 5

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        layoutViews()
        bindViewModel()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func bindViewModel() {
        self.nameLabel.reactive.text <~ self.viewModel.outputs.fileName.observe(on: UIScheduler())

        self.statusLabel.rac_text <~ self.viewModel.outputs.statusText.observe(on: UIScheduler())

        self.statusLabel.reactive.textColor <~ self.viewModel.outputs.statusTextColor.observe(on: UIScheduler())

        self.errorInfoButton.reactive.isHidden <~ self.viewModel.outputs.errorInfoButtonIsHidden.observe(on: UIScheduler())

        self.viewModel.outputs.statusIcon
            .observe(on: UIScheduler())
            .observeValues { [weak self] icon in
                self?.statusButton.setImage(.icon(icon), for: .normal)
            }

        self.viewModel.outputs.statusIconColor
            .observe(on: UIScheduler())
            .observeValues { [weak self] color in
                self?.statusButton.tintColor = color
            }

        self.statusButton.reactive.controlEvents(.touchUpInside)
            .observe(on: UIScheduler())
            .observeValues { [weak self] _ in
                self?.viewModel.inputs.tappedStatusButton()
            }

        self.iconImageView.reactive.image <~ self.viewModel.outputs.imageData.map { UIImage(data: $0) }.observe(on: UIScheduler())
        self.iconImageView.reactive.image <~ self.viewModel.outputs.graphic.map { $0.image }.observe(on: UIScheduler())

        self.viewModel.outputs.progress
            .observe(on: UIScheduler())
            .observeValues { [weak self] progress in
                self?.update(progress: progress)
            }

        self.errorInfoButton.reactive.controlEvents(.touchUpInside)
            .observe(on: UIScheduler())
            .observeValues { [weak self] _ in
                self?.viewModel.inputs.tappedErrorInfoButton()
            }

        self.viewModel.outputs.showError
            .observe(on: UIScheduler())
            .observeValues { [weak self] errorMessage in
                guard let me = self else { return }
                me.delegate?.fileUploadTableViewCell(me, needsToDisplay: errorMessage)
            }
    }

    @objc func layoutViews() {
        // Progress
        contentView.addSubview(progressView)
        progressView.heightAnchor.constraint(equalToConstant: progressHeight).isActive = true
        progressWidthConstraint = progressView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0)
        progressWidthConstraint.isActive = true
        constrain(progressView, contentView) { progressView, contentView in
            progressView.bottom == contentView.bottom
            progressView.leading == contentView.leading
        }

        // Icon
        contentView.addSubview(iconImageView)
        iconImageView.widthAnchor.constraint(equalToConstant: iconSize).isActive = true
        iconImageView.heightAnchor.constraint(equalToConstant: iconSize).isActive = true
        constrain(iconImageView, contentView) { icon, contentView in
            icon.leading == contentView.leadingMargin
            icon.centerY == contentView.centerY
        }

        // Actions
        contentView.addSubview(actionStack)
        actionStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        constrain(actionStack, contentView) { actionStack, contentView in
            actionStack.trailing == contentView.trailingMargin
        }

        // Labels
        contentView.addSubview(labelStack)
        constrain(labelStack, contentView) { labelStack, contentView in
            labelStack.top == contentView.topMargin
        }
        constrain(labelStack, progressView) { labelStack, progressView in
            distribute(by: 10, vertically: labelStack, progressView)
        }

        constrain(iconImageView, labelStack, actionStack) { iconImageView, labelStack, actionStack in
            distribute(by: 10, horizontally: iconImageView, labelStack, actionStack)
        }
    }

    @objc func configureWith(fileUpload: FileUpload, session: Session) {
        viewModel.inputs.fileUpload(fileUpload, session: session)
    }

    @objc func deleteUpload() {
        viewModel.inputs.tappedDeleteUpload()
    }

    @objc func update(progress: Double) {
        self.progressWidthConstraint.constant = CGFloat(progress) * self.contentView.frame.size.width / 100
    }
}
