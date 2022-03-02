/**
 @file LFCGzipUtility.h
 @author Clint Harris (www.clintharris.net)
 
 Modified (added inflatefunction) By Jeremy Stone
 
 Note: The code in this file has been commented so as to be compatible with
 Doxygen, a tool for automatically generating HTML-based documentation from
 source code. See http://www.doxygen.org for more info.
 */

#import <Foundation/Foundation.h>
#import "zlib.h"

@interface LFCGzipUtility : NSObject
{
	
}

/***************************************************************************
 Uses zlib to compress the given data. Note that gzip headers will be added so
 that the data can be easily decompressed using a tool like WinZip, gunzip, etc.
 
 Note: Special thanks to Robbie Hanson of Deusty Designs for sharing sample code
 showing how deflateInit2() can be used to make zlib generate a compressed file
 with gzip headers:
 http://deusty.blogspot.com/2007/07/gzip-compressiondecompression.html
 
 @param pUncompressedData memory buffer of bytes to compress
 @return Compressed data as an NSData object
 */
+(NSData*) gzipData: (NSData*)pUncompressedData;

@end

// taken from cocos2d and slightly modified
int InflateMemoryWithHint(unsigned char *in, unsigned int inLength, unsigned char **out, unsigned int outLengthHint );
