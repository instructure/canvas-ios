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

#import <Foundation/Foundation.h>

//! Project version number for CanvasKeymaster
FOUNDATION_EXPORT double CanvasKeymasterVersionNumber;

//! Project version string for CanvasKeymaster.
FOUNDATION_EXPORT const unsigned char CanvasKeymasterVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <CanvasKeymaster/PublicHeader.h>

NS_ASSUME_NONNULL_BEGIN

@import CanvasKit;

@class CanvasKeymaster;

@interface CanvasKeymaster : NSObject

+ (instancetype)theKeymaster;

/**
 The current client (last one delivered on
 `signalForCurrentClient`) or nil if not logged
 in
 */
@property (nonatomic, readonly, nullable) CKIClient *currentClient;


@property (nonatomic, readonly) NSString *logFilePath;

@property (nonatomic, readonly) NSInteger numberOfClients;

- (void)setupWithClient:(CKIClient *)client;
@end

@interface CKIClient (CanvasKeymaster)
+ (instancetype)currentClient;
@end

NS_ASSUME_NONNULL_END

#define TheKeymaster ([CanvasKeymaster theKeymaster])

#import <CanvasKeymaster/SupportTicketViewController.h>
#import <CanvasKeymaster/SupportTicketManager.h>
#import <CanvasKeymaster/FXKeychain+CKMKeyChain.h>
#import <CanvasKeymaster/SupportTicket.h>
