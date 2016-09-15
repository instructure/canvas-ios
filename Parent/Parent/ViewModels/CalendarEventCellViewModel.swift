//
//  CalendarEventCellViewModel.swift
//  Parent
//
//  Created by Brandon Pluim on 1/22/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import Foundation

import SoPersistent
import CalendarKit

struct CalendarEventCellViewModel: TableViewCellViewModel {
    
    let calendarObject: CalendarEventProtocol
    
    static func tableViewDidLoad(tableView: UITableView) {
        tableView.estimatedRowHeight = 80
        tableView.registerNib(UINib(nibName: "CalendarEventCell", bundle: NSBundle(forClass: AppDelegate.self)), forCellReuseIdentifier: "CalendarEventCellViewModel")
    }
    
    func cellForTableView(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier("CalendarEventCellViewModel", forIndexPath: indexPath) as? CalendarEventCell else {
            fatalError("Incorrect Cell Type Found Expected: CalendarEventTableViewCell")
        }
        
        cell.titleLabel.text = calendarObject.title
        cell.courseNameLabel.text = calendarObject.contextCode
        cell.typeImageView.image = imageFromType(calendarObject.type)
        
        return cell
    }
    
    func imageFromType(type: EventType)->UIImage? {
        switch(type) {
        case .Assignment:
            return UIImage(named: "icon_assignment_fill")
        case .Quiz:
            return UIImage(named: "icon_quiz_fill")
        case .Discussion:
            return UIImage(named: "icon_discussion_fill")
        case .CalendarEvent:
            return UIImage(named: "icon_calendar_event_fill")
        }
    }
    
}