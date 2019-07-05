//
//  viewTweetViewController.m
//  twitter
//
//  Created by jpearl on 7/3/19.
//  Copyright © 2019 Emerson Malca. All rights reserved.
//

#import "viewTweetViewController.h"
#import "UIImageView+AFNetworking.h"
#import "DateTools.h"


@interface viewTweetViewController ()
@property (weak, nonatomic) IBOutlet UILabel *accountName;
@property (weak, nonatomic) IBOutlet UILabel *screenName;
@property (weak, nonatomic) IBOutlet UILabel *date;
@property (weak, nonatomic) IBOutlet UILabel *retweets;
@property (weak, nonatomic) IBOutlet UILabel *favorites;
@property (weak, nonatomic) IBOutlet UILabel *timeAgo;
- (IBAction)didFav:(id)sender;
- (IBAction)didRetweet:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *profPic;
@property (weak, nonatomic) IBOutlet UILabel *tweetWords;



@end

@implementation viewTweetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.accountName.text = self.tweet.user.name;
    self.screenName.text = self.tweet.user.screenName;
    self.date.text = self.tweet.createdAtString;
    self.tweetWords.text = self.tweet.text;
    self.retweets.text = [NSString stringWithFormat:@"%i", self.tweet.retweetCount];
    self.favorites.text = [NSString stringWithFormat:@"%i", self.tweet.favoriteCount];
    NSString *profilePicture = self.tweet.user.profPic;
    NSDate *timeAgoDate = self.tweet.originalDate;
    NSLog(@"%@", timeAgoDate.shortTimeAgoSinceNow);
    self.timeAgo.text = timeAgoDate.shortTimeAgoSinceNow;
    NSURL *profilePic = [NSURL URLWithString:profilePicture];
    self.profPic.image = nil;
    [self fadePic:self.profPic withURL:profilePic];
    
    // Do any additional setup after loading the view.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)didFav:(id)sender {
}

- (IBAction)didRetweet:(id)sender {
}

-(void)fadePic: (UIImageView *)imgFading withURL: (NSURL *)urlProvided{
    NSURLRequest *request = [NSURLRequest requestWithURL:urlProvided];
    [imgFading setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *imageRequest, NSHTTPURLResponse *imageResponse, UIImage *image) {
          
          // imageResponse will be nil if the image is cached
        if (imageResponse) {
            NSLog(@"Image was NOT cached, fade in image");
            imgFading.alpha = 0.0;
            imgFading.image = image;
              
              //Animate UIImageView back to alpha 1 over 0.3sec
            [UIView animateWithDuration:0.8 animations:^{
            imgFading.alpha = 1.0;
            }];
        }
        else {
              NSLog(@"Image was cached so just update the image");
              imgFading.image = image;
        }
    }
    failure:^(NSURLRequest *request, NSHTTPURLResponse * response, NSError *error) {
          // do something for the failure condition
        NSLog(@"didn't work");
    }];
}
@end
