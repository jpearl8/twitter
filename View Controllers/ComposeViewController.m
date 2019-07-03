//
//  ComposeViewController.m
//  twitter
//
//  Created by jpearl on 7/2/19.
//  Copyright © 2019 Emerson Malca. All rights reserved.
//

#import "ComposeViewController.h"
#import "APIManager.h"
#import "UIImageView+AFNetworking.h"
#import "Tweet.h"

@interface ComposeViewController ()
@property (weak, nonatomic) IBOutlet UITextView *tweetBox;
- (IBAction)tweetAction:(id)sender;

- (IBAction)closeButton:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *tweetWords;

@end

@implementation ComposeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
 (void)postStatusWithText:(NSString *)text completion:(void (^)(Tweet *, NSError *))completion
 (void)getHomeTimelineWithCompletion:(void(^)(NSArray *tweets, NSError *error))completion*/

- (IBAction)tweetAction:(id)sender {
    [[APIManager shared] postStatusWithText:self.tweetBox.text completion: ^(Tweet *tweet, NSError *error){
        if (error != nil){
            NSLog(@"error!");
            NSLog(@"%@", self.tweetBox.text);
            NSLog(@"%@", error);
        } else {
            NSLog(@"yo");
            [self dismissViewControllerAnimated:true completion:nil];
        }
    }];
}

- (IBAction)closeButton:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];

}
@end
