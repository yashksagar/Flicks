//
//  MoviesListViewController.m
//  Flicks
//
//  Created by Yash Kshirsagar on 9/12/16.
//  Copyright © 2016 Yash Kshirsagar. All rights reserved.
//

#import "MoviesListViewController.h"
#import "MovieCell.h"
#import "MovieCollectionCell.h"
#import "MovieInfoViewController.h"
#import "UIImageView+AFNetworking.h"
#import "MBProgressHUD.h"

// constants
NSString *const POSTER_BASE_URL = @"https://image.tmdb.org/t/p/w342/";
NSString *const NOW_PLAYING_API = @"now_playing";
NSString *const TOP_RATED_API = @"top_rated";
NSString *const API_KEY = @"a07e22bc18f5cb106bfe4cc1f83ad8ed";

@interface MoviesListViewController () <UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource>

@property (strong, nonatomic) NSArray *movies; // movies data model
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) UIView *refreshLoadingView;
@property (strong, nonatomic) UIView *refreshColorView;
@property (weak, nonatomic) IBOutlet UIView *errorView;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (strong, nonatomic) NSString *moviesEndpoint;
@property (strong, nonatomic) NSString *loadingText;
@property (weak, nonatomic) IBOutlet UISegmentedControl *viewTypeSegmented;
@property (strong, nonatomic) IBOutlet UICollectionView *gridView;
@property (weak, nonatomic) IBOutlet UIView *moviesViewContainer;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;

@end

@implementation MoviesListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"movieslist vc did load ");
    
    [self.navigationItem setTitle:@"Flicks"];
    [self.viewTypeSegmented setSelectedSegmentIndex:0];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithWhite:0.1 alpha:1]];
    [self.navigationController.navigationBar
        setTitleTextAttributes:@{
                                 NSForegroundColorAttributeName: [UIColor whiteColor]
                                }
     ];
    [self.navigationController.navigationBar setTintColor:[UIColor colorWithWhite:1 alpha:0.95]];
    
    switch (self.tabBarController.selectedIndex) {
        case 0:
            self.moviesEndpoint = NOW_PLAYING_API;
            self.loadingText = @"Loading Now Playing";
            break;
        case 1:
            self.moviesEndpoint = TOP_RATED_API;
            self.loadingText = @"Loading Top Rated";
            break;
        default:
            self.moviesEndpoint = @"now_playing";
            self.loadingText = @"Loading Now Playing";
            break;
    }
    
    // initial view setup
    [self viewTypeChange:self.viewTypeSegmented];

    // Table and Collection view setup
    [self.gridView setContentInset:UIEdgeInsetsMake(90, 0, 60, 0)];
    [self.tableView setContentInset:UIEdgeInsetsMake(30, 0, -10, 0)];

    self.gridView.dataSource = self;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorColor = [UIColor clearColor];

    self.errorView.hidden = true;
    self.errorView.center = CGPointMake(self.view.bounds.size.width/2, 0);
    
    // fetch movies
    [self fetchData];
    
    // set pull-to-refresh
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.tableView addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(fetchData) forControlEvents:UIControlEventValueChanged];
    
    self.flowLayout.minimumLineSpacing = 10;
    self.flowLayout.minimumInteritemSpacing = 5;
    [self.flowLayout setSectionInset:UIEdgeInsetsMake(0, 10, 0, 10)];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)viewTypeChange:(UISegmentedControl *)sender {
    [self switchViews:sender.selectedSegmentIndex];
}

- (void) switchViews:(NSInteger)index {
    NSLog(@" selected index: %ld", index);
    UIView *fromView, *toView;
    
    if (index == 1) {
        fromView = self.tableView;
        toView = self.gridView;
    } else {
        fromView = self.gridView;
        toView = self.tableView;
    }

    // show/hide views
    [fromView setHidden:YES];
    [toView setHidden:NO];
    
    // add refresh control to new view
    [self.refreshControl removeFromSuperview];
    [toView addSubview:self.refreshControl];

    // animate transition between views
    [UIView transitionFromView:fromView
                        toView:toView
                      duration:0.3
                       options:UIViewAnimationOptionTransitionFlipFromTop
                    completion:nil];
}



// TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.movies.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MovieCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MovieCell"];
    
    NSDictionary *movie = self.movies[indexPath.row];
    NSString *imageUrl = [NSString stringWithFormat:@"%@%@",
                          POSTER_BASE_URL,
                          movie[@"poster_path"]
                        ];

    cell.titleLabel.text = movie[@"title"];
    cell.synopsisLabel.text = movie[@"overview"];
    cell.thumbnail.alpha = 0.0;
    [cell.thumbnail setImageWithURL:[NSURL URLWithString:imageUrl]];

    // TODO: only fade in when loading from network, not cache
    [UIView animateWithDuration:0.25 animations:^{
        cell.thumbnail.alpha = 1.0;
    } completion:^(BOOL finished) {}];

    return cell;
}

// CollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.movies.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    MovieCollectionCell *mcc = [collectionView dequeueReusableCellWithReuseIdentifier:@"MovieCollectionCell" forIndexPath:indexPath];
    
    NSDictionary *movie = self.movies[indexPath.row];
    NSString *imageUrl = [NSString stringWithFormat:@"%@%@",
                          POSTER_BASE_URL,
                          movie[@"poster_path"]
                        ];
    [mcc.image setImageWithURL:[NSURL URLWithString:imageUrl]];
    
    // poster styling
    mcc.layer.masksToBounds = NO;
    mcc.layer.borderColor = [UIColor whiteColor].CGColor;
    mcc.layer.borderWidth = 3.0f;
    mcc.layer.contentsScale = [UIScreen mainScreen].scale;
    mcc.layer.shadowOpacity = 0.5f;
    mcc.layer.shadowRadius = 2.0f;
    mcc.layer.shadowOffset = CGSizeZero;
    mcc.layer.shadowPath = [UIBezierPath bezierPathWithRect:mcc.bounds].CGPath;
    
    
    mcc.image.alpha = 0.0;
    [UIView animateWithDuration:0.25 delay:0.1 options:UIViewAnimationOptionCurveEaseOut animations:^{
        mcc.image.alpha = 1.0;
    } completion:^(BOOL finished) {}];
    
    NSLog(@" video?: %@", movie[@"video"]);
     return mcc;
}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    MovieInfoViewController *mivc = segue.destinationViewController;
    NSIndexPath *ip;

    if ([segue.identifier isEqual: @"GridPosterSegue"]) {
        UICollectionViewCell *cell = sender;
        ip = [self.gridView indexPathForCell:cell];
    } else {
      UITableViewCell *cell = sender;
      ip = [self.tableView indexPathForCell:cell];
    }
    
    mivc.movie = self.movies[ip.row];
}


- (void) renderErrorView {
    self.errorLabel.text = @"Network error";
    self.errorView.hidden = false;
    [UIView animateWithDuration:.3 animations:^{
        self.errorView.center = CGPointMake(self.view.bounds.size.width/2, 125);
    } completion:^(BOOL finished) {}];
}

// fetch movies data from API

- (void)fetchData {
    NSLog(@"fetching data... ");

    NSString *apiKey = API_KEY;
    NSString *urlString =
    [[NSString stringWithFormat:@"https://api.themoviedb.org/3/movie/%@?api_key=", self.moviesEndpoint] stringByAppendingString:apiKey];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    MBProgressHUD *hud;

    // set loading HUD when not pull-to-refresh
    if (!self.refreshControl.isRefreshing) {
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:true];
        hud.label.text = self.loadingText;
    }
    self.errorView.hidden = true;
    self.errorView.center = CGPointMake(self.view.bounds.size.width/2, 0);

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
                                                    NSDictionary *responseDictionary =
                                                    [NSJSONSerialization JSONObjectWithData:data
                                                                                    options:kNilOptions
                                                                                      error:&jsonError];
                                                    
                                                    self.movies = responseDictionary[@"results"];
                                                   
                                                    [self.tableView reloadData];
                                                    [self.gridView reloadData];
                                                    
                                                    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                                                        // Do something...
                                                        // mock slow network
                                                        [NSThread sleepForTimeInterval:1];
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            if (hud) {
                                                                [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                            }
                                                            
                                                            if (self.refreshControl.isRefreshing) {
                                                                [self.refreshControl endRefreshing];
                                                            }
                                                            
                                                        });
                                                    });
                                                
                                                    if (!self.movies || !self.movies.count) {
                                                        [self renderErrorView];
                                                    }
                                                 
                                                } else {
                                                    NSLog(@"An error occurred: %@", error.description);
                                                    [self.refreshControl endRefreshing];
                                                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                    [self renderErrorView];
                                                }
                                            }];
    [task resume];
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
