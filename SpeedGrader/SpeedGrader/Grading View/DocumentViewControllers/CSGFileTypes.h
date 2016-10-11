//
//  CSGFileTypes.h
//  SpeedGrader
//
//  Created by Brandon Pluim on 9/29/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const CSGImageDocumentPathExtensionPNG;
extern NSString * const CSGImageDocumentPathExtensionJPG;
extern NSString * const CSGImageDocumentPathExtensionJPEG;
extern NSString * const CSGImageDocumentPathExtensionGIF;

extern NSString * const CSGVideoDocumentPathExtensionMOV;
extern NSString * const CSGVideoDocumentPathExtensionMP4;
extern NSString * const CSGVideoDocumentPathExtensionMPV;
extern NSString * const CSGVideoDocumentPathExtension3GP;

extern NSString * const CSGAudioDocumentPathExtensionMP3;
extern NSString * const CSGAudioDocumentPathExtensionM4A;
extern NSString * const CSGAudioDocumentPathExtensionWMA;
extern NSString * const CSGAudioDocumentPathExtensionRM;

@interface CSGFileTypes : NSObject

+ (NSArray *)supportedSourceFileTypes;
+ (NSArray *)supportedImageFileTypes;
+ (NSArray *)supportedVideoFileTypes;
+ (NSArray *)supportedAudioFileTypes;

@end