//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

protocol PlannerListDelegate: UIScrollViewDelegate {
    func plannerListWillRefresh()
    func getPlannables(from: Date, to: Date) -> GetPlannables
}

public class PlannerListViewController: UIViewController {
    @IBOutlet weak var emptyStateHeader: UILabel!
    @IBOutlet weak var emptyStateSubHeader: UILabel!
    @IBOutlet weak var emptyStateView: UIView!
    @IBOutlet weak var errorView: ListErrorView!
    let refreshControl = CircleRefreshControl()
    @IBOutlet weak var spinnerView: CircleProgressView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewBackgroundView: TableViewBackgroundView!

    weak var delegate: PlannerListDelegate?
    let env = AppEnvironment.shared
    var start: Date = Clock.now.startOfDay() // inclusive
    var end: Date = Clock.now.startOfDay().addDays(1) // exclusive

    private var selectedPlannableId: String?
    private var needsDetailsAccessibilityFocus: Bool = false

    var plannables: Store<GetPlannables>?

    static func create(start: Date, end: Date, delegate: PlannerListDelegate?) -> PlannerListViewController {
        let controller = loadFromStoryboard()
        controller.delegate = delegate
        controller.start = start
        controller.end = end
        return controller
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        emptyStateHeader.text = String(localized: "No Events Today!", bundle: .core)
        emptyStateSubHeader.text = String(localized: "It looks like a great day to rest, relax, and recharge.", bundle: .core)
        errorView.messageLabel.text = String(localized: "There was an error loading events. Pull to refresh to try again.", bundle: .core)
        errorView.retryButton.addTarget(self, action: #selector(retryAfterError), for: .primaryActionTriggered)

        refreshControl.addTarget(self, action: #selector(plannerListWillRefresh), for: .primaryActionTriggered)
        refreshControl.color = nil
        spinnerView.color = nil
        tableView.refreshControl = refreshControl
        tableView.separatorColor = .borderMedium
        self.view.backgroundColor = .backgroundLightest
        tableView.tableFooterView = UIView(frame: .zero)
        tableViewBackgroundView.add(to: tableView)
        refresh()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selected = tableView.indexPathForSelectedRow,
           splitViewController?.isCollapsed ?? true {
            tableView.deselectRow(at: selected, animated: true)
            selectedPlannableId = nil
        }
    }

    @objc func retryAfterError() {
        refreshControl.beginRefreshing()
        delegate?.plannerListWillRefresh()
    }

    @objc func plannerListWillRefresh() {
        delegate?.plannerListWillRefresh()
    }

    func refresh(force: Bool = false) {
        errorView.isHidden = true
        plannables = delegate.flatMap { env.subscribe($0.getPlannables(from: start, to: end)) { [weak self] in
            self?.updatePlannables()
        } }
        plannables?.refresh(force: force)
    }

    private func updatePlannables() {
        guard plannables?.requested == true, plannables?.pending == false else { return }
        refreshControl.endRefreshing()
        spinnerView.isHidden = true
        emptyStateView.isHidden = plannables?.error != nil || plannables?.isEmpty != true
        errorView.isHidden = plannables?.error == nil
        tableView.reloadData()
        reselectRowAfterReload()
        accessibilityFocusOnDetailsIfNeeded()
    }

    func setNeedsDetailsAccessibilityFocus() {
        needsDetailsAccessibilityFocus = true
    }

    func accessibilityFocusOnDetailsIfNeeded() {
        guard needsDetailsAccessibilityFocus else { return }
        accessibilityFocusOnDetails()
        needsDetailsAccessibilityFocus = false
    }

    func accessibilityFocusOnDetails() {
        if emptyStateView.isHidden {
            accessibilityFocusOnDefaultRow()
        } else {
            let message = String(localized: "No Events Today!", bundle: .core)
            UIAccessibility.announce(message)
        }
    }

    private func accessibilityFocusOnDefaultRow() {
        /// Calling this on main queue with a duration to avoid any
        /// possible interruption caused by cell reloading or selection
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self else { return }
            let cell = tableView.cellForRow(at: indexPathForRowToFocusOn)
            UIAccessibility.post(notification: .screenChanged, argument: cell)
        }
    }

    private func reselectRowAfterReload() {
        guard let selectedPlannableId,
              let index = plannables?.all.firstIndex(where: { $0.id == selectedPlannableId })
        else {
            return
        }

        let indexPath = IndexPath(row: index, section: 0)
        tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
    }

    private var indexPathForRowToFocusOn: IndexPath {
        if let selectedPlannableId,
           let index = plannables?.all.firstIndex(where: { $0.id == selectedPlannableId }) {
            return IndexPath(row: index, section: 0)
        }
        return IndexPath(row: 0, section: 0)
    }
}

extension PlannerListViewController: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return plannables?.count ?? 0
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: PlannerListCell = tableView.dequeue(for: indexPath)
        let p = plannables?[indexPath]
        cell.update(p)
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let plannable = plannables?[indexPath] else { return }

