//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

#import <Foundation/Foundation.h>
#import <React/RCTViewManager.h>
#import <CanvasCore/CanvasCore-Swift.h>

@interface DocViewerManager: RCTViewManager
@end

@implementation DocViewerManager

RCT_EXPORT_MODULE()

- (UIView *)view {
    return [DocViewerWrapper new];
}

RCT_EXPORT_VIEW_PROPERTY(contentInset, UIEdgeInsets)
RCT_EXPORT_VIEW_PROPERTY(fallbackURL, NSString)
RCT_EXPORT_VIEW_PROPERTY(filename, NSString)
RCT_EXPORT_VIEW_PROPERTY(previewURL, NSString)

@end
