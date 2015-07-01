//
//  StoryViewController.m
//  HNReader
//
//  Created by Vlad on 7/1/15.
//  Copyright (c) 2015 Vlad. All rights reserved.
//

#import "StoryViewController.h"

@interface StoryViewController ()
{
    
    UIActivityIndicatorView *spinner;
}
@end

@implementation StoryViewController


- (void)setStory:(NSDictionary *) story  {
    if (story)
    {
    
    self.title = [story objectForKey:@"title"];
    [self loadWebViewWithUrlString:[story objectForKey:@"url"]];
    }
}

-(void) loadWebViewWithUrlString:(NSString *) urlString {
 //creating webView for displaing story
   UIWebView* webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:webView];
    webView.delegate = self;
    NSURL* url = [NSURL URLWithString:urlString];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    [webView setMultipleTouchEnabled:YES];
    
    [webView loadRequest:request];
    //showing activity indicator while loading page
    [self.view bringSubviewToFront:spinner];
    [spinner startAnimating];
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [spinner stopAnimating];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    //creating spinner to show while loading page
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.center = self.view.center;
    [spinner setColor:[UIColor blueColor]];
    [spinner setHidesWhenStopped:YES];
    [self.view addSubview:spinner];
    
    [spinner startAnimating];
    
}



@end
