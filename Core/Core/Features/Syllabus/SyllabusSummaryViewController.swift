//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

import UIKit
import SwiftUI

public protocol ColorDelegate: AnyObject {
    var iconColor: UIColor? { get }
}

public class SyllabusSummaryViewController: UITableViewController {
    private(set) var env = AppEnvironment.shared
    var courseID: String!
    var context: Context { Context(.course, id: courseID) }
    public weak var colorDelegate: ColorDelegate?
    public var titleSubtitleView: TitleSubtitleView = TitleSubtitleView.create()

    public lazy var summary = env.subscribe(GetSyllabusSummary(context: context)) { [weak self] in
        self?.update()
    }

    lazy var course = env.subscribe(GetCourse(courseID: courseID)) { [weak self] in
        self?.update()
    }

    lazy var color = env.subscribe(GetCustomColors()) { [weak self] in
        self?.update()
    }

    private var emptyPandaViewController: CoreHostingController<InteractivePanda> = {
        let vc = CoreHostingController(
            InteractivePanda(
                scene: SpacePanda(),
                title: Text("No syllabus"),
                subtitle: Text("There is no syllabus to display.")
            )
        )
        vc.view.backgroundColor = .backgroundLightest
        return vc
    }()


    public static func create(courseID: String, colorDelegate: ColorDelegate? = nil, env: AppEnvironment) -> SyllabusSummaryViewController {
        let viewController = SyllabusSummaryViewController(nibName: nil, bundle: nil)
        viewController.courseID = courseID
        viewController.colorDelegate = colorDelegate
        viewController.env = env
        return viewController
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .backgroundLightest
        tableView.backgroundColor = .backgroundLightest
        tableView.separatorInset = .zero
        tableView.separatorColor = .borderMedium
        tableView.tableFooterView = UIView()
        tableView.registerCell(SyllabusSummaryItemCell.self)

        let refresh = CircleRefreshControl()
        refresh.addTarget(self, action: #selector(refresh(_:)), for: .primaryActionTriggered)
        tableView.refreshControl = refresh

        course.refresh()
        color.refresh()

        summary.exhaust(force: false)
    }

    func update() {
        guard !summary.pending, !course.pending else {
            return
        }

        if tableView.refreshControl?.isRefreshing == true {
            tableView.refreshControl?.endRefreshing()
        }

        if summary.isEmpty {
            tableView.backgroundColor = .clear
            addChild(emptyPandaViewController)
            emptyPandaViewController.didMove(toParent: self)
            tableView.addSubview(emptyPandaViewController.view)
            emptyPandaViewController.view.pin(inside: tableView)
            NSLayoutConstraint.activate([
                emptyPandaViewController.view.heightAnchor.constraint(equalTo: view.heightAnchor),
                emptyPandaViewController.view.widthAnchor.constraint(equalTo: view.widthAnchor)
            ])
        } else if emptyPandaViewController.parent != nil, emptyPandaViewController.view.superview != nil {
            emptyPandaViewController.removeFromParent()
            emptyPandaViewController.view.removeFromSuperview()
        }
        tableView.reloadData()
    }

    @objc func refresh(_ sender: UIRefreshControl) {
        summary.exhaust(force: true)
    }

    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return summary.count
    }

    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(SyllabusSummaryItemCell.self, for: indexPath)
        let item = summary[indexPath.row]
        let color = colorDelegate?.iconColor ?? course.first?.color
        cell.update(item, indexPath: indexPath, color: color)
        return cell
    }

    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = summary[indexPath]
        if let url = item?.htmlURL {
            env.router.route(to: url, from: self)
        }
    }
}

class SyllabusSummaryItemCell: UITableViewCell {
    @IBOutlet weak var dateLabel: DynamicLabel!
    @IBOutlet weak var itemNameLabel: DynamicLabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var iconImageView: UIImageView!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        loadFromXib()
        setupCell()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadFromXib()
        setupCell()
    }

    func setupCell() {
        backgroundColor = .backgroundLightest
    }

    func update(_ item: SyllabusSummaryItem?, indexPath: IndexPath, color: UIColor?) {
        backgroundColor = .backgroundLightest
        itemNameLabel?.setText(item?.title, style: .textCellTitle)
        iconImageView?.image = item?.icon
        iconImageView?.tintColor = color
        dateLabel?.setText(item?.dateFormatted ?? String(localized: "No Due Date", bundle: .core), style: .textCellSupportingText)
        accessibilityIdentifier = "itemCell.\(item?.id ?? "")"
        selectedBackgroundView = ContextCellBackgroundView.create(color: color)
    }
}
