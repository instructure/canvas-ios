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

public class SyllabusActionableItemsViewController: UITableViewController {

    struct ViewModel {
        var id: String
        var htmlUrl: URL
        var title: String
        var dueDate: Date?
        var formattedDate: String
        var image: UIImage?
    }
    var models: [ViewModel] = []
    var presenter: SyllabusActionableItemsPresenter?
    public var color: UIColor?
    public weak var colorDelegate: ColorDelegate?
    public var titleSubtitleView: TitleSubtitleView = TitleSubtitleView.create()

    public convenience init(env: AppEnvironment = .shared, courseID: String, sort: GetAssignments.Sort = .dueAt, colorDelegate: ColorDelegate? = nil) {
        self.init(nibName: nil, bundle: nil)
        presenter = SyllabusActionableItemsPresenter(view: self, courseID: courseID, sort: sort)
        self.colorDelegate = colorDelegate
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        tableView.backgroundColor = .named(.backgroundLightest)
        tableView.separatorInset = .zero
        tableView.separatorColor = .named(.borderMedium)
        tableView.tableFooterView = UIView()
        tableView.register(SyllabusActionableItemsCell.self, forCellReuseIdentifier: String(describing: SyllabusActionableItemsCell.self))
        presenter?.viewIsReady()
        tableView.showsVerticalScrollIndicator = false
    }

    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }

    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(SyllabusActionableItemsCell.self, for: indexPath)
        cell.backgroundColor = .named(.backgroundLightest)
        cell.itemNameLabel?.text = models[indexPath.row].title
        cell.iconImageView?.image = models[indexPath.row].image
        cell.iconImageView?.tintColor = colorDelegate?.iconColor ?? color
        cell.dateLabel?.text = models[indexPath.row].formattedDate
        return cell
    }

    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let htmlUrl = models[indexPath.row].htmlUrl
        presenter?.select(htmlUrl, from: self)
    }
}

extension SyllabusActionableItemsViewController: SyllabusActionableItemsViewProtocol {
    func update(models: [ViewModel]) {
        self.models = models
        tableView.reloadData()
    }

    func updateColor(_ color: UIColor?) {
        self.color = color
    }
}

class SyllabusActionableItemsCell: UITableViewCell {

    @IBOutlet weak var dateLabel: DynamicLabel!
    @IBOutlet weak var itemNameLabel: DynamicLabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var iconImageView: UIImageView!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        loadFromXib()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadFromXib()
    }
}
