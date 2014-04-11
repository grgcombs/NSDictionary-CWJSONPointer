//
//  NSDictionary+JSONPointer.h
//  JSON Pointer Category for NSDictionary.
//
//  Created by Jonathan on 31/01/2014.
//  Copyright (c) 2014 Jonathan Dring. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary(CWJSONPointer)

- (id)objectForJSONPointer:(NSString *)pointer;

- (NSArray *)arrayForJSONPointer:(NSString *)pointer;
- (NSNumber *)numberForJSONPointer:(NSString *)pointer;
- (NSNumber *)booleanForJSONPointer:(NSString *)pointer;
- (NSString *)stringForJSONPointer:(NSString *)pointer;
- (NSDictionary *)dictionaryForJSONPointer:(NSString *)pointer;

@end
