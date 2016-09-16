// SDURLCache.m
//
// Copyright (c) 2010-2011 Olivier Poitrey <rs@dailymotion.com>
// Modernized to use GCD by Peter Steinberger <steipete@gmail.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is furnished
// to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "SDURLCache.h"
#import <CommonCrypto/CommonDigest.h>

#define kAFURLCachePath @"SDNetworkingURLCache"
#define kAFURLCacheMaintenanceTime 5ull

#if !__has_feature(objc_arc)
#error "SDURLCache needs to be compiled with ARC enabled."
#endif

static NSTimeInterval const kAFURLCacheInfoDefaultMinCacheInterval = 5.0 * 60.0; // 5 minute
static NSString *const kAFURLCacheInfoFileName = @"cacheInfo.plist";
static NSString *const kAFURLCacheInfoAccessesKey = @"accesses";
static NSString *const kAFURLCacheInfoSizesKey = @"sizes";
static float const kAFURLCacheLastModFraction = 0.1f; // 10% since Last-Modified suggested by RFC2616 section 13.2.4
static float const kAFURLCacheDefault = 3600.0f; // Default cache expiration delay if none defined (1 hour)

/**
 Below is ragel source used to compile those tables. The output was polished / pretty-printed and tweaked from ragel.
 As the generated code is "hard" to debug, we store the code in http-date.r1
 
 shell% ragel -F1 http-date.rl
 shell% gcc -o http-date http-date.c
 shell% ./http-date 'Sun, 06 Nov 1994 08:49:37 GMT' 'Sunday, 06-Nov-94 08:49:37 GMT' 'Sun Nov  6 08:49:37 1994' 'Sat Dec 24 14:34:26 2037' 'Sunday, 06-Nov-94 08:49:37 GMT' 'Sun, 06 Nov 1994 08:49:37 GMT'
 */
static const char _httpDate_trans_keys[] = {
      0,   0,  70,  87, 114, 114, 105, 105,  32, 100,  65,  83, 112, 117, 114, 114,  32,
     32,  32,  57,  48,  57,  32,  32,  48,  57,  48,  57,  58,  58,  48,  57,  48,  57,
     58,  58,  48,  57,  48,  57,  32,  32,  48,  57,  48,  57,  48,  57,  48,  57, 103,
    103, 101, 101,  99,  99, 101, 101,  98,  98,  97, 117, 110, 110, 108, 110,  97,  97,
    114, 121, 111, 111, 118, 118,  99,  99, 116, 116, 101, 101, 112, 112,  32,  32,  48,
     57,  48,  57,  32,  32,  65,  83, 112, 117, 114, 114,  32,  32,  48,  57,  48,  57,
     48,  57,  48,  57,  32,  32,  48,  57,  48,  57,  58,  58,  48,  57,  48,  57,  58,
     58,  48,  57,  48,  57,  32,  32,  71,  71,  77,  77,  84,  84, 103, 103, 101, 101,
     99,  99, 101, 101,  98,  98,  97, 117, 110, 110, 108, 110,  97,  97, 114, 121, 111,
    111, 118, 118,  99,  99, 116, 116, 101, 101, 112, 112,  97,  97, 121, 121,  44,  44,
     32,  32,  48,  57,  48,  57,  45,  45,  65,  83, 112, 117, 114, 114,  45,  45,  48,
     57,  48,  57,  32,  32,  48,  57,  48,  57,  58,  58,  48,  57,  48,  57,  58,  58,
     48,  57,  48,  57,  32,  32,  71,  71,  77,  77,  84,  84, 103, 103, 101, 101,  99,
     99, 101, 101,  98,  98,  97, 117, 110, 110, 108, 110,  97,  97, 114, 121, 111, 111,
    118, 118,  99,  99, 116, 116, 101, 101, 112, 112, 111, 111, 110, 110,  97, 117, 116,
    116,  32, 117, 114, 114, 100, 100, 104, 117, 117, 117,  32, 114, 115, 115, 101, 101,
     32, 115, 101, 101, 100, 100,  32, 110, 101, 101,   0,   0,   0,   0,   0,   0,   0
};

static const char _httpDate_key_spans[] = {
     0, 18,  1,  1, 69, 19,  6,  1,  1, 26, 10,  1, 10, 10,  1, 10, 10,
     1, 10, 10,  1, 10, 10, 10, 10,  1,  1,  1,  1,  1, 21,  1,  3,  1,
     8,  1,  1,  1,  1,  1,  1,  1, 10, 10,  1, 19,  6,  1,  1, 10, 10,
    10, 10,  1, 10, 10,  1, 10, 10,  1, 10, 10,  1,  1,  1,  1,  1,  1,
     1,  1,  1, 21,  1,  3,  1,  8,  1,  1,  1,  1,  1,  1,  1,  1,  1,
     1, 10, 10,  1, 19,  6,  1,  1, 10, 10,  1, 10, 10,  1, 10, 10,  1,
    10, 10,  1,  1,  1,  1,  1,  1,  1,  1,  1, 21,  1,  3,  1,  8,  1,
     1,  1,  1,  1,  1,  1,  1, 21,  1, 86,  1,  1, 14,  1, 83,  1,  1,
    84,  1,  1, 79,  1,  0,  0,  0
};

