//
//  LandingPageViewController.swift
//  iCanvas
//
//  Created by Kyle Longhurst on 8/3/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import UIKit

let landingPageOptions = ["Courses", "Calendar", "To-Do List", "Notifications", "Messages"]

enum LandingPageOptions: Int {
    case Courses = 0
    case Calendar = 1
    case Todo = 2
    case Notifications = 3
    case Messages = 4
}

public class LandingPageViewController: UITableViewController {
    private var currentUsersID: String
    private var currentLandingPageSettingsDictionary: [String : String]
    private var currentUserLandingPageSettings: LandingPageOptions
    
    // ---------------------------------------------
    // MARK: - Inits
    // ---------------------------------------------
    
    init (currentUserID: String) {
        currentUsersID = currentUserID
        currentLandingPageSettingsDictionary = [:]
        currentUserLandingPageSettings = LandingPageOptions.Courses
        if let settingsDictionary = NSUserDefaults.standardUserDefaults().objectForKey("landingPageSettings") as? [String : String] {
            currentLandingPageSettingsDictionary = settingsDictionary
            for (userID, landingPageSetting) in currentLandingPageSettingsDictionary {
                if userID == currentUsersID {
                    var storedLandingPageSetting: LandingPageOptions
                    switch landingPageSetting {
                        case "Courses":
                            storedLandingPageSetting = LandingPageOptions.Courses
                        case "Calendar":
                            storedLandingPageSetting = LandingPageOptions.Calendar
                        case "To-Do List":
                            storedLandingPageSetting = LandingPageOptions.Todo
                        case "Notifications":
                            storedLandingPageSetting = LandingPageOptions.Notifications
                        case "Messages":
                            storedLandingPageSetting = LandingPageOptions.Messages
                        default:
                            storedLandingPageSetting = LandingPageOptions.Courses
                    }
                    currentUserLandingPageSettings = storedLandingPageSetting
                    break
                } else {
                    currentUserLandingPageSettings = LandingPageOptions.Courses
                }
            }
        }
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    // ---------------------------------------------
    // MARK: - Life Cycle
    // ---------------------------------------------
    
    public override func viewDidLoad() {
        tableView.tableFooterView = UIView(frame: CGRectZero)

    }
    
    // ---------------------------------------------
    // MARK: - Delegate Methods
    // ---------------------------------------------
    
    public override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    public override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return landingPageOptions.count
    }
    
    private static let cellReuseIdentifier = "LandingPageSettingsCell"
    public override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = landingPageOptions[indexPath.row]
        if currentUserLandingPageSettings.rawValue == indexPath.row {
            cell.accessoryType  = UITableViewCellAccessoryType.Checkmark
            cell.setSelected(true, animated: false)
        }
        return cell
    }
    
    public override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Choose Landing Page"
        } else {
            return nil
        }
    }
    
    public override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        currentUserLandingPageSettings = LandingPageOptions(rawValue: indexPath.row)!
        currentLandingPageSettingsDictionary[currentUsersID] = landingPageOptions[indexPath.row]
        NSUserDefaults.standardUserDefaults().setObject(currentLandingPageSettingsDictionary, forKey: "landingPageSettings")
        tableView.reloadData()
    }
    
    public override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = UITableViewCellAccessoryType.None
    }
    
}