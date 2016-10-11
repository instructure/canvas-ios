//
//  CSGFileTypes.m
//  SpeedGrader
//
//  Created by Brandon Pluim on 9/29/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CSGFileTypes.h"

NSString *const CSGImageDocumentPathExtensionPNG = @"png";
NSString *const CSGImageDocumentPathExtensionJPG = @"jpg";
NSString *const CSGImageDocumentPathExtensionJPEG = @"jpeg";
NSString *const CSGImageDocumentPathExtensionGIF = @"gif";

NSString *const CSGVideoDocumentPathExtensionMOV = @"mov";
NSString *const CSGVideoDocumentPathExtensionMP4 = @"mp4";
NSString *const CSGVideoDocumentPathExtensionMPV = @"mpv";
NSString *const CSGVideoDocumentPathExtension3GP = @"3gp";

NSString *const CSGAudioDocumentPathExtensionMP3 = @"mp3";
NSString *const CSGAudioDocumentPathExtensionM4A = @"m4a";
NSString *const CSGAudioDocumentPathExtensionWMA = @"wma";
NSString *const CSGAudioDocumentPathExtensionRM = @"rm";

@implementation CSGFileTypes

+ (NSArray *)supportedSourceFileTypes {
    return  @[
              @"c",
              @"h",
              @"m",
              @"css",
              @"cpp",
              @"c++",
              @"cc",
              @"h",
              @"c#",
              @"cs",
              @"css",
              @"diff",
              @"patch",
              @"as",
              @"html",
              @"htm",
              @"java",
              @"js",
              @"tex",
              @"log",
              @"m4",
              @"pas",
              @"~pa",
              @"pl",
              @"php",
              @"php3",
              @"php4",
              @"php5",
              @"py",
              @"rb",
              @"scl",
              @"sh",
              @"bash",
              @"sql",
              @"tcl",
              @"xml",
              @"xhtml",
              @"xslt",
              @"xdl",
              @"xlnk",
              @"xsd",
              @"xsl",
              @"xspf",
              @"xul"];
}

+ (NSArray *)supportedImageFileTypes {
    return @[
             CSGImageDocumentPathExtensionPNG,
             CSGImageDocumentPathExtensionJPG,
             CSGImageDocumentPathExtensionJPEG,
             CSGImageDocumentPathExtensionGIF
             ];
}
+ (NSArray *)supportedVideoFileTypes {
    return @[
             CSGVideoDocumentPathExtension3GP,
             CSGVideoDocumentPathExtensionMOV,
             CSGVideoDocumentPathExtensionMP4,
             CSGVideoDocumentPathExtensionMPV
             ];
}

+ (NSArray *)supportedAudioFileTypes {
    return @[
             CSGAudioDocumentPathExtensionM4A,
             CSGAudioDocumentPathExtensionMP3,
             CSGAudioDocumentPathExtensionRM
             ];
}

@end