static const short _httpDate_index_offsets[] = {
       0,    0,   19,   21,   23,   93,  113,  120,  122,  124,  151,  162,  164,  175,  186,  188,  199,
     210,  212,  223,  234,  236,  247,  258,  269,  280,  282,  284,  286,  288,  290,  312,  314,  318,
     320,  329,  331,  333,  335,  337,  339,  341,  343,  354,  365,  367,  387,  394,  396,  398,  409,
     420,  431,  442,  444,  455,  466,  468,  479,  490,  492,  503,  514,  516,  518,  520,  522,  524,
     526,  528,  530,  532,  554,  556,  560,  562,  571,  573,  575,  577,  579,  581,  583,  585,  587,
     589,  591,  602,  613,  615,  635,  642,  644,  646,  657,  668,  670,  681,  692,  694,  705,  716,
     718,  729,  740,  742,  744,  746,  748,  750,  752,  754,  756,  758,  780,  782,  786,  788,  797,
     799,  801,  803,  805,  807,  809,  811,  813,  835,  837,  924,  926,  928,  943,  945, 1029, 1031,
    1033, 1118, 1120, 1122, 1202, 1204, 1205, 1206
};

static const unsigned char _httpDate_indicies[] = {
      0,   1,   1,   1,   1,   1,   1,   2,   1,   1,   1,   1,   1,   3,   4,   1,   1,
      5,   1,   6,   1,   7,   1,   8,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,
      1,   9,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,
      1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,
      1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,
      1,   1,   1,   1,   1,   1,  10,   1,  11,   1,   1,  12,   1,  13,   1,   1,   1,
     14,   1,   1,  15,  16,  17,   1,   1,   1,  18,   1,  19,   1,   1,   1,   1,  20,
      1,  21,   1,  22,   1,  23,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,
      1,   1,   1,   1,  24,  24,  24,  24,  24,  24,  24,  24,  24,  24,   1,  25,  25,
     25,  25,  25,  25,  25,  25,  25,  25,   1,  26,   1,  27,  27,  27,  27,  27,  27,
     27,  27,  27,  27,   1,  28,  28,  28,  28,  28,  28,  28,  28,  28,  28,   1,  29,
      1,  30,  30,  30,  30,  30,  30,  30,  30,  30,  30,   1,  31,  31,  31,  31,  31,
     31,  31,  31,  31,  31,   1,  32,   1,  33,  33,  33,  33,  33,  33,  33,  33,  33,
     33,   1,  34,  34,  34,  34,  34,  34,  34,  34,  34,  34,   1,  35,   1,  36,  36,
     36,  36,  36,  36,  36,  36,  36,  36,   1,  37,  37,  37,  37,  37,  37,  37,  37,
     37,  37,   1,  38,  38,  38,  38,  38,  38,  38,  38,  38,  38,   1,  39,  39,  39,
     39,  39,  39,  39,  39,  39,  39,   1,  40,   1,  41,   1,  42,   1,  43,   1,  44,
      1,  45,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,
      1,   1,   1,   1,  46,   1,  47,   1,  48,   1,  49,   1,  50,   1,  51,   1,   1,
      1,   1,   1,   1,  52,   1,  53,   1,  54,   1,  55,   1,  56,   1,  57,   1,  58,
      1,  59,   1,  60,  60,  60,  60,  60,  60,  60,  60,  60,  60,   1,  61,  61,  61,
     61,  61,  61,  61,  61,  61,  61,   1,  62,   1,  63,   1,   1,  64,   1,  65,   1,
      1,   1,  66,   1,   1,  67,  68,  69,   1,   1,   1,  70,   1,  71,   1,   1,   1,
      1,  72,   1,  73,   1,  74,   1,  75,  75,  75,  75,  75,  75,  75,  75,  75,  75,
      1,  76,  76,  76,  76,  76,  76,  76,  76,  76,  76,   1,  77,  77,  77,  77,  77,
     77,  77,  77,  77,  77,   1,  78,  78,  78,  78,  78,  78,  78,  78,  78,  78,   1,
     79,   1,  80,  80,  80,  80,  80,  80,  80,  80,  80,  80,   1,  81,  81,  81,  81,
     81,  81,  81,  81,  81,  81,   1,  82,   1,  83,  83,  83,  83,  83,  83,  83,  83,
     83,  83,   1,  84,  84,  84,  84,  84,  84,  84,  84,  84,  84,   1,  85,   1,  86,
     86,  86,  86,  86,  86,  86,  86,  86,  86,   1,  87,  87,  87,  87,  87,  87,  87,
     87,  87,  87,   1,  88,   1,  89,   1,  90,   1,  91,   1,  92,   1,  93,   1,  94,
      1,  95,   1,  96,   1,  97,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,
      1,   1,   1,   1,   1,   1,   1,   1,  98,   1,  99,   1, 100,   1, 101,   1, 102,
      1, 103,   1,   1,   1,   1,   1,   1, 104,   1, 105,   1, 106,   1, 107,   1, 108,
      1, 109,   1, 110,   1, 111,   1, 112,   1, 113,   1, 114,   1, 115, 115, 115, 115,
    115, 115, 115, 115, 115, 115,   1, 116, 116, 116, 116, 116, 116, 116, 116, 116, 116,
      1, 117,   1, 118,   1,   1, 119,   1, 120,   1,   1,   1, 121,   1,   1, 122, 123,
    124,   1,   1,   1, 125,   1, 126,   1,   1,   1,   1, 127,   1, 128,   1, 129,   1,
    130, 130, 130, 130, 130, 130, 130, 130, 130, 130,   1, 131, 131, 131, 131, 131, 131,
    131, 131, 131, 131,   1, 132,   1, 133, 133, 133, 133, 133, 133, 133, 133, 133, 133,
      1, 134, 134, 134, 134, 134, 134, 134, 134, 134, 134,   1, 135,   1, 136, 136, 136,
    136, 136, 136, 136, 136, 136, 136,   1, 137, 137, 137, 137, 137, 137, 137, 137, 137,
    137,   1, 138,   1, 139, 139, 139, 139, 139, 139, 139, 139, 139, 139,   1, 140, 140,
    140, 140, 140, 140, 140, 140, 140, 140,   1, 141,   1, 142,   1, 143,   1, 144,   1,
    145,   1, 146,   1, 147,   1, 148,   1, 149,   1, 150,   1,   1,   1,   1,   1,   1,
      1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1, 151,   1, 152,   1,
    153,   1, 154,   1, 155,   1, 156,   1,   1,   1,   1,   1,   1, 157,   1, 158,   1,
    159,   1, 160,   1, 161,   1, 162,   1, 163,   1, 164,   1,   7,   1, 165,   1,   1,
      1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,
    164,   1, 166,   1,   8,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   9,
      1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,
      1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,
      1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,
      1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,
      1,   1,   1,   1, 167,   1, 168,   1,  10,   1, 169,   1,   1,   1,   1,   1,   1,
      1,   1,   1,   1,   1,   1, 170,   1, 171,   1,   8,   1,   1,   1,   1,   1,   1,
      1,   1,   1,   1,   1,   9,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,
      1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,
      1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,
      1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,
      1,   1,   1,   1,   1,   1,   1, 172,   1, 168,   1, 173,   1,   8,   1,   1,   1,
      1,   1,   1,   1,   1,   1,   1,   1,   9,   1,   1,   1,   1,   1,   1,   1,   1,
      1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,
      1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,
      1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,
      1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1, 168,   1, 174,   1, 175,   1,
      8,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   9,   1,   1,   1,   1,
      1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,
      1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,
      1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,
      1,   1,   1,   1,   1,   1,   1,   1,   1,   1, 176,   1, 172,   1,   1,   1,   1,
      0
};

