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
    
    

#import "CAKeyframeAnimation+Additions.h"

@implementation CAKeyframeAnimation (Additions)

// Animations are calling fromValue on CAKeyFrameAnimation which is causing a crash
// We should identify the issue but this is fixng the crash for now
- (id)fromValue
{
    return nil;
}

@end
