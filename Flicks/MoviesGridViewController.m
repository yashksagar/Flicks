//
//  MoviesGridViewController.m
//  Flicks
//
//  Created by Yash Kshirsagar on 9/15/16.
//  Copyright © 2016 Yash Kshirsagar. All rights reserved.
//

#import "MoviesGridViewController.h"

@interface MoviesGridViewController () <UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *gridView;

@end

@implementation MoviesGridViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.gridView.dataSource = self;
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
