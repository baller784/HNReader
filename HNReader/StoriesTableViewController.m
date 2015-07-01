//
//  StoriesTableViewController.m
//  HNReader
//
//  Created by Vlad on 7/1/15.
//  Copyright (c) 2015 Vlad. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import "NSDate+TimeAgo.h"

#import "StoriesTableViewController.h"
#import "StoryTableViewCell.h"
#import "StoryViewController.h"

@interface StoriesTableViewController ()
{
    NSMutableArray * stories;
    NSArray * ids ;
    NSMutableArray *storiesSeen;
    NSUserDefaults *userDefaults;
    int loadedStories;
    int currentlyShowingStories;
}
@end

@implementation StoriesTableViewController
-(void) viewDidLoad {
    [super viewDidLoad];
    stories = [[NSMutableArray alloc]init];
    userDefaults = [NSUserDefaults standardUserDefaults];
    loadedStories = 0 ;
    
    [self getTopStoriesIds];

}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    storiesSeen = [[NSMutableArray alloc]init];
   
    if ([userDefaults objectForKey:@"storiesSeen"]) storiesSeen = [[userDefaults objectForKey:@"storiesSeen"]mutableCopy];
   
    [self.tableView reloadData];
 
    
}



#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 72;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
  
    return [stories count]+1;

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     static NSString *storyTableCellIdentifier = @"StoryTableViewCell";
    StoryTableViewCell *cell = (StoryTableViewCell *)[tableView dequeueReusableCellWithIdentifier: storyTableCellIdentifier ];
    
    if(cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:storyTableCellIdentifier owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    //Configure Loading more stories cell
    if (indexPath.row == [stories count])
    {
        cell.backgroundColor = [UIColor colorWithRed:21/255.0 green:107/255.0 blue:241/255.0 alpha:1.0];
        cell.storyName.textAlignment = NSTextAlignmentCenter;
        cell.storyName.textColor = [UIColor whiteColor];
        cell.storyName.text =@"Load 10 More Stories";
        cell.score.text = nil;
        cell.creator.text = nil;
        cell.totalComments.text = [NSString stringWithFormat:@"%lu readed",(unsigned long)[storiesSeen count]];
        cell.time.text = [NSString stringWithFormat:@"%u more ",[ids count] - loadedStories];
        return  cell;
    }else {
    //configure stories cell
    cell.backgroundColor = [UIColor whiteColor];
    cell.storyName.textColor = [UIColor blackColor];
    NSDictionary *story = [stories objectAtIndex: indexPath.row];
   
     cell.storyName.textAlignment = NSTextAlignmentLeft;
    cell.storyName.text =[NSString stringWithFormat:@"%d. %@", indexPath.row+1, [story objectForKey:@"title"]];
    cell.score.text = [NSString stringWithFormat:@"%@ points",[[story objectForKey:@"score"]stringValue]];
    cell.creator.text = [NSString stringWithFormat:@"by %@",[story objectForKey:@"by"]];
    NSDate *date =[[NSDate alloc]initWithTimeIntervalSince1970:[[story objectForKey:@"time"]doubleValue]];
    cell.time.text =[date timeAgo];
    cell.totalComments.text =[NSString stringWithFormat:@"%d comments",[[story objectForKey:@"descendants"]intValue]];
        
        //check if user alread read this story
        bool contains = false;
        
        for (NSDictionary * seenStory in storiesSeen) {
        
            if ([[seenStory objectForKey:@"title"] isEqualToString:  [story objectForKey:@"title"]]) contains = true;
        }
        
        // if user read this story change background color
        if (contains) cell.backgroundColor = [UIColor colorWithRed:205/255.0 green:201/255.0 blue:201/255.0 alpha:0.8];
        else cell.backgroundColor = [UIColor whiteColor];
       

    return cell;
    }
}

-(void) getTopStoriesIds {
    //empty stories array for new get stories request
    [stories removeAllObjects];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET: @"https://hacker-news.firebaseio.com/v0/topstories.json?print=pretty" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        ids = responseObject;
        [self getTopStories];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (error.code == -1009)
        {
            UIAlertView *alert= [[UIAlertView alloc]initWithTitle:@"Oops no internet connection" message:@"Please try again later!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }

    }];

}

-(void) getTopStories  {
    //show 10 stories by defaut showing more when loadMoreStoriesClicked
     currentlyShowingStories = loadedStories + 10;
   
    while (loadedStories < currentlyShowingStories) {
     
        NSString *storyId = [ids objectAtIndex:loadedStories];
      
        [self getRequest:storyId];
      
        loadedStories ++;
       
    }
    
          
}

-(void) getRequest: (NSString *) storyId {
   
    NSString * url = [NSString stringWithFormat:@"https://hacker-news.firebaseio.com/v0/item/%@.json?print=pretty",storyId];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET: url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {

        [stories addObject: responseObject];
            [self.tableView reloadData];
        if([stories count] == currentlyShowingStories)
        {
           [self.refreshControl endRefreshing];
            StoryTableViewCell * cell = (StoryTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[stories count] inSection:0]];
            
            if(cell.activityIndicator.isAnimating) [cell.activityIndicator stopAnimating];
                
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (error.code == -1009)
        {
            UIAlertView *alert= [[UIAlertView alloc]initWithTitle:@"Oops no internet connection" message:@"Please try again later!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }

    }];
    
    
    
   }
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [stories count])
    {
       //load 10 more stories
        StoryTableViewCell * cell = (StoryTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        [cell.activityIndicator startAnimating];
        [self getTopStories];
    }else {
        [self performSegueWithIdentifier:@"showUrl" sender:self];
    }
}
#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"showUrl"]) {
      //select story that corresponds to selected cell
        NSIndexPath *selectedCell = [self.tableView indexPathForSelectedRow];
        
        NSDictionary * selectedStory =[stories objectAtIndex:selectedCell.row];
       
        //add this story to readed if user didn't do it already
        bool contains = false;
        
        for (NSDictionary * story in storiesSeen) {
           
            if ([[story objectForKey:@"title"] isEqualToString:[selectedStory objectForKey:@"title"]]) contains = true;
        }
        
        if (!contains) [storiesSeen addObject: selectedStory];
        [userDefaults setObject:storiesSeen forKey:@"storiesSeen"];
        [userDefaults synchronize];
        [[segue destinationViewController] setStory: selectedStory ];
        }
        
}


- (IBAction)refreshTable:(id)sender {
    loadedStories = 0;
    
    [self getTopStoriesIds];

 }
@end
