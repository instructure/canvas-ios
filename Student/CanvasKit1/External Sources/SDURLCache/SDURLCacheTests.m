//
//  SDURLCacheTests.m
//  SDURLCache
//
//  Created by Olivier Poitrey on 16/03/10.
//  Copyright 2010 Dailymotion. All rights reserved.
//

#import "SDURLCacheTests.h"
#import "SDURLCache.h"

@interface SDURLCache ()
+ (NSDate *)dateFromHttpDateString:(NSString *)httpDate;
+ (NSDate *)expirationDateFromHeaders:(NSDictionary *)headers withStatusCode:(NSInteger)status;
@end

@implementation SDURLCacheTests

- (void)testHttpDateParser
{
    NSDate *date;
    NSTimeInterval referenceTime = 784111777;

    // RFC 1123 date format
    date = [SDURLCache dateFromHttpDateString:@"Sun, 06 Nov 1994 08:49:37 GMT"];
    STAssertEquals([date timeIntervalSince1970], referenceTime, @"RFC 1123 date format");

    // ANSI C date format
    date = [SDURLCache dateFromHttpDateString:@"Sun Nov  6 08:49:37 1994"];
    STAssertEquals([date timeIntervalSince1970], referenceTime, @"ANSI C date format %f", [date timeIntervalSince1970]);

    // RFC 850 date format
    date = [SDURLCache dateFromHttpDateString:@"Sunday, 06-Nov-94 08:49:37 GMT"];
    STAssertEquals([date timeIntervalSince1970], referenceTime, @"RFC 850 date format");
}

