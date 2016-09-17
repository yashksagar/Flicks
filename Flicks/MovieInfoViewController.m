//
//  MovieInfoViewController.m
//  Flicks
//
//  Created by Yash Kshirsagar on 9/12/16.
//  Copyright © 2016 Yash Kshirsagar. All rights reserved.
//

#import "MovieInfoViewController.h"
#import "UIImageView+AFNetworking.h"
#import "TrailerViewController.h"

@interface MovieInfoViewController ()

@property (strong, nonatomic) IBOutlet UIView *infoView;
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *synopsisLabel;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *releaseDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UILabel *ratingLabel;
@property (weak, nonatomic) IBOutlet UIImageView *durationIcon;
@property (strong, nonatomic) NSArray *videos;
@property (weak, nonatomic) IBOutlet UIView *trailerIconView;

@property (strong, nonatomic) NSDictionary *trailer;

@end

@implementation MovieInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.trailerIconView.hidden = YES;

    // load movie info from segue
    [self loadMovieInfo:self.movie];

    // fetch full movie info
    [self fetchMovieInfo:self.movie[@"id"]];

    CGFloat contentHeight = self.titleLabel.bounds.size.height + self.synopsisLabel.bounds.size.height + self.releaseDateLabel.bounds.size.height + 60;

    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width, contentHeight);
    [self.scrollView.layer setCornerRadius:5.0f];
    
    // off-screen initially
    self.scrollView.transform = CGAffineTransformTranslate(self.scrollView.transform, 0, 330);
}

- (void) updateInfo:(NSDictionary *) movie {
    self.titleLabel.text = movie[@"title"];
    self.synopsisLabel.text = movie[@"overview"];
    
    // format runtime
    if (movie[@"runtime"] != (id)[NSNull null]) {
      int runtime = [movie[@"runtime"] intValue];

      // get 'hrs mins' formatted string
      NSString *duration = [NSString stringWithFormat: @"%dh %02dm", runtime/60, runtime % 60];
      self.durationLabel.text = duration;
    }
   
    if (movie[@"vote_average"] != (id)[NSNull null]) {
        int voteAvg = [movie[@"vote_average"] floatValue] * 10; // convert to percent
        
        self.ratingLabel.text = [NSString stringWithFormat: @"%d%%", voteAvg];
    }
    
    //TODO animate duration icon
}

- (void) loadMovieInfo:(NSDictionary *) movie {
    // animation inits
    self.bgImageView.alpha = 0.0;
    
    NSString *imageUrlOriginal = [NSString stringWithFormat:@"%@%@",
                          @"https://image.tmdb.org/t/p/original/",
                          movie[@"poster_path"]
                          ];
    NSString *imageUrlLow = [NSString stringWithFormat:@"%@%@",
                          @"https://image.tmdb.org/t/p/w342/",
                          movie[@"poster_path"]
                          ];

    // set low res image initially
    [self.bgImageView setImageWithURL:[NSURL URLWithString:imageUrlLow]];

    self.titleLabel.text = movie[@"title"];
    self.synopsisLabel.text = movie[@"overview"];

    [self.synopsisLabel sizeToFit];
    [self.titleLabel sizeToFit];


    // format release date
    NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
    [DateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *releaseDate = [DateFormatter dateFromString:movie[@"release_date"]];
    [DateFormatter setDateFormat:@"MMM dd, yy"];
    NSString *dateString = [DateFormatter stringFromDate:releaseDate];
    self.releaseDateLabel.text = dateString;

    // animate view
    [UIView animateWithDuration:0.5 delay:0.2 options:UIViewAnimationOptionCurveEaseOut animations:^{
        // This causes the bg image to fade in
        self.bgImageView.alpha = 1.0;
    } completion:^(BOOL finished) {
        // bounce-in scroll view
        [UIView animateWithDuration:0.2 delay:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.scrollView.transform = CGAffineTransformTranslate(self.scrollView.transform, 0, -335);
            // switch to original res image
            [self.bgImageView setImageWithURL:[NSURL URLWithString:imageUrlOriginal]];
        } completion:^(BOOL finished) {
            self.scrollView.transform = CGAffineTransformTranslate(self.scrollView.transform, 0, 7);
            [self showTrailerIcon];
        }];
    }];
}

- (void) showTrailerIcon {
    NSDictionary *movie = self.movie;

    // show video icon for trailer
    if (movie[@"videos"] != (id)[NSNull null] && [movie[@"videos"][@"results"] count] > 0) {
        NSDictionary *video = movie[@"videos"][@"results"][0];
        NSLog(@"trailer ?? %@", video);
        self.trailer = video;

        self.trailerIconView.hidden = NO;
        self.trailerIconView.alpha = 0.0;
        [self.trailerIconView.layer setCornerRadius:5.0f];
        [self.trailerIconView.layer setBorderColor:[UIColor colorWithRed:255/255.0f green:230/255.0f blue:66/255.0f alpha:1].CGColor];
        [self.trailerIconView.layer setBorderWidth:2.0f];
        
        [UIView animateWithDuration:0.2 delay:.3 options:0 animations:^{
            self.trailerIconView.alpha = 1.0;
        } completion:^(BOOL finished) {}];
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    TrailerViewController *tvc = segue.destinationViewController;
    
    tvc.videoId = self.trailer[@"key"];
    tvc.videoTitle = self.movie[@"title"];
    tvc.bgImage = self.bgImageView.image;
}


- (void) fetchMovieInfo:id {
    NSString *apiKey = @"a07e22bc18f5cb106bfe4cc1f83ad8ed";
    NSString *apiPath = [NSString stringWithFormat:@"https://api.themoviedb.org/3/movie/%@?api_key=", id];
    NSString *urlString = [[apiPath stringByAppendingString:apiKey] stringByAppendingString:@"&append_to_response=videos"];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];

    NSURLSession *session =
    [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                  delegate:nil
                             delegateQueue:[NSOperationQueue mainQueue]];

    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData * _Nullable data,
                                                                NSURLResponse * _Nullable response,
                                                                NSError * _Nullable error) {
                                                if (!error) {
                                                    NSError *jsonError = nil;
                                                    NSDictionary *movie =
                                                    [NSJSONSerialization JSONObjectWithData:data
                                                                                    options:kNilOptions
                                                                                      error:&jsonError];
                                                    self.movie = movie; // update model
                                                    [self updateInfo:movie];
                                                } else {
                                                    NSLog(@"An error occurred: %@", error.description);
                                                }
                                            }];
    [task resume];

}

// hides tab bar on info page
- (BOOL)hidesBottomBarWhenPushed {
    return YES;
}

- (void) viewWillDisappear:(BOOL)animated {
    self.bgImageView.alpha = 0.8;
    self.scrollView.alpha = 0.8;

    [UIView animateWithDuration:0.2 animations:^{
        self.bgImageView.alpha = 0.0;
        self.scrollView.alpha = 0.0;
    } completion:^(BOOL finished) {}];
}

- (void) viewWillAppear:(BOOL)animated {
    self.bgImageView.alpha = 1.0;
    self.scrollView.alpha = 1.0;
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
