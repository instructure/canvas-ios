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