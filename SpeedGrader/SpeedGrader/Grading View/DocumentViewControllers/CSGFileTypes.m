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