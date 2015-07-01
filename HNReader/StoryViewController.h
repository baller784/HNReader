//
//  StoryViewController.h
//  HNReader
//
//  Created by Vlad on 7/1/15.
//  Copyright (c) 2015 Vlad. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StoryViewController : UIViewController <UIWebViewDelegate>

@property (strong, nonatomic) IBOutlet UIWebView *webView;

- (void)setStory:(NSDictionary *) story ;
@end
