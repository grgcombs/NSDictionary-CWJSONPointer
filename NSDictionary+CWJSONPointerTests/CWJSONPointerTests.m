//
//  jsonPointerCategoryTests.m
//  Tests for NSDictionary_CWJSONPointer
//
//  Created by Jonathan on 31/01/2014.
//  Copyright (c) 2014 Jonathan Dring. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "NSDictionary+CWJSONPointer.h"

@interface jsonPointerTests : XCTestCase

@end

@implementation jsonPointerTests
{
    NSDictionary *_rjson;
    NSDictionary *_njson;
}

- (void)setUp
{
    NSError *error;
    [super setUp];
    
    NSString *jsonPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"RFC6901Specification" ofType:@"json"];
    XCTAssertNotNil(jsonPath, @"Failed to create RFC test file path");
    
    NSData *jsonData = [NSData dataWithContentsOfFile:jsonPath ];
    XCTAssertNotNil(jsonData, @"Failed to get RFC test data from file");
    
    _rjson = [NSJSONSerialization JSONObjectWithData: jsonData options:0 error: &error ];
    XCTAssertNotNil(_rjson, @"Failed to deserialise RFC json data.");

    NSString *testPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"NonRFC6901TestCases" ofType:@"json"];
    XCTAssertNotNil(testPath, @"Failed to create Non-RFC test file path");
    
    NSData *testData = [NSData dataWithContentsOfFile:testPath ];
    XCTAssertNotNil(testData, @"Failed to get Non-RFC data from file");
    
    _njson = [NSJSONSerialization JSONObjectWithData: testData options:0 error: &error ];
    XCTAssertNotNil(_njson, @"Failed to deserialise Non-RFC json data.");
}

/* RFC6901 String Representations
""         // the whole document
"/foo"       ["bar", "baz"]
"/foo/0"    "bar"
"/"          0
"/a~1b"      1
"/c%d"       2
"/e^f"       3
"/g|h"       4
"/i\\j"      5
"/k\"l"      6
"/ "         7
"/m~0n"      8
*/
- (void)testRFC6901StringRepresentations
{
    NSArray  *arrayResult  = @[@"bar",@"baz"];
    
    XCTAssertEqualObjects( [ _rjson objectForJSONPointer: @""       ], _rjson,                     @"Specified Test Failed");
    XCTAssertEqualObjects( [ _rjson objectForJSONPointer: @"/foo"   ], arrayResult,                @"Specified Test Failed");
    XCTAssertEqualObjects( [ _rjson objectForJSONPointer: @"/foo/0" ], @"bar",                     @"Specified Test Failed");
    XCTAssertEqualObjects( [ _rjson objectForJSONPointer: @"/"      ], [NSNumber numberWithInt:0], @"Specified Test Failed");
    XCTAssertEqualObjects( [ _rjson objectForJSONPointer: @"/a~1b"  ], [NSNumber numberWithInt:1], @"Specified Test Failed");
    XCTAssertEqualObjects( [ _rjson objectForJSONPointer: @"/c%d"   ], [NSNumber numberWithInt:2], @"Specified Test Failed");
    XCTAssertEqualObjects( [ _rjson objectForJSONPointer: @"/e^f"   ], [NSNumber numberWithInt:3], @"Specified Test Failed");
    XCTAssertEqualObjects( [ _rjson objectForJSONPointer: @"/g|h"   ], [NSNumber numberWithInt:4], @"Specified Test Failed");
    XCTAssertEqualObjects( [ _rjson objectForJSONPointer: @"/i\\j"  ], [NSNumber numberWithInt:5], @"Specified Test Failed");
    XCTAssertEqualObjects( [ _rjson objectForJSONPointer: @"/k\"l"  ], [NSNumber numberWithInt:6], @"Specified Test Failed");
    XCTAssertEqualObjects( [ _rjson objectForJSONPointer: @"/ "     ], [NSNumber numberWithInt:7], @"Specified Test Failed");
    XCTAssertEqualObjects( [ _rjson objectForJSONPointer: @"/m~0n"  ], [NSNumber numberWithInt:8], @"Specified Test Failed");
}

