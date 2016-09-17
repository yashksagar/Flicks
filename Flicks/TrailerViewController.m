//
//  TrailerViewController.m
//  Flicks
//
//  Created by Yash Kshirsagar on 9/16/16.
//  Copyright © 2016 Yash Kshirsagar. All rights reserved.
//

#import "TrailerViewController.h"
#import <XCDYouTubeKit/XCDYouTubeKit.h>

@interface TrailerViewController ()
@property (weak, nonatomic) IBOutlet UIView *videoContainerView;
@property (strong, nonatomic) MPMoviePlayerController *mv;
@property (weak, nonatomic) IBOutlet UILabel *videoTitleLabel;
@property (weak, nonatomic) IBOutlet UIView *loadingStateView;
@property (weak, nonatomic) IBOutlet UIImageView *bgPosterImage;
@end

@implementation TrailerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    NSLog(@" video id: %@", self.videoId);
    
    XCDYouTubeVideoPlayerViewController *videoPlayerViewController = [[XCDYouTubeVideoPlayerViewController alloc] initWithVideoIdentifier:self.videoId];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerPlaybackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:videoPlayerViewController.moviePlayer];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerLoadStateChanged:) name:MPMoviePlayerLoadStateDidChangeNotification object:videoPlayerViewController.moviePlayer];
    
    [videoPlayerViewController presentInView:self.videoContainerView];

    self.mv = videoPlayerViewController.moviePlayer;
    self.videoTitleLabel.text = self.videoTitle;
    self.bgPosterImage.image = self.bgImage;
    [videoPlayerViewController.moviePlayer play];

}


- (void) moviePlayerLoadStateChanged:(NSNotification *)notification
{
    if (self.mv.loadState == 3) {
        [UIView animateWithDuration:0.2 animations:^{
            self.loadingStateView.alpha = 0.0;
        }];
    }
}

- (void) moviePlayerPlaybackDidFinish:(NSNotification *)notification
{
    [self closeModal];
    
}

- (IBAction)closeButtonPress:(UIButton *)sender {
    // stop video play
    [self.mv stop];
    [self closeModal];
}

- (void) closeModal {
    // dismiss VC
    [self dismissViewControllerAnimated:YES completion:nil];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
