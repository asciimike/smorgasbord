//
//  FirebaseProtocol.h
//  ShortOrder
//
//  Created by Michael McDonald on 4/7/14.
//  Copyright (c) 2014 Michael McDonald. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FirebaseProtocol <NSObject>

@required
- (id)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)toDictionary;

@end
