//
// CWJSONPointerTests.m
// Tests for NSDictionary+CWJSONPointer
//
// Created by Jonathan on 31/01/2014.
// Copyright (c) 2014 Jonathan Dring. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSDictionary+CWJSONPointer.h"

@interface CWJSONPointerTests : XCTestCase
@property (nonatomic,strong) NSDictionary *rfcJSON;
@property (nonatomic,strong) NSDictionary *nonRfcJSON;
@end

@implementation CWJSONPointerTests

- (void)setUp {
	NSError *error;
	[super setUp];

	NSBundle *bundle = [NSBundle bundleForClass:[self class]];
	XCTAssertNotNil(bundle, @"Failed to get RFC test data from file");

	NSString *jsonPath = [bundle pathForResource:@"RFC6901Specification" ofType:@"json"];
	XCTAssertNotNil(jsonPath, @"Failed to create RFC test file path");

	NSData *jsonData = [NSData dataWithContentsOfFile:jsonPath];
	XCTAssertNotNil(jsonData, @"Failed to get RFC test data from file");

	_rfcJSON = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
	XCTAssertNotNil(_rfcJSON, @"Failed to deserialise RFC json data.");

	NSString *testPath = [bundle pathForResource:@"NonRFC6901TestCases" ofType:@"json"];
	XCTAssertNotNil(testPath, @"Failed to create Non-RFC test file path");

	NSData *testData = [NSData dataWithContentsOfFile:testPath];
	XCTAssertNotNil(testData, @"Failed to get Non-RFC data from file");

	_nonRfcJSON = [NSJSONSerialization JSONObjectWithData:testData options:0 error:&error];
	XCTAssertNotNil(_nonRfcJSON, @"Failed to deserialise Non-RFC json data.");
}

/* RFC6901 String Representations
   ""       // the whole document
   "/foo"   ["bar", "baz"]
   "/foo/0" "bar"
   "/"      0
   "/a~1b"  1
   "/c%d"   2
   "/e^f"   3
   "/g|h"   4
   "/i\\j"  5
   "/k\"l"  6
   "/ "     7
   "/m~0n"  8
 */

- (void)testRFC6901StringRepresentations {
	NSArray *arrayResult = @[@"bar", @"baz"];

	NSDictionary *tests = @{ _rfcJSON: @"",
		                     arrayResult: @"/foo",
		                     @"bar": @"/foo/0",
		                     @0: @"/",
		                     @1: @"/a~1b",
		                     @2: @"/c%d",
		                     @3: @"/e^f",
		                     @4: @"/g|h",
		                     @5: @"/i\\j",
		                     @6: @"/k\"l",
		                     @7: @"/ ",
		                     @8: @"/m~0n" };
	[tests enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop) {
	    XCTAssertEqualObjects([_rfcJSON objectForJSONPointer:obj], key, @"RFC6901 Test '%@' Failed", key);
	}];
}

/* RFC6901 URI Fragment Representations
   "#"          the whole document
   "#/foo"      ["bar", "baz"]
   "#/foo/0"    "bar"
   "#/"         0
   "#/a~1b"     1
   "#/c%25d"    2
   "#/e%5Ef"    3
   "#/g%7Ch"    4
   "#/i%5Cj"    5
   "#/k%22l"    6
   '#/%20"      7
   "#/m~0n"     8
 */

- (void)testRFC6901URIRepresentations {
	NSArray *arrayResult = @[@"bar", @"baz"];

	NSDictionary *tests = @{ _rfcJSON: @"#",
		                     arrayResult: @"#/foo",
		                     @"bar": @"#/foo/0",
		                     @0: @"#/",
		                     @1: @"#/a~1b",
		                     @2: @"#/c%25d",
		                     @3: @"#/e%5Ef",
		                     @4: @"#/g%7Ch",
		                     @5: @"#/i%5Cj",
		                     @6: @"#/k%22l",
		                     @7: @"#/%20",
		                     @8: @"#/m~0n" };
	[tests enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop) {
	    XCTAssertEqualObjects([_rfcJSON objectForJSONPointer:obj], key, @"URI Test '%@' Failed", key);
	}];
}

- (void)testInvalidReferences
{
    NSString *expect = @"should return nil.";
	XCTAssertNil([_rfcJSON objectForJSONPointer:@"/u110000"], @"Invalid Character Not Nil");
	XCTAssertNil([_rfcJSON objectForJSONPointer:@"/c%25d"], @"Escaping in non fragment pointer, %@.", expect);

    NSString *prefix = @"Invalid array reference";
	XCTAssertNil([_rfcJSON objectForJSONPointer:@"/foo/00"], @"%@ with leading zero's, %@.", prefix, expect);
	XCTAssertNil([_rfcJSON objectForJSONPointer:@"/foo/a"], @"%@ with numbers, %@.", prefix, expect);
}

