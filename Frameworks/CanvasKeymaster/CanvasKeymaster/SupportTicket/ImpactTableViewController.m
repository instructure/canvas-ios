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

#import "ImpactTableViewController.h"

@interface ImpactTableViewController ()
@property (weak, nonatomic) IBOutlet UITableViewCell *casualQuestionCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *needHelpCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *somethingBrokenCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *stuckCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *emergencyCell;

@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *cells;

@end

@implementation ImpactTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.cells enumerateObjectsUsingBlock:^(UITableViewCell *cell, NSUInteger idx, BOOL *stop) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }];
    
    switch (self.ticket.impactValue) {
        case SupportTicketImpactLevelComment:
            self.casualQuestionCell.accessoryType = UITableViewCellAccessoryCheckmark;
            break;
        case SupportTicketImpactLevelNotUrgent:
            self.needHelpCell.accessoryType = UITableViewCellAccessoryCheckmark;
            break;
        case SupportTicketImpactLevelWorkaroundPossible:
            self.somethingBrokenCell.accessoryType = UITableViewCellAccessoryCheckmark;
            break;
        case SupportTicketImpactLevelBlocking:
            self.stuckCell.accessoryType = UITableViewCellAccessoryCheckmark;
            break;
        case SupportTicketImpactLevelEmergency:
            self.emergencyCell.accessoryType = UITableViewCellAccessoryCheckmark;
            break;
        default:
            break;
    }

    [self setupAccessibility];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Expecting cells to be sorted by severity
    if (indexPath.row == SupportTicketImpactLevelComment) {
        self.ticket.impactValue = SupportTicketImpactLevelComment;
        
    } else if (indexPath.row == SupportTicketImpactLevelNotUrgent) {
        self.ticket.impactValue = SupportTicketImpactLevelNotUrgent;
        
    } else if (indexPath.row == SupportTicketImpactLevelWorkaroundPossible) {
        self.ticket.impactValue = SupportTicketImpactLevelWorkaroundPossible;
        
    } else if (indexPath.row == SupportTicketImpactLevelBlocking) {
        self.ticket.impactValue = SupportTicketImpactLevelBlocking;
        
    } else if (indexPath.row == SupportTicketImpactLevelEmergency) {
        self.ticket.impactValue = SupportTicketImpactLevelEmergency;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setupAccessibility
{
    [self.casualQuestionCell setAccessibilityLabel:NSLocalizedString(@"Casual question or suggestion", nil)];
    [self.casualQuestionCell setAccessibilityIdentifier:@"ticketImpactCasualCell"];

    [self.needHelpCell setAccessibilityLabel:NSLocalizedString(@"I need help but it's not urgent", nil)];
    [self.needHelpCell setAccessibilityIdentifier:@"ticketImpactNeedHelpCell"];

    [self.somethingBrokenCell setAccessibilityLabel:NSLocalizedString(@"Something is broken but I can work around it", nil)];
    [self.somethingBrokenCell setAccessibilityIdentifier:@"ticketImpactSomethingBrokenCell"];

    [self.stuckCell setAccessibilityLabel:NSLocalizedString(@"I can't get things done until I hear back from you", nil)];
    [self.stuckCell setAccessibilityIdentifier:@"ticketImpactStuckCell"];

    [self.emergencyCell setAccessibilityLabel:NSLocalizedString(@"Extremely critical emergency", nil)];
    [self.emergencyCell setAccessibilityIdentifier:@"ticketImpactEmergencyCell"];
}

@end
