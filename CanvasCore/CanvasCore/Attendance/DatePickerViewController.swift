//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import UIKit

extension Calendar {
    var daysInWeek: Int {
        return Int(self.maximumRange(of: .weekday)?.count ?? 0)
    }
    
    func numberOfWeeksForMonth(of date: Date) -> Int {
        let weekRange = range(of: .weekOfMonth, in: .month, for: date)
        return weekRange?.count ?? 0
    }
}

protocol DatePickerDelegate: NSObjectProtocol {
    func didSelectDate(_ date: Date)
}

class DatePickerViewController: UIViewController {
    
    var initialDate = Date() {
        didSet {
            selectedDate = initialDate
        }
    }
    weak var delegate: DatePickerDelegate?
    
    fileprivate let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale.current
        return calendar
    }()
    fileprivate var collectionView: UICollectionView!
    fileprivate let layout = UICollectionViewFlowLayout()
    
    fileprivate let today = Date()
    fileprivate var earliestDate: Date!
    fileprivate var latestDate: Date!
    fileprivate var selectedDate = Date()
    
    static var monthHeaderFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "MMMM", options: 0, locale: Locale.current)
        return dateFormatter
    }()
    
    static var yearFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "YYYY", options: 0, locale: Locale.current)
        return dateFormatter
    }()

    static var a11yDayFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateStyle = .medium
        return dateFormatter
    }()

    static var a11yMonthFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "MMMM YYYY", options: 0, locale: Locale.current)
        return dateFormatter
    }()
    
    fileprivate var hasScrolledToInitialDate = false
    
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        let todayComponents = calendar.dateComponents([.year, .month, .day], from: Date())
        let startOfMonth = DateComponents(calendar: calendar, year: todayComponents.year!, month: todayComponents.month!, day: 1).date!
        
        var components = DateComponents()
        components.month = 24
        self.latestDate = calendar.date(byAdding: components, to: startOfMonth)!
        
        components.month = -24
        self.earliestDate = calendar.date(byAdding: components, to: startOfMonth)!
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        navigationItem.title = NSLocalizedString("Choose Date", tableName: "Localizable", bundle: .core, value: "", comment: "")
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done(_:)))
        
        layout.minimumLineSpacing = 0.0
        layout.minimumInteritemSpacing = 0.0
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(DatePickerDateCell.self, forCellWithReuseIdentifier: "DateCell")
        collectionView.register(DatePickerMonthHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "MonthHeaderView")
        
        collectionView.backgroundColor = .white
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
            collectionView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor),
        ])
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let itemWidth: CGFloat = floor((view.bounds.size.width - (2.0 * 16.0)) / CGFloat(calendar.daysInWeek))
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        layout.invalidateLayout()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !hasScrolledToInitialDate {
            scroll(to: initialDate, animated: false)
            hasScrolledToInitialDate = true
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        let newWidth = size.width - (2.0 * 16.0)
        let itemWidth: CGFloat = floor((newWidth) / CGFloat(calendar.daysInWeek))
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        layout.invalidateLayout()
    }
    
    func done(_ sender: Any?) {
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
    
    fileprivate func dateForFirstDay(inSection section: Int) -> Date {
        var components = DateComponents()
        components.month = section
        return calendar.date(byAdding: components, to: earliestDate)!
    }
    
    fileprivate func dateForCell(at indexPath: IndexPath) -> Date {
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
        return calendar.daysInWeek * calendar.numberOfWeeksForMonth(of: date)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DateCell", for: indexPath) as! DatePickerDateCell
        
        let firstDayInMonth = dateForFirstDay(inSection: indexPath.section)
        let cellDate = dateForCell(at: indexPath)
        
        let month = calendar.component(.month, from: cellDate)
        if month == calendar.component(.month, from: firstDayInMonth) {
            let day = calendar.component(.day, from: cellDate)
            cell.label.text = "\(day)"
            cell.label.accessibilityLabel = DatePickerViewController.a11yDayFormatter.string(from: cellDate)
            cell.isToday = calendar.isDateInToday(cellDate)
            cell.label.accessibilityTraits = cell.isToday ? UIAccessibilityTraitSelected : UIAccessibilityTraitNone
            cell.setIsHighlighted(calendar.isDate(selectedDate, inSameDayAs: cellDate))
        } else {
            cell.label.text = ""
            cell.setIsHighlighted(false)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "MonthHeaderView", for: indexPath) as! DatePickerMonthHeaderView
        
        let firstDayInSection = dateForFirstDay(inSection: indexPath.section)
        let sectionMonth = calendar.component(.month, from: firstDayInSection)
        
        view.yearLabel.isHidden = sectionMonth != 1
        view.yearLabel.accessibilityElementsHidden = true
        view.yearLabel.text = DatePickerViewController.yearFormatter.string(from: firstDayInSection)
        view.monthLabel.text = DatePickerViewController.monthHeaderFormatter.string(from: firstDayInSection)
        view.monthLabel.accessibilityTraits = UIAccessibilityTraitHeader
        view.monthLabel.accessibilityLabel = DatePickerViewController.a11yMonthFormatter.string(from: firstDayInSection)
        
        return view
    }
}

extension DatePickerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        if !hasScrolledToInitialDate {
//            scroll(to: initialDate, animated: false)
//            hasScrolledToInitialDate = true
//        }
        
        if calendar.isDate(selectedDate, inSameDayAs: dateForCell(at: indexPath)) && (collectionView.indexPathsForSelectedItems ?? []).count == 0 {
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? DatePickerDateCell else { return }
        selectedDate = dateForCell(at: indexPath)
        cell.setIsHighlighted(true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? DatePickerDateCell else { return }
        cell.setIsHighlighted(false)
    }
}

extension DatePickerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return layout.itemSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let firstDayInSection = dateForFirstDay(inSection: section)
        let sectionMonth = calendar.component(.month, from: firstDayInSection)
        
        let header = DatePickerMonthHeaderView(frame: CGRect(x: 0, y: 0, width: collectionView.bounds.size.width, height: 0))
        header.yearLabel.isHidden = sectionMonth != 1
        header.yearLabel.text = DatePickerViewController.yearFormatter.string(from: firstDayInSection)
        header.monthLabel.text = DatePickerViewController.monthHeaderFormatter.string(from: firstDayInSection)
        
        header.setNeedsLayout()
        header.layoutIfNeeded()
        
        let size = header.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        
        return size
    }
}