/* RFC6901 URI Fragment Representations
#            the whole document
#/foo        ["bar", "baz"]
#/foo/0      "bar"
#/           0
#/a~1b       1
#/c%25d      2
#/e%5Ef      3
#/g%7Ch      4
#/i%5Cj      5
#/k%22l      6
#/%20        7
#/m~0n       8
*/
- (void)testRFC6901URIRepresentations
{
    NSArray  *arrayResult  = @[@"bar",@"baz"];
    
    XCTAssertEqualObjects( [ _rjson objectForJSONPointer: @"#"       ], _rjson,                     @"Specified Test Failed");
    XCTAssertEqualObjects( [ _rjson objectForJSONPointer: @"#/foo"   ], arrayResult,                @"Specified Test Failed");
    XCTAssertEqualObjects( [ _rjson objectForJSONPointer: @"#/foo/0" ], @"bar",                     @"Specified Test Failed");
    XCTAssertEqualObjects( [ _rjson objectForJSONPointer: @"#/"      ], [NSNumber numberWithInt:0], @"Specified Test Failed");
    XCTAssertEqualObjects( [ _rjson objectForJSONPointer: @"#/a~1b"  ], [NSNumber numberWithInt:1], @"Specified Test Failed");
    XCTAssertEqualObjects( [ _rjson objectForJSONPointer: @"#/c%25d" ], [NSNumber numberWithInt:2], @"Specified Test Failed");
    XCTAssertEqualObjects( [ _rjson objectForJSONPointer: @"#/e%5Ef" ], [NSNumber numberWithInt:3], @"Specified Test Failed");
    XCTAssertEqualObjects( [ _rjson objectForJSONPointer: @"#/g%7Ch" ], [NSNumber numberWithInt:4], @"Specified Test Failed");
    XCTAssertEqualObjects( [ _rjson objectForJSONPointer: @"#/i%5Cj" ], [NSNumber numberWithInt:5], @"Specified Test Failed");
    XCTAssertEqualObjects( [ _rjson objectForJSONPointer: @"#/k%22l" ], [NSNumber numberWithInt:6], @"Specified Test Failed");
    XCTAssertEqualObjects( [ _rjson objectForJSONPointer: @"#/%20"   ], [NSNumber numberWithInt:7], @"Specified Test Failed");
    XCTAssertEqualObjects( [ _rjson objectForJSONPointer: @"#/m~0n"  ], [NSNumber numberWithInt:8], @"Specified Test Failed");
}