static const unsigned char _httpDate_trans_targs[] = {
      2,   0, 124, 126, 131, 137,   3,   4,   5,  41,  82,   6,  26,  28,  30,  33,  35,
     37,  39,   7,  25,   8,   9,  10,  10,  11,  12,  13,  14,  15,  16,  17,  18,  19,
     20,  21,  22,  23,  24, 141,   8,  27,   8,  29,   8,  31,  32,   8,   8,   8,  34,
      8,   8,  36,   8,  38,   8,  40,   8,  42,  43,  44,  45,  46,  67,  69,  71,  74,
     76,  78,  80,  47,  66,  48,  49,  50,  51,  52,  53,  54,  55,  56,  57,  58,  59,
     60,  61,  62,  63,  64,  65, 142,  48,  68,  48,  70,  48,  72,  73,  48,  48,  48,
     75,  48,  48,  77,  48,  79,  48,  81,  48,  83,  84,  85,  86,  87,  88,  89,  90,
    109, 111, 113, 116, 118, 120, 122,  91, 108,  92,  93,  94,  95,  96,  97,  98,  99,
    100, 101, 102, 103, 104, 105, 106, 107, 143,  92, 110,  92, 112,  92, 114, 115,  92,
     92,  92, 117,  92,  92, 119,  92, 121,  92, 123,  92, 125, 127, 128, 129, 130, 132,
    135, 133, 134, 136, 138, 139, 140
};

static const char _httpDate_trans_actions[] = {
     0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
     0,  0,  0,  0,  1,  0,  0,  2,  2,  0,  3,  3,  0,  4,  4,  0,  5,
     5,  0,  6,  6,  6,  6,  7,  0,  8,  0,  9,  0,  0, 10, 11, 12,  0,
    13, 14,  0, 15,  0, 16,  0, 17,  0,  2,  2,  0,  0,  0,  0,  0,  0,
     0,  0,  0,  0,  0,  1,  0,  6,  6,  6,  6,  0,  3,  3,  0,  4,  4,
     0,  5,  5,  0,  0,  0,  0,  7,  0,  8,  0,  9,  0,  0, 10, 11, 12,
     0, 13, 14,  0, 15,  0, 16,  0, 17,  0,  0,  0,  0,  2,  2,  0,  0,
     0,  0,  0,  0,  0,  0,  0,  0,  0,  1,  0,  6, 18,  0,  3,  3,  0,
     4,  4,  0,  5,  5,  0,  0,  0,  0,  7,  0,  8,  0,  9,  0,  0, 10,
    11, 12,  0, 13, 14,  0, 15,  0, 16,  0, 17,  0,  0,  0,  0,  0,  0,
     0,  0,  0,  0,  0,  0,  0
};

