/**
 @file LFCGzipUtility.m
 @author Clint Harris (www.clintharris.net)
 
 Note: The code in this file has been commented so as to be compatible with
 Doxygen, a tool for automatically generating HTML-based documentation from
 source code. See http://www.doxygen.org for more info.
 */

#import "LFCGzipUtility.h"

@implementation LFCGzipUtility

/*******************************************************************************
 See header for documentation.
 */
+(NSData*) gzipData: (NSData*)pUncompressedData
{
	/*
	 Special thanks to Robbie Hanson of Deusty Designs for sharing sample code
	 showing how deflateInit2() can be used to make zlib generate a compressed
	 file with gzip headers:
	 http://deusty.blogspot.com/2007/07/gzip-compressiondecompression.html
	 */
	
	if (!pUncompressedData || [pUncompressedData length] == 0)
	{
		NSLog(@"%s: Error: Can't compress an empty or null NSData object.", __func__);
		return nil;
	}
	
	/* Before we can begin compressing (aka "deflating") data using the zlib
	 functions, we must initialize zlib. Normally this is done by calling the
	 deflateInit() function; in this case, however, we'll use deflateInit2() so
	 that the compressed data will have gzip headers. This will make it easy to
	 decompress the data later using a tool like gunzip, WinZip, etc.
	 
	 deflateInit2() accepts many parameters, the first of which is a C struct of
	 type "z_stream" defined in zlib.h. The properties of this struct are used to
	 control how the compression algorithms work. z_stream is also used to
	 maintain pointers to the "input" and "output" byte buffers (next_in/out) as
	 well as information about how many bytes have been processed, how many are
	 left to process, etc. */
	z_stream zlibStreamStruct;
	zlibStreamStruct.zalloc    = Z_NULL; // Set zalloc, zfree, and opaque to Z_NULL so
	zlibStreamStruct.zfree     = Z_NULL; // that when we call deflateInit2 they will be
	zlibStreamStruct.opaque    = Z_NULL; // updated to use default allocation functions.
	zlibStreamStruct.total_out = 0; // Total number of output bytes produced so far
	zlibStreamStruct.next_in   = (Bytef*)[pUncompressedData bytes]; // Pointer to input bytes
	zlibStreamStruct.avail_in  = (unsigned int)[pUncompressedData length]; // Number of input bytes left to process
	
	/* Initialize the zlib deflation (i.e. compression) internals with deflateInit2().
	 The parameters are as follows:
	 
	 z_streamp strm - Pointer to a zstream struct
	 int level      - Compression level. Must be Z_DEFAULT_COMPRESSION, or between
	 0 and 9: 1 gives best speed, 9 gives best compression, 0 gives
	 no compression.
	 int method     - Compression method. Only method supported is "Z_DEFLATED".
	 int windowBits - Base two logarithm of the maximum window size (the size of
	 the history buffer). It should be in the range 8..15. Add
	 16 to windowBits to write a simple gzip header and trailer
	 around the compressed data instead of a zlib wrapper. The
	 gzip header will have no file name, no extra data, no comment,
	 no modification time (set to zero), no header crc, and the
	 operating system will be set to 255 (unknown).
	 int memLevel   - Amount of memory allocated for internal compression state.
	 1 uses minimum memory but is slow and reduces compression
	 ratio; 9 uses maximum memory for optimal speed. Default value
	 is 8.
	 int strategy   - Used to tune the compression algorithm. Use the value
	 Z_DEFAULT_STRATEGY for normal data, Z_FILTERED for data
	 produced by a filter (or predictor), or Z_HUFFMAN_ONLY to
	 force Huffman encoding only (no string match) */
    int initError = deflateInit2(&zlibStreamStruct, Z_DEFAULT_COMPRESSION, Z_DEFLATED, (15+16), 8, Z_DEFAULT_STRATEGY);
	if (initError != Z_OK)
	{
		NSString *errorMsg = nil;
		switch (initError)
		{
			case Z_STREAM_ERROR:
				errorMsg = @"Invalid parameter passed in to function.";
				break;
			case Z_MEM_ERROR:
				errorMsg = @"Insufficient memory.";
				break;
			case Z_VERSION_ERROR:
				errorMsg = @"The version of zlib.h and the version of the library linked do not match.";
				break;
			default:
				errorMsg = @"Unknown error code.";
				break;
		}
		NSLog(@"%s: deflateInit2() Error: \"%@\" Message: \"%s\"", __func__, errorMsg, zlibStreamStruct.msg);
		//		[errorMsg release];
		return nil;
	}
	
	// Create output memory buffer for compressed data. The zlib documentation states that
	// destination buffer size must be at least 0.1% larger than avail_in plus 12 bytes.
	NSMutableData *compressedData = [NSMutableData dataWithLength:[pUncompressedData length] * 1.01 + 12];
	
	int deflateStatus;
	do
	{
		// Store location where next byte should be put in next_out
		zlibStreamStruct.next_out = [compressedData mutableBytes] + zlibStreamStruct.total_out;
		
		// Calculate the amount of remaining free space in the output buffer
		// by subtracting the number of bytes that have been written so far
		// from the buffer's total capacity
		zlibStreamStruct.avail_out = (unsigned int)([compressedData length] - zlibStreamStruct.total_out);
		
		/* deflate() compresses as much data as possible, and stops/returns when
		 the input buffer becomes empty or the output buffer becomes full. If
		 deflate() returns Z_OK, it means that there are more bytes left to
		 compress in the input buffer but the output buffer is full; the output
		 buffer should be expanded and deflate should be called again (i.e., the
		 loop should continue to rune). If deflate() returns Z_STREAM_END, the
		 end of the input stream was reached (i.e.g, all of the data has been
		 compressed) and the loop should stop. */
		deflateStatus = deflate(&zlibStreamStruct, Z_FINISH);
		
	} while ( deflateStatus == Z_OK );
	
	// Check for zlib error and convert code to usable error message if appropriate
	if (deflateStatus != Z_STREAM_END)
	{
		NSString *errorMsg = nil;
		switch (deflateStatus)
		{
			case Z_ERRNO:
				errorMsg = @"Error occured while reading file.";
				break;
			case Z_STREAM_ERROR:
				errorMsg = @"The stream state was inconsistent (e.g., next_in or next_out was NULL).";
				break;
			case Z_DATA_ERROR:
				errorMsg = @"The deflate data was invalid or incomplete.";
				break;
			case Z_MEM_ERROR:
				errorMsg = @"Memory could not be allocated for processing.";
				break;
			case Z_BUF_ERROR:
				errorMsg = @"Ran out of output buffer for writing compressed bytes.";
				break;
			case Z_VERSION_ERROR:
				errorMsg = @"The version of zlib.h and the version of the library linked do not match.";
				break;
			default:
				errorMsg = @"Unknown error code.";
				break;
		}
		NSLog(@"%s: zlib error while attempting compression: \"%@\" Message: \"%s\"", __func__, errorMsg, zlibStreamStruct.msg);
		//		[errorMsg release];
		
		// Free data structures that were dynamically created for the stream.
		deflateEnd(&zlibStreamStruct);
		
		return nil;
	}
	// Free data structures that were dynamically created for the stream.
	deflateEnd(&zlibStreamStruct);
	[compressedData setLength: zlibStreamStruct.total_out];
	NSLog(@"%s: Compressed file from %d KB to %d KB", __func__, (int)[pUncompressedData length]/1024, (int)[compressedData length]/1024);
	
	return compressedData;
}

