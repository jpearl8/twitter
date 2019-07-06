//
//  User.m
//  twitter
//
//  Created by jpearl on 7/1/19.
//  Copyright © 2019 Emerson Malca. All rights reserved.
//

#import "User.h"

@implementation User

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.name = dictionary[@"name"];
        // partial to be used in API calls, screenName everywhere else
        self.partialScreen = dictionary[@"screen_name"];
        self.screenName = [@"@" stringByAppendingString:dictionary[@"screen_name"]];
        self.profPic = dictionary[@"profile_image_url_https"];
        self.followers_count = [dictionary[@"followers_count"] stringValue];
        self.favorites_count = [dictionary[@"favourites_count"] stringValue];
        self.location = dictionary[@"location"];
        self.desc = dictionary[@"description"];
        self.profile_background = dictionary[@"profile_background_image_url_https"];
    }
    return self;
}
@end