static const char _httpDate_eof_actions[] = {
     0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
     0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
     0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
     0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
     0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
     0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
     0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
     0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
     0,  0,  0,  0,  0, 19, 20, 21
};

static NSDate *_parseHTTPDate(const char *buf, size_t bufLen) {
    const char *p = buf, *pe = p + bufLen, *eof = pe;
    int parsed = 0, cs = 1;
    NSDate *date = NULL;

    CFGregorianDate gdate;
    memset(&gdate, 0, sizeof(CFGregorianDate));

    {
        int _slen, _trans;
        const char *_keys;
        const unsigned char *_inds;
        if(p  == pe) { goto _test_eof; }
    _resume:
        _keys  = _httpDate_trans_keys + (cs << 1);
        _inds  = _httpDate_indicies   + _httpDate_index_offsets[cs];
        _slen  = _httpDate_key_spans[cs];
        _trans = _inds[(_slen > 0) && (_keys[0] <= (*p)) && ((*p) <= _keys[1]) ? (*p) - _keys[0] : _slen];
        cs     = _httpDate_trans_targs[_trans];

        if(_httpDate_trans_actions[_trans] == 0) { goto _again; }

        switch(_httpDate_trans_actions[_trans]) {
            case 6:  gdate.year   = gdate.year * 10 + ((*p) - '0');                     break;
            case 18: gdate.year   = gdate.year * 10 + ((*p) - '0'); gdate.year += 1900; break;
            case 10: gdate.month  =  1; break;
            case 9:  gdate.month  =  2; break;
            case 13: gdate.month  =  3; break;
            case 1:  gdate.month  =  4; break;
            case 14: gdate.month  =  5; break;
            case 12: gdate.month  =  6; break;
            case 11: gdate.month  =  7; break;
            case 7:  gdate.month  =  8; break;
            case 17: gdate.month  =  9; break;
            case 16: gdate.month  = 10; break;
            case 15: gdate.month  = 11; break;
            case 8:  gdate.month  = 12; break;
            case 2:  gdate.day    = gdate.day    * 10   + ((*p) - '0'); break;
            case 3:  gdate.hour   = gdate.hour   * 10   + ((*p) - '0'); break;
            case 4:  gdate.minute = gdate.minute * 10   + ((*p) - '0'); break;
            case 5:  gdate.second = gdate.second * 10.0 + ((*p) - '0'); break;
        }

    _again:
        if(  cs ==  0) { goto _out;    }
        if(++p  != pe) { goto _resume; }
    _test_eof: {}
        if(p == eof) {
            switch(_httpDate_eof_actions[cs]) {
                case 19: parsed = 1; break;
                case 20: parsed = 1; break;
                case 21: parsed = 1; break;
            }
        }

    _out: {}
    }

    static CFTimeZoneRef gmtTimeZone;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ gmtTimeZone = CFTimeZoneCreateWithTimeIntervalFromGMT(NULL, 0.0); });

    if(parsed == 1) { date = [NSDate dateWithTimeIntervalSinceReferenceDate:CFGregorianDateGetAbsoluteTime(gdate, gmtTimeZone)]; }

    return(date);
}


@implementation NSCachedURLResponse(NSCoder)

// This is an intentional override of the default behavior. Silence the warning. (supported by Xcode 4.3 and above)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.data forKey:@"data"];
    [coder encodeObject:self.response forKey:@"response"];
    [coder encodeObject:self.userInfo forKey:@"userInfo"];
    [coder encodeInt:self.storagePolicy forKey:@"storagePolicy"];
}

- (id)initWithCoder:(NSCoder *)coder {
    return [self initWithResponse:[coder decodeObjectForKey:@"response"]
                             data:[coder decodeObjectForKey:@"data"]
                         userInfo:[coder decodeObjectForKey:@"userInfo"]
                    storagePolicy:[coder decodeIntForKey:@"storagePolicy"]];
}

#pragma clang diagnostic pop

@end

// deadlock-free variant of dispatch_sync
void dispatch_sync_afreentrant(dispatch_queue_t queue, dispatch_block_t block);
inline void dispatch_sync_afreentrant(dispatch_queue_t queue, dispatch_block_t block) {
    dispatch_get_current_queue() == queue ? block() : dispatch_sync(queue, block);
}

void dispatch_async_afreentrant(dispatch_queue_t queue, dispatch_block_t block);
inline void dispatch_async_afreentrant(dispatch_queue_t queue, dispatch_block_t block) {
	dispatch_get_current_queue() == queue ? block() : dispatch_async(queue, block);
}

@interface SDURLCache ()
@property (nonatomic, retain) NSString *diskCachePath;
@property (nonatomic, retain) NSMutableDictionary *diskCacheInfo;
- (void)periodicMaintenance;
@end

