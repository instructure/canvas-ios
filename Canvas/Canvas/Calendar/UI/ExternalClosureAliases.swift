//
//  File.swift
//  Calendar
//
//  Created by Brandon Pluim on 4/29/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import UIKit

import CalendarKit

public typealias CalendarEventSelected = (calendarEvent: CalendarEvent) -> ()

public typealias DateSelected = (date: NSDate) -> ()
public typealias ShouldOperateOnDate = (date: NSDate) -> Bool

// UIActions
public typealias UIBarButtonItemAction = (sender: UIBarButtonItem) -> ()

public typealias ColorForContextID = (contextID: String) -> UIColor
public typealias RouteToURL = (url: NSURL) -> Void