        selectedPlannableId = plannable.id

        switch env.app {
        case .student, .teacher:
            switch plannable.plannableType {
            case .planner_note:
                let vc = PlannerAssembly.makeToDoDetailsViewController(plannable: plannable)
                env.router.show(vc, from: self, options: .detail)
            case .calendar_event:
                let vc = PlannerAssembly.makeEventDetailsViewController(eventId: plannable.id) { [delegate] output in
                    switch output {
                    case .didUpdate, .didDelete:
                        delegate?.plannerListWillRefresh()
                    case .didCancel:
                        break
                    }
                }
                env.router.show(vc, from: self, options: .detail)
            default:
                routeToPlannableDetailsAtUrl(plannable.htmlURL)
            }
        case .parent, .none:
            routeToPlannableDetailsAtUrl(plannable.htmlURL)
        }
    }

    private func routeToPlannableDetailsAtUrl(_ url: URL?) {
        guard let url else { return }

        let to = url.appendingQueryItems(URLQueryItem(name: "origin", value: "calendar"))
        env.router.route(to: to, from: self, options: .detail)
    }

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        delegate?.scrollViewWillBeginDragging?(scrollView)
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidScroll?(scrollView)
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        delegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
    }
}

class PlannerListCell: UITableViewCell {
    @IBOutlet weak var courseCode: UILabel!
    @IBOutlet weak var dueDate: UILabel!
    @IBOutlet weak var points: UILabel!
    @IBOutlet weak var pointsDivider: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var icon: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        pointsDivider.setText(pointsDivider.text, style: .textCellSupportingText)
        setupInstDisclosureIndicator()
    }

    func update(_ p: Plannable?) {
        accessibilityIdentifier = "PlannerList.event.\(p?.id ?? "")"

        let customColor = AppEnvironment.shared.app == .parent
            ? nil
            : p?.color.ensureContrast(against: .backgroundLightest)

        backgroundColor = .backgroundLightest
        selectedBackgroundView = ContextCellBackgroundView.create(color: customColor)

        icon.image = p?.icon()
        if let customColor {
            icon.tintColor = customColor
        }

        courseCode.setText(contextName(for: p), style: .textCellTopLabel)
        if let customColor {
            courseCode.textColor = customColor
        }

        title.setText(p?.title, style: .textCellTitle)

        let dueDateText = (p?.date).flatMap {
            DateFormatter.localizedString(from: $0, dateStyle: .medium, timeStyle: .short)
        }
        dueDate.setText(dueDateText, style: .textCellSupportingText)
        let pointsText: String? = p?.pointsPossible.flatMap {
            let format = String(localized: "g_points", bundle: .core)
            return String.localizedStringWithFormat(format, $0)
        }
        points.setText(pointsText, style: .textCellSupportingText)
        pointsDivider.isHidden = dueDate.text == nil || pointsText == nil
    }

    private func contextName(for plannable: Plannable?) -> String? {
        guard let plannable else { return nil }

        if plannable.plannableType != .planner_note {
            return plannable.contextName
        }

        if let contextName = plannable.contextName {
            return String(localized: "\(contextName) To Do", bundle: .core, comment: "<CourseName> To Do")
        } else {
            return String(localized: "To Do", bundle: .core)
        }
    }
}