@implementation SDURLCache

#pragma mark SDURLCache (tools)

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    NSString *string = request.URL.absoluteString;
    NSRange hash = [string rangeOfString:@"#"];
    if (hash.location == NSNotFound)
        return request;
    
    NSMutableURLRequest *copy = [request mutableCopy];
    copy.URL = [NSURL URLWithString:[string substringToIndex:hash.location]];
    return copy;
}

+ (NSString *)cacheKeyForURL:(NSURL *)url {
    const char *str = [url.absoluteString UTF8String];
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, strlen(str), r);
    static NSString *cacheFormatVersion = @"2";
    return [NSString stringWithFormat:@"%@_%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            cacheFormatVersion, r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
}

#pragma mark SDURLCache (private)

static dispatch_queue_t get_disk_cache_queue() {
    static dispatch_once_t onceToken;
    static dispatch_queue_t _diskCacheQueue;
	dispatch_once(&onceToken, ^{
		_diskCacheQueue = dispatch_queue_create("com.petersteinberger.disk-cache.processing", NULL);
	});
	return _diskCacheQueue;
}

static dispatch_queue_t get_disk_io_queue() {
    static dispatch_queue_t _diskIOQueue;
    static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_diskIOQueue = dispatch_queue_create("com.petersteinberger.disk-cache.io", NULL);
	});
	return _diskIOQueue;
}

- (dispatch_source_t)maintenanceTimer {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        _maintenanceTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        if (_maintenanceTimer) {
            dispatch_source_set_timer(_maintenanceTimer, dispatch_walltime(DISPATCH_TIME_NOW, kAFURLCacheMaintenanceTime * NSEC_PER_SEC), 
                                      kAFURLCacheMaintenanceTime * NSEC_PER_SEC, kAFURLCacheMaintenanceTime/2 * NSEC_PER_SEC);
            __block SDURLCache *blockSelf = self;
            dispatch_source_set_event_handler(_maintenanceTimer, ^{
                [blockSelf periodicMaintenance];
                
                // will abuse cache queue to lock timer
                dispatch_async_afreentrant(get_disk_cache_queue(), ^{
                    dispatch_suspend(_maintenanceTimer); // pause timer
                    _timerPaused = YES;
                });            
            });
            // initially wake up timer
            dispatch_resume(_maintenanceTimer);
        }
    });
    return _maintenanceTimer;
}

/*
 * Parse HTTP Date: http://www.w3.org/Protocols/rfc2616/rfc2616-sec3.html#sec3.3.1
 */
+ (NSDate *)dateFromHttpDateString:(NSString *)httpDate {
    char stringBuffer[256];
    size_t stringLength = (size_t)CFStringGetLength((__bridge CFStringRef)httpDate);
    const char *cStringPtr = (const char *)CFStringGetCStringPtr((__bridge CFStringRef)httpDate, kCFStringEncodingMacRoman);
    if(cStringPtr == NULL) {
        CFIndex usedBytes = 0L, convertedCount = 0L;
        convertedCount = CFStringGetBytes((__bridge CFStringRef)httpDate, CFRangeMake(0L, (CFIndex)stringLength), kCFStringEncodingUTF8, '?', NO, (UInt8 *)stringBuffer, sizeof(stringBuffer) - 1L, &usedBytes);
        if(((size_t)convertedCount != stringLength) || (usedBytes < 0L)) { return(NULL); }
        stringBuffer[usedBytes] = '\0';
        cStringPtr = (const char *)stringBuffer;
    }
    return(_parseHTTPDate(cStringPtr, stringLength));
}

/*
 * This method tries to determine the expiration date based on a response headers dictionary.
 */
