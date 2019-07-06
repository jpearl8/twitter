//
//  User.h
//  twitter
//
//  Created by jpearl on 7/1/19.
//  Copyright © 2019 Emerson Malca. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface User : NSObject

// MARK: Properties
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *partialScreen;
@property (strong, nonatomic) NSString *screenName;
@property (strong, nonatomic) NSString *profPic;
@property (strong, nonatomic) NSString *followers_count;
@property (strong, nonatomic) NSString *favorites_count;
@property (strong, nonatomic) NSString *location;
@property (strong, nonatomic) NSString *desc;
@property (strong, nonatomic) NSString *profile_background;


// Create initializer
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
@end

NS_ASSUME_NONNULL_END
