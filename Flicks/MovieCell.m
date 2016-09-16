//
//  MovieCell.m
//  Flicks
//
//  Created by Yash Kshirsagar on 9/12/16.
//  Copyright © 2016 Yash Kshirsagar. All rights reserved.
//

#import "MovieCell.h"

@implementation MovieCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // disable select color
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    // TODO: how to add highlight color?
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    self.center = CGPointMake(150, self.center.y);
}

@end