+ (NSDate *)expirationDateFromHeaders:(NSDictionary *)headers withStatusCode:(NSInteger)status {
    if (status != 200 && status != 203 && status != 300 && status != 301 && status != 302 && status != 307 && status != 410) {
        // Uncacheable response status code
        return nil;
    }
    
    // Check Pragma: no-cache
    NSString *pragma = [headers objectForKey:@"Pragma"];
    if (pragma && [pragma isEqualToString:@"no-cache"]) {
        // Uncacheable response
        return nil;
    }
    
    // Define "now" based on the request
    NSString *date = [headers objectForKey:@"Date"];
    // If no Date: header, define now from local clock
    NSDate *now = date ? [SDURLCache dateFromHttpDateString:date] : [NSDate date];
    
    // Look at info from the Cache-Control: max-age=n header
    NSString *cacheControl = [[headers objectForKey:@"Cache-Control"] lowercaseString];
    if (cacheControl)
    {
        NSRange foundRange = [cacheControl rangeOfString:@"no-store"];
        if (foundRange.length > 0) {
            // Can't be cached
            return nil;
        }
        
        NSInteger maxAge;
        foundRange = [cacheControl rangeOfString:@"max-age"];
        if (foundRange.length > 0) {
            NSScanner *cacheControlScanner = [NSScanner scannerWithString:cacheControl];
            [cacheControlScanner setScanLocation:foundRange.location + foundRange.length];
            [cacheControlScanner scanString:@"=" intoString:nil];
            if ([cacheControlScanner scanInteger:&maxAge]) {
                return maxAge > 0 ? [[NSDate alloc] initWithTimeInterval:maxAge sinceDate:now] : nil;
            }
        }
    }
    
    // If not Cache-Control found, look at the Expires header
    NSString *expires = [headers objectForKey:@"Expires"];
    if (expires) {
        NSTimeInterval expirationInterval = 0;
        NSDate *expirationDate = [SDURLCache dateFromHttpDateString:expires];
        if (expirationDate) {
            expirationInterval = [expirationDate timeIntervalSinceDate:now];
        }
        if (expirationInterval > 0) {
            // Convert remote expiration date to local expiration date
            return [NSDate dateWithTimeIntervalSinceNow:expirationInterval];
        }
        else {
            // If the Expires header can't be parsed or is expired, do not cache
            return nil;
        }
    }
    
    if (status == 302 || status == 307) {
        // If not explict cache control defined, do not cache those status
        return nil;
    }
    
    // If no cache control defined, try some heristic to determine an expiration date
    NSString *lastModified = [headers objectForKey:@"Last-Modified"];
    if (lastModified) {
        NSTimeInterval age = 0;
        NSDate *lastModifiedDate = [SDURLCache dateFromHttpDateString:lastModified];
        if (lastModifiedDate) {
            // Define the age of the document by comparing the Date header with the Last-Modified header
            age = [now timeIntervalSinceDate:lastModifiedDate];
        }
        return age > 0 ? [NSDate dateWithTimeIntervalSinceNow:(age * kAFURLCacheLastModFraction)] : nil;
    }
    
    // If nothing permitted to define the cache expiration delay nor to restrict its cacheability, use a default cache expiration delay
    return [[NSDate alloc] initWithTimeInterval:kAFURLCacheDefault sinceDate:now];
}

- (NSMutableDictionary *)diskCacheInfo {
    if (!_diskCacheInfo) {
        dispatch_sync_afreentrant(get_disk_cache_queue(), ^{
            if (!_diskCacheInfo) { // Check again, maybe another thread created it while waiting for the mutex
                _diskCacheInfo = [[NSMutableDictionary alloc] initWithContentsOfFile:[_diskCachePath stringByAppendingPathComponent:kAFURLCacheInfoFileName]];
                if (!_diskCacheInfo) {
                    _diskCacheInfo = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                      [NSMutableDictionary dictionary], kAFURLCacheInfoAccessesKey,
                                      [NSMutableDictionary dictionary], kAFURLCacheInfoSizesKey,
                                      nil];
                }
                _diskCacheInfoDirty = NO;
                NSArray *sizes = [[_diskCacheInfo objectForKey:kAFURLCacheInfoSizesKey] allValues];
                _diskCacheUsage = [[sizes valueForKeyPath:@"@sum.self"] unsignedIntegerValue];
                
                // create maintenance timer
                [self maintenanceTimer];
            }
        });
    }
    
    return _diskCacheInfo;
}

- (void)createDiskCachePath {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        if (![fileManager fileExistsAtPath:_diskCachePath]) {
            [fileManager createDirectoryAtPath:_diskCachePath
                   withIntermediateDirectories:YES
                                    attributes:nil
                                         error:NULL];
        }
    });
}

- (void)saveCacheInfo {
    [self createDiskCachePath];
    dispatch_async_afreentrant(get_disk_cache_queue(), ^{
        // Previous versions of SDURLCache stored a diskUsage key that could go wrong, just get rid of it.
        [self.diskCacheInfo removeObjectForKey:@"diskUsage"];
        NSData *data = [NSPropertyListSerialization dataFromPropertyList:self.diskCacheInfo format:NSPropertyListBinaryFormat_v1_0 errorDescription:NULL];
        if (data) {
            [data writeToFile:[_diskCachePath stringByAppendingPathComponent:kAFURLCacheInfoFileName] atomically:YES];
        }
        
        _diskCacheInfoDirty = NO;
    });
}

- (void)removeCachedResponseForCachedKeys:(NSArray *)cacheKeys {
    dispatch_async_afreentrant(get_disk_cache_queue(), ^{
        @autoreleasepool {
            NSEnumerator *enumerator = [cacheKeys objectEnumerator];
            NSString *cacheKey;
            
            NSMutableDictionary *accesses = [self.diskCacheInfo objectForKey:kAFURLCacheInfoAccessesKey];
            NSMutableDictionary *sizes = [self.diskCacheInfo objectForKey:kAFURLCacheInfoSizesKey];
            NSFileManager *fileManager = [[NSFileManager alloc] init];
            
            while ((cacheKey = [enumerator nextObject])) {
                NSUInteger cacheItemSize = [[sizes objectForKey:cacheKey] unsignedIntegerValue];
                [accesses removeObjectForKey:cacheKey];
                [sizes removeObjectForKey:cacheKey];
                [fileManager removeItemAtPath:[_diskCachePath stringByAppendingPathComponent:cacheKey] error:NULL];
                
                _diskCacheUsage -= cacheItemSize;
            }
        }
    });
}