- (void)testSuccessForBoolean
{
    NSString *expect = @"Fetching a bool with a bool should pass";
	XCTAssertEqual([[_nonRfcJSON booleanForJSONPointer:@"/foo/bar/true"] boolValue], YES, @"%@", expect);
	XCTAssertEqual([[_nonRfcJSON booleanForJSONPointer:@"/foo/bar/false"] boolValue], NO, @"%@", expect);
}

- (void)testFailureForBoolean
{
    NSDictionary *tests = @{@"array": @"/foo/bar/array",
                            @"negative": @"/foo/bar/negative",
                            @"object": @"/foo/bar/object",
                            @"number": @"/foo/bar/number",
                            @"string": @"/foo/bar/string",
                            @"null": @"/foo/bar/null"};
    [tests enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
	    XCTAssertNil([_nonRfcJSON booleanForJSONPointer:obj], @"fetching %@ with booleanForJSONPointer should fail.", key);
    }];
}

- (void)testSuccessForNumber
{
    NSString *expect = @"Fetching a number with a number should pass";
	XCTAssertEqual([[_nonRfcJSON numberForJSONPointer:@"/foo/bar/number"] intValue], 55, @"%@", expect);
	XCTAssertEqual([[_nonRfcJSON numberForJSONPointer:@"/foo/bar/negative"] intValue], -55, @"%@", expect);
    XCTAssertTrue([[_nonRfcJSON numberForJSONPointer:@"/foo/bar/number"] isKindOfClass:[NSNumber class]], @"Should be a number");
}

- (void)testFailureForNumber
{
    NSDictionary *tests = @{@"string": @"/foo/bar/string",
                            @"array": @"/foo/bar/array",
                            @"object": @"/foo/bar/object",
                            @"null": @"/foo/bar/null"};
    [tests enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
	    XCTAssertNil([_nonRfcJSON numberForJSONPointer:obj], @"fetching %@ with numberForJSONPointer should fail.", key);
    }];
}

- (void)testSuccessForString
{
	XCTAssertEqualObjects([_nonRfcJSON stringForJSONPointer:@"/foo/bar/string"], @"mystring", @"fetching string with string should pass.");
    XCTAssertTrue([[_nonRfcJSON stringForJSONPointer:@"/foo/bar/string"] isKindOfClass:[NSString class]], @"Should be a string");
}

- (void)testFailureForString
{
    NSDictionary *tests = @{@"array": @"/foo/bar/array",
                            @"bool": @"/foo/bar/true",
                            @"number": @"/foo/bar/number",
                            @"object": @"/foo/bar/object",
                            @"null": @"/foo/bar/null"};
    [tests enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
	    XCTAssertNil([_nonRfcJSON stringForJSONPointer:obj], @"fetching %@ with stringForJSONPointer should fail.", key);
    }];
}

- (void)testSuccessForArray
{
	NSArray *array = @[@1,
                       @2,
                       @3];
	XCTAssertEqualObjects([_nonRfcJSON arrayForJSONPointer:@"/foo/bar/array"], array, @"fetching array with array should fail.");
    XCTAssertTrue([[_nonRfcJSON arrayForJSONPointer:@"/foo/bar/array"] isKindOfClass:[NSArray class]], @"Should be an array");
}

- (void)testFailureForArray
{
    NSDictionary *tests = @{@"string": @"/foo/bar/string",
                            @"bool": @"/foo/bar/true",
                            @"number": @"/foo/bar/number",
                            @"object": @"/foo/bar/object",
                            @"null": @"/foo/bar/null"};
    [tests enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
	    XCTAssertNil([_nonRfcJSON arrayForJSONPointer:obj], @"fetching %@ with arrayForJSONPointer should fail.", key);
    }];
}

- (void)testSuccessForDictionary
{
	NSDictionary *dictionary = @{@"a": @1,
                                 @"b": @2,
                                 @"c": @3};
	XCTAssertEqualObjects([_nonRfcJSON dictionaryForJSONPointer:@"/foo/bar/object"], dictionary, @"fetching object with dictionary should fail.");
    XCTAssertTrue([[_nonRfcJSON dictionaryForJSONPointer:@"/foo/bar/object"] isKindOfClass:[NSDictionary class]], @"Should be an object");
}

- (void)testFailureForDictionary
{
    NSDictionary *tests = @{@"array": @"/foo/bar/array",
                            @"bool": @"/foo/bar/true",
                            @"number": @"/foo/bar/number",
                            @"string": @"/foo/bar/string",
                            @"null": @"/foo/bar/null"};
    [tests enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
	    XCTAssertNil([_nonRfcJSON dictionaryForJSONPointer:obj], @"fetching %@ with dictionaryForJSONPointer should fail.", key);
    }];
}

- (void)tearDown {
	[super tearDown];
}

@end