- (void)testExpirationDateFromHeader
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    [dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss z"];
    NSDate *now = [NSDate date];
    NSString *pastDate = [dateFormatter stringFromDate:[NSDate dateWithTimeInterval:-1000 sinceDate:now]];
    NSString *nowDate = [dateFormatter stringFromDate:now];
    NSString *futureDate = [dateFormatter stringFromDate:[NSDate dateWithTimeInterval:1000 sinceDate:now]];

    NSDate *expDate;

    // No cache control
    expDate = [SDURLCache expirationDateFromHeaders:[NSDictionary dictionaryWithObjectsAndKeys:nowDate, @"Date", nil] withStatusCode:200];
    STAssertNotNil(expDate, @"No cache control returns a default expiration date");
    STAssertEqualsWithAccuracy([expDate timeIntervalSinceNow], (NSTimeInterval)3600, 1, @"Default expiration date is 1 hour");

    // No cache control but last-modified
    expDate = [SDURLCache expirationDateFromHeaders:[NSDictionary dictionaryWithObjectsAndKeys:pastDate, @"Last-Modified", nowDate, @"Date", nil] withStatusCode:200];
    STAssertNotNil(expDate, @"No cache control with last-modified header returns an expiration date");
    STAssertEqualsWithAccuracy([expDate timeIntervalSinceNow], (NSTimeInterval)100, 1, @"Expiration date relative to last-modified is 10%% of the age");

    // Pragma: no-cache
    expDate = [SDURLCache expirationDateFromHeaders:[NSDictionary dictionaryWithObjectsAndKeys:@"no-cache", @"Pragma", futureDate, @"Expires", nil] withStatusCode:200];
    STAssertNil(expDate, @"Pragma no-cache");

    // Expires in the past
    expDate = [SDURLCache expirationDateFromHeaders:[NSDictionary dictionaryWithObjectsAndKeys:pastDate, @"Expires", nil] withStatusCode:200];
    STAssertNil(expDate, @"Expires in the past");

    // Expires in the past
    expDate = [SDURLCache expirationDateFromHeaders:[NSDictionary dictionaryWithObjectsAndKeys:futureDate, @"Expires", nil] withStatusCode:200];
    STAssertTrue([expDate timeIntervalSinceNow] > 0, @"Expires in the future");

    // Cache-Control: no-cache with Expires in the future
    expDate = [SDURLCache expirationDateFromHeaders:[NSDictionary dictionaryWithObjectsAndKeys:@"no-cache", @"Cache-Control", futureDate, @"Expires", nil] withStatusCode:200];
    STAssertTrue([expDate timeIntervalSinceNow] > 0, @"Cache-Control no-cache with Expires in the future");

    // Cache-Control with future date
    expDate = [SDURLCache expirationDateFromHeaders:[NSDictionary dictionaryWithObjectsAndKeys:@"public, max-age=1000", @"Cache-Control", nil] withStatusCode:200];
    STAssertNotNil(expDate, @"Cache-Control with future date");
    STAssertTrue([expDate timeIntervalSinceNow] > 0, @"Cache-Control with future date");

    // Cache-Control with max-age=0 and Expires future date
    expDate = [SDURLCache expirationDateFromHeaders:[NSDictionary dictionaryWithObjectsAndKeys:@"public, max-age=0", @"Cache-Control",
                                                     futureDate, @"Expires", nil] withStatusCode:200];
    STAssertNil(expDate, @"Cache-Control with max-age=0 and Expires future date");

    // Cache-Control with future date and Expires past date
    expDate = [SDURLCache expirationDateFromHeaders:[NSDictionary dictionaryWithObjectsAndKeys:@"public, max-age=1000", @"Cache-Control", pastDate, @"Expires", nil] withStatusCode:200];
    STAssertNotNil(expDate, @"Cache-Control with future date and Expires past date");
    STAssertTrue([expDate timeIntervalSinceNow] > 0, @"Cache-Control with future date and Expires past date");

    STAssertNil([SDURLCache expirationDateFromHeaders:nil withStatusCode:100], @"Response status code 100 is not cacheable");
    STAssertNil([SDURLCache expirationDateFromHeaders:nil withStatusCode:101], @"Response status code 101 is not cacheable");
    STAssertNotNil([SDURLCache expirationDateFromHeaders:nil withStatusCode:200], @"Response status code 200 is cacheable");
    STAssertNil([SDURLCache expirationDateFromHeaders:nil withStatusCode:201], @"Response status code 201 is not cacheable");
    STAssertNil([SDURLCache expirationDateFromHeaders:nil withStatusCode:202], @"Response status code 202 is not cacheable");
    STAssertNotNil([SDURLCache expirationDateFromHeaders:nil withStatusCode:203], @"Response status code 203 is cacheable");
    STAssertNil([SDURLCache expirationDateFromHeaders:nil withStatusCode:204], @"Response status code 204 is not cacheable");
    STAssertNil([SDURLCache expirationDateFromHeaders:nil withStatusCode:205], @"Response status code 205 is not cacheable");
    STAssertNil([SDURLCache expirationDateFromHeaders:nil withStatusCode:206], @"Response status code 206 is not cacheable");
    STAssertNotNil([SDURLCache expirationDateFromHeaders:nil withStatusCode:300], @"Response status code 300 is cacheable");
    STAssertNotNil([SDURLCache expirationDateFromHeaders:nil withStatusCode:301], @"Response status code 301 is cacheable");
    STAssertNil([SDURLCache expirationDateFromHeaders:nil withStatusCode:302], @"Response status code 302 is not cacheable if not explicitly instructed");
    expDate = [SDURLCache expirationDateFromHeaders:[NSDictionary dictionaryWithObjectsAndKeys:@"public, max-age=1000", @"Cache-Control", nil] withStatusCode:302];
    STAssertNotNil(expDate, @"Response status code 302 is cacheable if explicitly instructed");
    STAssertNil([SDURLCache expirationDateFromHeaders:nil withStatusCode:303], @"Response status code 303 is not cacheable");
    STAssertNil([SDURLCache expirationDateFromHeaders:nil withStatusCode:304], @"Response status code 304 is not cacheable");
    STAssertNil([SDURLCache expirationDateFromHeaders:nil withStatusCode:305], @"Response status code 305 is not cacheable");
    STAssertNil([SDURLCache expirationDateFromHeaders:nil withStatusCode:307], @"Response status code 305 is not cacheable if not explicitly instructed");
    expDate = [SDURLCache expirationDateFromHeaders:[NSDictionary dictionaryWithObjectsAndKeys:@"public, max-age=1000", @"Cache-Control", nil] withStatusCode:307];
    STAssertNotNil(expDate, @"Response status code 307 is cacheable if explicitly instructed");
    STAssertNil([SDURLCache expirationDateFromHeaders:nil withStatusCode:400], @"Response status code 400 is not cacheable");
    STAssertNil([SDURLCache expirationDateFromHeaders:nil withStatusCode:401], @"Response status code 401 is not cacheable");
    STAssertNil([SDURLCache expirationDateFromHeaders:nil withStatusCode:402], @"Response status code 402 is not cacheable");
    STAssertNil([SDURLCache expirationDateFromHeaders:nil withStatusCode:403], @"Response status code 403 is not cacheable");
    STAssertNil([SDURLCache expirationDateFromHeaders:nil withStatusCode:404], @"Response status code 404 is not cacheable");
    STAssertNil([SDURLCache expirationDateFromHeaders:nil withStatusCode:405], @"Response status code 405 is not cacheable");
    STAssertNil([SDURLCache expirationDateFromHeaders:nil withStatusCode:406], @"Response status code 406 is not cacheable");
    STAssertNil([SDURLCache expirationDateFromHeaders:nil withStatusCode:407], @"Response status code 407 is not cacheable");
    STAssertNil([SDURLCache expirationDateFromHeaders:nil withStatusCode:408], @"Response status code 408 is not cacheable");
    STAssertNil([SDURLCache expirationDateFromHeaders:nil withStatusCode:409], @"Response status code 409 is not cacheable");
    STAssertNotNil([SDURLCache expirationDateFromHeaders:nil withStatusCode:410], @"Response status code 410 is cacheable");
    STAssertNil([SDURLCache expirationDateFromHeaders:nil withStatusCode:411], @"Response status code 411 is not cacheable");
    STAssertNil([SDURLCache expirationDateFromHeaders:nil withStatusCode:412], @"Response status code 412 is not cacheable");
    STAssertNil([SDURLCache expirationDateFromHeaders:nil withStatusCode:413], @"Response status code 413 is not cacheable");
    STAssertNil([SDURLCache expirationDateFromHeaders:nil withStatusCode:414], @"Response status code 414 is not cacheable");
    STAssertNil([SDURLCache expirationDateFromHeaders:nil withStatusCode:415], @"Response status code 415 is not cacheable");
    STAssertNil([SDURLCache expirationDateFromHeaders:nil withStatusCode:416], @"Response status code 416 is not cacheable");
    STAssertNil([SDURLCache expirationDateFromHeaders:nil withStatusCode:417], @"Response status code 417 is not cacheable");
    STAssertNil([SDURLCache expirationDateFromHeaders:nil withStatusCode:500], @"Response status code 500 is not cacheable");
    STAssertNil([SDURLCache expirationDateFromHeaders:nil withStatusCode:501], @"Response status code 501 is not cacheable");
    STAssertNil([SDURLCache expirationDateFromHeaders:nil withStatusCode:502], @"Response status code 502 is not cacheable");
    STAssertNil([SDURLCache expirationDateFromHeaders:nil withStatusCode:503], @"Response status code 503 is not cacheable");
    STAssertNil([SDURLCache expirationDateFromHeaders:nil withStatusCode:504], @"Response status code 504 is not cacheable");
    STAssertNil([SDURLCache expirationDateFromHeaders:nil withStatusCode:505], @"Response status code 505 is not cacheable");
}

- (void)testCaching
{
    // TODO
}

- (void)testCacheCapacity
{
    // TODO
}

@end
