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
    
    

#import <CanvasKit/CanvasKit.h>
@import CanvasCore;



@interface CKIClient (CBIClient)

/**
* Creates a copy of the client that can be used for fetching images.
*/
- (nonnull CKIClient *)imageClient;

@property (nonatomic, readonly, nonnull) Session *authSession;

@end

extern NSString * _Nonnull const CBICourseColorUpdatedNotification;
extern NSString * _Nonnull const CBICourseColorUpdatedCourseIDKey;
extern NSString * _Nonnull const CBICourseColorUpdatedValue;
