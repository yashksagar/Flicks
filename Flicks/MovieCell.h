//
//  MovieCell.h
//  Flicks
//
//  Created by Yash Kshirsagar on 9/12/16.
//  Copyright © 2016 Yash Kshirsagar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MovieCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *synopsisLabel;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnail;



@end
