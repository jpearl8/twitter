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
#import "APIManager.h"


@interface viewTweetViewController ()
@property (weak, nonatomic) IBOutlet UILabel *accountName;
@property (weak, nonatomic) IBOutlet UILabel *screenName;
@property (weak, nonatomic) IBOutlet UILabel *date;
@property (weak, nonatomic) IBOutlet UILabel *retweets;
@property (weak, nonatomic) IBOutlet UILabel *favorites;
@property (weak, nonatomic) IBOutlet UIButton *favButton;
@property (weak, nonatomic) IBOutlet UIButton *retweetButton;
@property (weak, nonatomic) IBOutlet UILabel *timeAgo;
- (IBAction)didFav:(id)sender;
- (IBAction)didRetweet:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *profPic;
@property (weak, nonatomic) IBOutlet UILabel *tweetWords;



@end

@implementation viewTweetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"%@", self.tweet.user.partialScreen);
    [[APIManager shared] getUserTimelineWithCompletion:self.tweet.user.partialScreen withCompletion:^(NSArray *tweets, NSError *error) {
        if (tweets) {
            for (Tweet *tweet in tweets){
                NSLog(@"%@", tweet);
            }
        } else {
            NSLog(@"na");
        }   
    }];
    self.accountName.text = self.tweet.user.name;
    self.screenName.text = self.tweet.user.screenName;
    self.date.text = self.tweet.createdAtString;
    self.tweetWords.text = self.tweet.text;
    self.retweets.text = [NSString stringWithFormat:@"%i", self.tweet.retweetCount];
    self.favorites.text = [NSString stringWithFormat:@"%i", self.tweet.favoriteCount];
    NSString *profilePicture = self.tweet.user.profPic;
    self.timeAgo.text = self.tweet.originalDate.shortTimeAgoSinceNow;
    NSURL *profilePic = [NSURL URLWithString:profilePicture];
    self.profPic.image = nil;
    [self fadePic1:self.profPic withURL:profilePic];
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
    self.tweet.favorited = !(self.tweet.favorited);
    int x = -1;
    if (self.tweet.favorited){
        [self.favButton setImage:[UIImage imageNamed:@"favor-icon-red"] forState:UIControlStateNormal];
        x = 1;
        
        self.tweet.favoriteCount += 1;
        NSLog(@"favorited");
    } else {
        [self.favButton setImage:[UIImage imageNamed:@"favor-icon"] forState:UIControlStateNormal];
        self.tweet.favoriteCount -= 1;
    }
    self.favorites.text = [NSString stringWithFormat:@"%d",self.tweet.favoriteCount];
    [self actionOnTweet:x];
}

-(void)actionOnTweet:(int)x {
    [[APIManager shared] action:self.tweet withInt:x withCompletion:^(Tweet *tweet, NSError *error) {
        if(error){
            NSLog(@"Error taking action on tweet: %@", error.localizedDescription);
        }
        else{
            NSLog(@"Successfully took action on the following Tweet: %@", tweet.text);
        }
    }];
}
- (IBAction)didRetweet:(id)sender {
    self.tweet.retweeted = !(self.tweet.retweeted);
    int x = -2;
    if (self.tweet.retweeted){
        [self.retweetButton setImage:[UIImage imageNamed:@"retweet-icon-green"] forState:UIControlStateNormal];
        x = 2;
        self.tweet.retweetCount += 1;
    } else {
        [self.retweetButton setImage:[UIImage imageNamed:@"retweet-icon"] forState:UIControlStateNormal];
        self.tweet.retweetCount -= 1;
        
    }
    self.retweets.text = [NSString stringWithFormat:@"%d",self.tweet.retweetCount];
    [self actionOnTweet:x];
    
}

-(void)fadePic1: (UIImageView *)imgFading withURL: (NSURL *)urlProvided{
    NSURLRequest *request = [NSURLRequest requestWithURL:urlProvided];
    [imgFading setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *imageRequest, NSHTTPURLResponse *imageResponse, UIImage *image) {
          

        if (imageResponse) {
            NSLog(@"Image was NOT cached, fade in image");
            imgFading.alpha = 0.0;
            imgFading.image = image;
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
        NSLog(@"didn't work");
    }];
}
@end
