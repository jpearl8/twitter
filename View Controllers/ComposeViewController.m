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
#import <UITextView+Placeholder/UITextView+Placeholder.h>
#import "TimelineViewController.h"


@interface ComposeViewController () <UITextViewDelegate>
@property (strong, nonatomic) IBOutlet UITextView *tweetBox;
@property (weak, nonatomic) IBOutlet UINavigationItem *navBar;
- (IBAction)tweetAction:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *charRemain;
@property (weak, nonatomic) IBOutlet UIImageView *tweetIm;
@property (weak, nonatomic) IBOutlet UILabel *tweetAccount;
@property (weak, nonatomic) IBOutlet UILabel *screenName;

- (IBAction)closeButton:(id)sender;


@end

@implementation ComposeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadUser];
    self.tweetBox.placeholder = @"What's happening?";
    self.tweetBox.placeholderColor = [UIColor lightGrayColor];
    self.tweetBox.delegate = self;
    
}

-(void)loadUser {
    [[APIManager shared] getCurrentUser:^(User *currentUser, NSError *error) {
        if (currentUser) {
            NSString *profilePicture = currentUser.profPic;
            NSURL *profilePic = [NSURL URLWithString:profilePicture];
            self.tweetIm.image = nil;
            [self fadePic:self.tweetIm withURL:profilePic];
            self.tweetAccount.text = currentUser.name;
            self.screenName.text = currentUser.screenName;
        }
    }];
}

    
-(void)fadePic: (UIImageView *)imgFading withURL: (NSURL *)urlProvided{
    NSURLRequest *request = [NSURLRequest requestWithURL:urlProvided];
    [imgFading setImageWithURLRequest:request placeholderImage:nil
      success:^(NSURLRequest *imageRequest, NSHTTPURLResponse *imageResponse, UIImage *image) {
          
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
      }];
}


    
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    int characterLimit = 140;
    NSString *newText = [self.tweetBox.text stringByReplacingCharactersInRange:range withString:text];
    self.charRemain.text = [NSString stringWithFormat: @"%d", (int)(characterLimit - newText.length)];
    return newText.length < characterLimit;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)tweetAction:(id)sender {
    [[APIManager shared] postStatusWithText:self.tweetBox.text completion: ^(Tweet *tweet, NSError *error){
        if (error != nil){
            NSLog(@"%@", self.tweetBox.text);
            NSLog(@"%@", error);
        } else {
            [self dismissViewControllerAnimated:true completion:nil];
        }
    }];
}

- (IBAction)closeButton:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];

}
@end
