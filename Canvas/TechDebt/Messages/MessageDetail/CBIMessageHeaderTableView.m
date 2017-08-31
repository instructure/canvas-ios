//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
    
    

#import "CBIMessageHeaderTableView.h"

@implementation CBIMessageHeaderTableView

- (void)setUserInteractionEnabled:(BOOL)userInteractionEnabled
{
    // this prevents the tableview's subviews from resigning
    // first responder status when the tableview reloads.
    // It is necessary in order to resize the height of the
    // cell while typing without the keyboard disappearing.
    [super setUserInteractionEnabled:YES];
}

@end