- (void)testNegativeCases
{
    // Test for leading zeros to be rejected for
    XCTAssertNil( [ _rjson objectForJSONPointer:      @"/u110000"         ], @"Invalid Character Not Nil"                                       );
    XCTAssertNil( [ _rjson objectForJSONPointer:      @"/c%25d"           ], @"Escaping in non fragment pointer, should return nil."            );
    XCTAssertNil( [ _rjson objectForJSONPointer:      @"/foo/00"          ], @"Invalid Array reference with leading zero's, should return nil." );
    XCTAssertNil( [ _rjson objectForJSONPointer:      @"/foo/a"           ], @"Invalid Array reference with numbers, should return nil."        );

    XCTAssertNil([_njson numberForJSONPointer:      @"/foo/bar/string"  ], @"fetching string with numberForJSONPointer should fail."            );
    XCTAssertNil([_njson numberForJSONPointer:      @"/foo/bar/array"   ], @"fetching array  with numberForJSONPointer should fail."            );
    XCTAssertNil([_njson numberForJSONPointer:      @"/foo/bar/object"  ], @"fetching object with numberForJSONPointer should fail."            );
    XCTAssertNil([_njson numberForJSONPointer:      @"/foo/bar/null"    ], @"fetching null  with  numberForJSONPointer should fail."            );

    XCTAssertNil([_njson arrayForJSONPointer:       @"/foo/bar/string"  ], @"fetching string with arrayForJSONPointer should fail."             );
    XCTAssertNil([_njson arrayForJSONPointer:       @"/foo/bar/true"    ], @"fetching bool  with  arrayForJSONPointer should fail."             );
    XCTAssertNil([_njson arrayForJSONPointer:       @"/foo/bar/number"  ], @"fetching number with arrayForJSONPointer should fail."             );
    XCTAssertNil([_njson arrayForJSONPointer:       @"/foo/bar/object"  ], @"fetching object with arrayForJSONPointer should fail."             );
    XCTAssertNil([_njson arrayForJSONPointer:       @"/foo/bar/null"    ], @"fetching null  with  arrayForJSONPointer should fail."             );
 
    XCTAssertNil([_njson stringForJSONPointer:      @"/foo/bar/array"   ], @"fetching array with  stringForJSONPointer should fail."            );
    XCTAssertNil([_njson stringForJSONPointer:      @"/foo/bar/true"    ], @"fetching bool  with  stringForJSONPointer should fail."            );
    XCTAssertNil([_njson stringForJSONPointer:      @"/foo/bar/number"  ], @"fetching number with stringForJSONPointer should fail."            );
    XCTAssertNil([_njson stringForJSONPointer:      @"/foo/bar/object"  ], @"fetching object with stringForJSONPointer should fail."            );
    XCTAssertNil([_njson stringForJSONPointer:      @"/foo/bar/null"    ], @"fetching null  with  stringForJSONPointer should fail."            );

    XCTAssertNil([_njson dictionaryForJSONPointer:  @"/foo/bar/array"   ], @"fetching array with  dictionaryForJSONPointer should fail."        );
    XCTAssertNil([_njson dictionaryForJSONPointer:  @"/foo/bar/true"    ], @"fetching bool  with  dictionaryForJSONPointer should fail."        );
    XCTAssertNil([_njson dictionaryForJSONPointer:  @"/foo/bar/number"  ], @"fetching number with dictionaryForJSONPointer should fail."        );
    XCTAssertNil([_njson dictionaryForJSONPointer:  @"/foo/bar/string"  ], @"fetching string with dictionaryForJSONPointer should fail."        );
    XCTAssertNil([_njson dictionaryForJSONPointer:  @"/foo/bar/null"    ], @"fetching null  with  dictionaryForJSONPointer should fail."        );

    XCTAssertNil([_njson booleanForJSONPointer:       @"/foo/bar/array"   ], @"fetching array with  booleanForJSONPointer should fail."             );
    XCTAssertNil([_njson booleanForJSONPointer:       @"/foo/bar/object"  ], @"fetching object with booleanForJSONPointer should fail."             );
    XCTAssertNil([_njson booleanForJSONPointer:       @"/foo/bar/string"  ], @"fetching string with booleanForJSONPointer should fail."             );
    XCTAssertNil([_njson booleanForJSONPointer:       @"/foo/bar/null"    ], @"fetching null  with  booleanForJSONPointer should fail."             );
    XCTAssertNil([_njson booleanForJSONPointer:       @"/foo/bar/number"  ], @"fetching null  with  booleanForJSONPointer should fail."             );
    XCTAssertNil([_njson booleanForJSONPointer:       @"/foo/bar/negative"], @"fetching null  with  booleanForJSONPointer should fail."             );
    
    XCTAssertTrue([[_njson arrayForJSONPointer:     @"/foo/bar/array"   ] isKindOfClass:[NSArray class]],      @"Should be an array"          );
    XCTAssertTrue([[_njson stringForJSONPointer:    @"/foo/bar/string"  ] isKindOfClass:[NSString class]],     @"Should be an array"          );
    XCTAssertTrue([[_njson numberForJSONPointer:    @"/foo/bar/number"  ] isKindOfClass:[NSNumber class]],     @"Should be an array"          );
    XCTAssertTrue([[_njson dictionaryForJSONPointer:@"/foo/bar/object"  ] isKindOfClass:[NSDictionary class]], @"Should be an array"          );
    
    XCTAssertEqual([[_njson booleanForJSONPointer:    @"/foo/bar/true"    ] boolValue ], YES, @"fetching bool with bool should pass."           );
    XCTAssertEqual([[_njson booleanForJSONPointer:    @"/foo/bar/false"   ] boolValue ], NO,  @"fetching bool with bool should pass."           );
    XCTAssertEqual([[_njson numberForJSONPointer:   @"/foo/bar/number"  ] intValue  ], 55,  @"fetching number with number should pass."       );
    XCTAssertEqual([[_njson numberForJSONPointer:   @"/foo/bar/negative"] intValue  ], -55, @"fetching number with number should pass."       );

    NSArray *array = @[ @1, @2, @3 ];
    NSDictionary *dictionary = @{ @"a":@1, @"b":@2, @"c":@3 };
    XCTAssertEqualObjects([_njson stringForJSONPointer:     @"/foo/bar/string" ], @"mystring", @"fetching string with string should pass."    );
    XCTAssertEqualObjects([_njson arrayForJSONPointer:      @"/foo/bar/array"  ], array,       @"fetching array  with array  should fail."    );
    XCTAssertEqualObjects([_njson dictionaryForJSONPointer: @"/foo/bar/object" ], dictionary,  @"fetching object with dictionary should fail.");
}

- (void)tearDown
{
    [super tearDown];
}

@end