- (void)balanceDiskUsage {
    if (_diskCacheUsage < self.diskCapacity) {
        return; // Already done
    }
    
    dispatch_async_afreentrant(get_disk_cache_queue(), ^{
        NSMutableArray *keysToRemove = [NSMutableArray array];
        
        // Apply LRU cache eviction algorithm while disk usage outreach capacity
        NSDictionary *sizes = [self.diskCacheInfo objectForKey:kAFURLCacheInfoSizesKey];
        
        NSInteger capacityToSave = _diskCacheUsage - self.diskCapacity;
        NSArray *sortedKeys = [[self.diskCacheInfo objectForKey:kAFURLCacheInfoAccessesKey] keysSortedByValueUsingSelector:@selector(compare:)];
        NSEnumerator *enumerator = [sortedKeys objectEnumerator];
        NSString *cacheKey;
        
        while (capacityToSave > 0 && (cacheKey = [enumerator nextObject])) {
            [keysToRemove addObject:cacheKey];
            capacityToSave -= [(NSNumber *)[sizes objectForKey:cacheKey] unsignedIntegerValue];
        }
        
        [self removeCachedResponseForCachedKeys:keysToRemove];
        [self saveCacheInfo];
    });
}


- (void)storeRequestToDisk:(NSURLRequest *)request response:(NSCachedURLResponse *)cachedResponse {
    NSString *cacheKey = [SDURLCache cacheKeyForURL:request.URL];
    NSString *cacheFilePath = [_diskCachePath stringByAppendingPathComponent:cacheKey];
    
    [self createDiskCachePath];
    
    // Archive the cached response on disk
    if (![NSKeyedArchiver archiveRootObject:cachedResponse toFile:cacheFilePath]) {
        // Caching failed for some reason
        return;
    }
    
    // Update disk usage info
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSNumber *cacheItemSize = [[fileManager attributesOfItemAtPath:cacheFilePath error:NULL] objectForKey:NSFileSize];
    
    dispatch_async_afreentrant(get_disk_cache_queue(), ^{
        NSNumber *previousCacheItemSize = [[self.diskCacheInfo objectForKey:kAFURLCacheInfoSizesKey] objectForKey:cacheKey];
        _diskCacheUsage -= [previousCacheItemSize unsignedIntegerValue];
        _diskCacheUsage += [cacheItemSize unsignedIntegerValue];
        
        // Update cache info for the stored item
        [(NSMutableDictionary *)[self.diskCacheInfo objectForKey:kAFURLCacheInfoAccessesKey] setObject:[NSDate date] forKey:cacheKey];
        [(NSMutableDictionary *)[self.diskCacheInfo objectForKey:kAFURLCacheInfoSizesKey] setObject:cacheItemSize forKey:cacheKey];
        
        [self saveCacheInfo];
        
        // start timer for cleanup (rely on fact that dispatch_suspend syncs with disk cache queue)
        if (_timerPaused) {
            _timerPaused = NO;
            dispatch_source_t timer = [self maintenanceTimer];
            if (timer) {
                dispatch_resume([self maintenanceTimer]);
            }
        }
    });
}

// called in NSTimer
- (void)periodicMaintenance {
    if (_diskCacheUsage > self.diskCapacity) {
        dispatch_async(get_disk_io_queue(), ^{
            [self balanceDiskUsage];
        });
    }
    else if (_diskCacheInfoDirty) {
        dispatch_async(get_disk_io_queue(), ^{
            [self saveCacheInfo];
        });
    }
}

#pragma mark SDURLCache

+ (NSString *)defaultCachePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [[paths objectAtIndex:0] stringByAppendingPathComponent:kAFURLCachePath];
}

#pragma mark NSURLCache

- (id)initWithMemoryCapacity:(NSUInteger)memoryCapacity diskCapacity:(NSUInteger)diskCapacity diskPath:(NSString *)path {
    if ((self = [super initWithMemoryCapacity:memoryCapacity diskCapacity:diskCapacity diskPath:path])) {
        self.minCacheInterval = kAFURLCacheInfoDefaultMinCacheInterval;
        self.diskCachePath = path;
        self.ignoreMemoryOnlyStoragePolicy = NO;
	}
    
    return self;
}

