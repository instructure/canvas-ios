//
//  CKIClient+CKIFile.h
//  CanvasKit
//
//  Created by Jason Larsen on 11/11/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "CKIClient.h"

@class CKIFile;
@class CKIFolder;
@class RACSignal;

@interface CKIClient (CKIFile)

- (RACSignal *)fetchFile:(NSString *)fileID;
- (RACSignal *)deleteFile:(CKIFile *)file;
- (RACSignal *)uploadFile:(NSData *)fileData ofType:(NSString *)fileType withName:(NSString *)name inFolder:(CKIFolder *)folder;

@end
