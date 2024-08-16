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

import UIKit
import Core

protocol DatePickerDelegate: NSObjectProtocol {
    func didSelectDate(_ date: Date)
}

class DatePickerViewController: UIViewController {
    let initialDate: Date
    weak var delegate: DatePickerDelegate?

    let calendar = Calendar.current
    let daysInWeek: Int
    func numberOfWeeksForMonth(of date: Date) -> Int {
        let weekRange = calendar.range(of: .weekOfMonth, in: .month, for: date)
        return weekRange?.count ?? 0
    }

    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    let layout = UICollectionViewFlowLayout()

    let today = Clock.now
    let earliestDate: Date
    let latestDate: Date
    var selectedDate = Clock.now

    static var dayFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("d")
        return dateFormatter
    }()

    static var monthHeaderFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("MMMM")
        return dateFormatter
    }()

    static var yearFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("yyyy")
        return dateFormatter
    }()

    static var a11yDayFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter
    }()

    static var a11yMonthFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("MMMM yyyy")
        return dateFormatter
    }()

    var hasScrolledToInitialDate = false

    init(selected: Date, delegate: DatePickerDelegate?) {
        let todayComponents = calendar.dateComponents([.year, .month, .day], from: today)
        let startOfMonth = DateComponents(calendar: calendar, year: todayComponents.year!, month: todayComponents.month!, day: 1).date!

        var components = DateComponents()
        components.month = 24
        latestDate = calendar.date(byAdding: components, to: startOfMonth)!

        components.month = -24
        earliestDate = calendar.date(byAdding: components, to: startOfMonth)!

        daysInWeek = calendar.maximumRange(of: .weekday)?.count ?? 0
        initialDate = selected
        selectedDate = selected
        self.delegate = delegate

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .backgroundLightest

        navigationItem.title = String(localized: "Choose Date", bundle: .teacher)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done(_:)))

        layout.minimumLineSpacing = 0.0
        layout.minimumInteritemSpacing = 0.0

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(DatePickerDateCell.self, forCellWithReuseIdentifier: String(describing: DatePickerDateCell.self))
        collectionView.register(
            DatePickerMonthHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: String(describing: DatePickerMonthHeaderView.self)
        )

        collectionView.backgroundColor = .backgroundLightest
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.scrollsToTop = false
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.0),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.0),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateItemSize(available: view.bounds.width)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if !hasScrolledToInitialDate {
            scroll(to: initialDate, animated: false)
            hasScrolledToInitialDate = true
        }
    }

    func updateItemSize(available: CGFloat) {
        let itemWidth: CGFloat = floor((available - (2.0 * 16.0)) / CGFloat(daysInWeek))
        let size = CGSize(width: itemWidth, height: itemWidth)
        guard size != layout.itemSize else { return }
        layout.itemSize = size
        layout.invalidateLayout()
    }

    @objc func done(_ sender: Any?) {
        dismiss(animated: true, completion: {
            if !self.calendar.isDate(self.selectedDate, inSameDayAs: self.initialDate) {
                self.delegate?.didSelectDate(self.selectedDate)
            }
        })
    }

    func scroll(to date: Date, animated: Bool) {
        guard date > earliestDate && date < latestDate else { return }
        let components = calendar.dateComponents([.month, .day], from: earliestDate, to: date)

        let indexPath = IndexPath(item: components.day!, section: components.month!)
        collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
    }

    func dateForFirstDay(inSection section: Int) -> Date {
        var components = DateComponents()
        components.month = section
        return calendar.date(byAdding: components, to: earliestDate)!
    }

    func dateForCell(at indexPath: IndexPath) -> Date {
        let firstDayInMonth = dateForFirstDay(inSection: indexPath.section)
        let weekday = calendar.component(.weekday, from: firstDayInMonth) - calendar.firstWeekday

        let weekdayDeltaComponents = DateComponents(calendar: calendar, day: indexPath.item - weekday)
        let cellDate = calendar.date(byAdding: weekdayDeltaComponents, to: firstDayInMonth)!

        return cellDate
    }
}

extension DatePickerViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // 4 years, 2 back, 2 forward
        return 48
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let date = dateForFirstDay(inSection: section)
        return daysInWeek * numberOfWeeksForMonth(of: date)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: DatePickerDateCell = collectionView.dequeue(for: indexPath)

        let firstDayInMonth = dateForFirstDay(inSection: indexPath.section)
        let cellDate = dateForCell(at: indexPath)

        let month = calendar.component(.month, from: cellDate)
        if month == calendar.component(.month, from: firstDayInMonth) {
            cell.label.text = DatePickerViewController.dayFormatter.string(from: cellDate)
            cell.label.accessibilityLabel = DatePickerViewController.a11yDayFormatter.string(from: cellDate)
            cell.isToday = calendar.isDate(cellDate, inSameDayAs: today)
            cell.label.accessibilityTraits = cell.isToday ? UIAccessibilityTraits.selected : UIAccessibilityTraits.none
            cell.setIsHighlighted(calendar.isDate(selectedDate, inSameDayAs: cellDate))
        } else {
            cell.label.text = ""
            cell.setIsHighlighted(false)
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view: DatePickerMonthHeaderView = collectionView.dequeue(ofKind: kind, for: indexPath)

        let firstDayInSection = dateForFirstDay(inSection: indexPath.section)
        let sectionMonth = calendar.component(.month, from: firstDayInSection)

        view.yearLabel.isHidden = sectionMonth != 1
        view.yearLabel.accessibilityElementsHidden = true
        view.yearLabel.text = DatePickerViewController.yearFormatter.string(from: firstDayInSection)
        view.monthLabel.text = DatePickerViewController.monthHeaderFormatter.string(from: firstDayInSection)
        view.monthLabel.accessibilityTraits = UIAccessibilityTraits.header
        view.monthLabel.accessibilityLabel = DatePickerViewController.a11yMonthFormatter.string(from: firstDayInSection)

        return view
    }
}

extension DatePickerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if calendar.isDate(selectedDate, inSameDayAs: dateForCell(at: indexPath)) && collectionView.indexPathsForSelectedItems?.isEmpty != false {
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? DatePickerDateCell
        selectedDate = dateForCell(at: indexPath)
        cell?.setIsHighlighted(true)
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? DatePickerDateCell
        cell?.setIsHighlighted(false)
    }
}

extension DatePickerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return layout.itemSize
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let firstDayInSection = dateForFirstDay(inSection: section)
        let sectionMonth = calendar.component(.month, from: firstDayInSection)

        let header = DatePickerMonthHeaderView(frame: CGRect(x: 0, y: 0, width: collectionView.bounds.width, height: 0))
        header.yearLabel.isHidden = sectionMonth != 1
        header.yearLabel.text = DatePickerViewController.yearFormatter.string(from: firstDayInSection)
        header.monthLabel.text = DatePickerViewController.monthHeaderFormatter.string(from: firstDayInSection)

        header.setNeedsLayout()
        header.layoutIfNeeded()

        let size = header.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        return size
    }
}