@end



// from cocos2d, un-zipping code:

#define BUFFER_INC_FACTOR (2)

static int inflateMemoryWithHintX(unsigned char *in, unsigned int inLength, unsigned char **out, unsigned int *outLength, unsigned int outlengthHint )
{
	/* ret value */
	int err = Z_OK;
	
	int bufferSize = outlengthHint;
	*out = (unsigned char*) malloc(bufferSize);
	
    z_stream d_stream; /* decompression stream */
    d_stream.zalloc = (alloc_func)0;
    d_stream.zfree = (free_func)0;
    d_stream.opaque = (voidpf)0;
	
    d_stream.next_in  = in;
    d_stream.avail_in = inLength;
	d_stream.next_out = *out;
	d_stream.avail_out = bufferSize;
	
	/* window size to hold 256k */
	if( (err = inflateInit2(&d_stream, 15 + 32)) != Z_OK )
		return err;
	
    for (;;) {
        err = inflate(&d_stream, Z_NO_FLUSH);
		
		if (err == Z_STREAM_END)
			break;
		
		switch (err) {
			case Z_NEED_DICT:
				err = Z_DATA_ERROR;
			case Z_DATA_ERROR:
			case Z_MEM_ERROR:
				inflateEnd(&d_stream);
				return err;
		}
		
		// not enough memory ?
		if (err != Z_STREAM_END) {
			
			unsigned char *tmp = realloc(*out, bufferSize * BUFFER_INC_FACTOR);
			
			/* not enough memory, ouch */
			if (! tmp ) {
				NSLog(@"ZipUtils: realloc failed");
				inflateEnd(&d_stream);
				return Z_MEM_ERROR;
			}
			/* only assign to *out if tmp is valid. it's not guaranteed that realloc will reuse the memory */
			*out = tmp;
			
			d_stream.next_out = *out + bufferSize;
			d_stream.avail_out = bufferSize;
			bufferSize *= BUFFER_INC_FACTOR;
		}
    }
	
	
	*outLength = bufferSize - d_stream.avail_out;
    err = inflateEnd(&d_stream);
	return err;
}

int InflateMemoryWithHint(unsigned char *in, unsigned int inLength, unsigned char **out, unsigned int outLengthHint )
{
	unsigned int outLength = 0;
	int err = inflateMemoryWithHintX((unsigned char*)in, inLength, out, &outLength, outLengthHint );
	
	if (err != Z_OK || *out == NULL) {
		if (err == Z_MEM_ERROR)
			NSLog(@"ZipUtils: Out of memory while decompressing map data!");
		
		else if (err == Z_VERSION_ERROR)
			NSLog(@"ZipUtils: Incompatible zlib version!");
		
		else if (err == Z_DATA_ERROR)
			NSLog(@"ZipUtils: Incorrect zlib compressed data!");
		
		else
			NSLog(@"ZipUtils: Unknown error while decompressing map data!");
		
		free(*out);
		*out = NULL;
		outLength = 0;
	}
	
	return outLength;
}



