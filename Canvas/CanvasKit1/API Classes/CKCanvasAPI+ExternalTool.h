//
//  CKCanvasAPI+LTI.h
//  CanvasKit
//
//  Created by derrick on 6/24/13.
//  Copyright (c) 2013 Instructure, Inc. All rights reserved.
//

#import "CKCanvasAPI.h"

@interface CKCanvasAPI (ExternalTool)
- (void)fetchExternalToolSessionURLForCanvasURL:(NSURL *)canvasExternalToolURL block:(void (^)(NSError *error, NSURL *externalURL))completion;
@end
