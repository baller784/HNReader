//
//  StoryTableViewCell.h
//  HNReader
//
//  Created by Vlad on 7/1/15.
//  Copyright (c) 2015 Vlad. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StoryTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *storyName;
@property (weak, nonatomic) IBOutlet UILabel *score;
@property (weak, nonatomic) IBOutlet UILabel *creator;
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UILabel *totalComments;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