- (void)storeCachedResponse:(NSCachedURLResponse *)cachedResponse forRequest:(NSURLRequest *)request {
    request = [SDURLCache canonicalRequestForRequest:request];
    
    if (!_allowCachingResponsesToNonCachedRequests &&
        (request.cachePolicy == NSURLRequestReloadIgnoringLocalCacheData
         || request.cachePolicy == NSURLRequestReloadIgnoringLocalAndRemoteCacheData
         || request.cachePolicy == NSURLRequestReloadIgnoringCacheData)) {
        // When cache is ignored for read, it's a good idea not to store the result as well as this option
        // have big chance to be used every times in the future for the same request.
        // NOTE: This is a change regarding default URLCache behavior
        return;
    }
    
    [super storeCachedResponse:cachedResponse forRequest:request];
    
    NSURLCacheStoragePolicy storagePolicy = cachedResponse.storagePolicy;
    if ((storagePolicy == NSURLCacheStorageAllowed || (storagePolicy == NSURLCacheStorageAllowedInMemoryOnly && _ignoreMemoryOnlyStoragePolicy))
        && [cachedResponse.response isKindOfClass:[NSHTTPURLResponse self]]
        && cachedResponse.data.length < self.diskCapacity) {
        NSDictionary *headers = [(NSHTTPURLResponse *)cachedResponse.response allHeaderFields];
        // RFC 2616 section 13.3.4 says clients MUST use Etag in any cache-conditional request if provided by server
        if (![headers objectForKey:@"Etag"]) {
            NSDate *expirationDate = [SDURLCache expirationDateFromHeaders:headers
                                                            withStatusCode:((NSHTTPURLResponse *)cachedResponse.response).statusCode];
            if (!expirationDate || [expirationDate timeIntervalSinceNow] - _minCacheInterval <= 0) {
                // This response is not cacheable, headers said
                return;
            }
        }
        
        dispatch_async(get_disk_io_queue(), ^{
            [self storeRequestToDisk:request response:cachedResponse];
        });
    }
}

- (NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request {
    request = [SDURLCache canonicalRequestForRequest:request];
    
    NSCachedURLResponse *memoryResponse = [super cachedResponseForRequest:request];
    if (memoryResponse) {
        return memoryResponse;
    }
    
    NSString *cacheKey = [SDURLCache cacheKeyForURL:request.URL];
    
    // NOTE: We don't handle expiration here as even staled cache data is necessary for NSURLConnection to handle cache revalidation.
    //       Staled cache data is also needed for cachePolicies which force the use of the cache.
    __block NSCachedURLResponse *response = nil;
    dispatch_sync(get_disk_cache_queue(), ^{
        NSMutableDictionary *accesses = [self.diskCacheInfo objectForKey:kAFURLCacheInfoAccessesKey];
        if ([accesses objectForKey:cacheKey]) { // OPTI: Check for cache-hit in a in-memory dictionnary before to hit the FS
            @try {
                response = [NSKeyedUnarchiver unarchiveObjectWithFile:[_diskCachePath stringByAppendingPathComponent:cacheKey]];
                if (response) {
                    // OPTI: Log the entry last access time for LRU cache eviction algorithm but don't save the dictionary
                    //       on disk now in order to save IO and time
                    [accesses setObject:[NSDate date] forKey:cacheKey];
                    _diskCacheInfoDirty = YES;
                }
            }
            @catch (NSException *exception) {
                if ([exception.name isEqualToString:NSInvalidArgumentException]) {
                    NSLog(@"Could not unarchive object at %@, Invalid archive!", [_diskCachePath stringByAppendingPathComponent:cacheKey]);
                    [self removeCachedResponseForRequest:request];
                }
            }
            @finally {
                // do nothing
            }
        }
    });
    
    // OPTI: Store the response to memory cache for potential future requests
    if (response) {
        [super storeCachedResponse:response forRequest:request];
    }
    
    return response;
}

- (NSUInteger)currentDiskUsage {
    if (!_diskCacheInfo) {
        [self diskCacheInfo];
    }
    return _diskCacheUsage;
}

- (void)removeCachedResponseForRequest:(NSURLRequest *)request {
    request = [SDURLCache canonicalRequestForRequest:request];
    
    [super removeCachedResponseForRequest:request];
    [self removeCachedResponseForCachedKeys:[NSArray arrayWithObject:[SDURLCache cacheKeyForURL:request.URL]]];
    [self saveCacheInfo];
}

- (void)removeAllCachedResponses {
    [super removeAllCachedResponses];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    [fileManager removeItemAtPath:_diskCachePath error:NULL];
    dispatch_async_afreentrant(get_disk_cache_queue(), ^{
        self.diskCacheInfo = nil;
    });
}

- (void)removeAllCachedResponsesInMemory {
    [super removeAllCachedResponses];
}

- (BOOL)isCached:(NSURL *)url {
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    request = [SDURLCache canonicalRequestForRequest:request];
    
    if ([super cachedResponseForRequest:request]) {
        return YES;
    }
    NSString *cacheKey = [SDURLCache cacheKeyForURL:url];
    NSString *cacheFile = [_diskCachePath stringByAppendingPathComponent:cacheKey];
    
    BOOL isCached = [[[NSFileManager alloc] init] fileExistsAtPath:cacheFile];
    return isCached;
}

#pragma mark NSObject

- (void)dealloc {
    if(_maintenanceTimer) {
        dispatch_source_cancel(_maintenanceTimer);
    }
    _diskCachePath = nil;
    _diskCacheInfo = nil;
}

@synthesize minCacheInterval = _minCacheInterval;
@synthesize ignoreMemoryOnlyStoragePolicy = _ignoreMemoryOnlyStoragePolicy;
@synthesize allowCachingResponsesToNonCachedRequests = _allowCachingResponsesToNonCachedRequests;
@synthesize diskCachePath = _diskCachePath;
@synthesize diskCacheInfo = _diskCacheInfo;

@end
