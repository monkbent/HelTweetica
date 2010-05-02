//
//  SearchViewController.m
//  HelTweetica
//
//  Created by Lucius Kwok on 4/11/10.

/*
 Copyright (c) 2010, Felt Tip Inc. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:  
 1.  Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 2.  Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 3.  Neither the name of the copyright holder(s) nor the names of any contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */


#import "SearchViewController.h"
#import "TwitterAccount.h"
#import "TwitterLoadSavedSearchesAction.h"

@interface SearchViewController (PrivateMethods)
- (void)loadSavedSearches;
@end

@implementation SearchViewController
@synthesize popover, statusMessage;

- (void) setContentSize {
	// Set the content size
	if ([UIViewController instancesRespondToSelector:@selector(setContentSizeForViewInPopover:)]) {
		
		int count = twitter.currentAccount.savedSearches.count;
		if (count < 3) count = 3;
		[self setContentSizeForViewInPopover: CGSizeMake(320, 44 * count + 66)];
	}
}

#pragma mark -
#pragma mark Memory management

- (id)initWithTwitter:(Twitter*)aTwitter {
	if (self = [super initWithNibName:@"Search" bundle:nil]) {
		twitter = [aTwitter retain];
		
		[self setContentSize];

		// Request a fresh list of list subscriptions.
		loading = YES;
		self.statusMessage = NSLocalizedString (@"Loading...", @"status message");
		[self loadSavedSearches];
	}
	return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
 }

- (void)viewDidUnload {
}

- (void)dealloc {
	[twitter release];
	[statusMessage release];
    [super dealloc];
}

#pragma mark -
#pragma mark TwitterAction

- (void)loadSavedSearches {
	TwitterLoadSavedSearchesAction *action = [[[TwitterLoadSavedSearchesAction alloc] init] autorelease];
	action.completionTarget= self;
	action.completionAction = @selector(didLoadSavedSearches:);
	action.delegate = self;
	action.consumerToken = twitter.currentAccount.xAuthToken;
	action.consumerSecret = twitter.currentAccount.xAuthSecret;
	
	// Start the URL connection
	[action start];
}

- (void)didLoadSavedSearches:(TwitterLoadSavedSearchesAction *)action {
	twitter.currentAccount.savedSearches = action.queries;
	loading = NO;
	[self setContentSize];
	[self.tableView reloadData];
	
	// Set the default status message for an empty list of saved searches
	self.statusMessage = NSLocalizedString (@"No saved searches.", @"");
}

#pragma mark -
#pragma mark TwitterAction delegate methods

- (void) twitterActionDidFinishLoading:(TwitterAction*)action {
	// Do nothing. didLoadSavedSearches: will be called.
}

- (void) twitterAction:(TwitterAction*)action didFailWithError:(NSError*)error {
	loading = NO;
	self.statusMessage = [error localizedDescription];
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	// Set table header view
	CGRect frame = self.view.bounds;
	frame.size.height = 44;
	UISearchBar *searchBar = [[[UISearchBar alloc] initWithFrame:frame] autorelease];
	searchBar.delegate = self;
	searchBar.tintColor = [UIColor blackColor];
	searchBar.placeholder = NSLocalizedString (@"Twitter", @"search bar placeholder");
	self.tableView.tableHeaderView = searchBar;

	// Title
	self.navigationItem.title = NSLocalizedString (@"Search", @"Nav bar");
	
   // Display an Edit button in the navigation bar for this view controller.
    //self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	int count = twitter.currentAccount.savedSearches.count;
	if (count == 0) count = 1;
	return count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return NSLocalizedString (@"Saved Searches", @"");
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SavedSearchCell"];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SavedSearchCell"] autorelease];
		cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
	}

	TwitterAccount *account = [twitter currentAccount];
	NSString *query;
	if (indexPath.row < account.savedSearches.count) {
		query = [account.savedSearches objectAtIndex: indexPath.row];
		cell.textLabel.text = query;
		cell.textLabel.textColor = [UIColor blackColor];
	} else if (indexPath.row == 0) {
		cell.textLabel.text = self.statusMessage;
		cell.textLabel.textColor = [UIColor grayColor];
	}
	
    return cell;
}

/*
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void) showAlertWithTitle:(NSString*)aTitle message:(NSString*)aMessage {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:aTitle message:aMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

- (NSString *)htmlSafeString:(NSString *)string {
	NSMutableString *result = [NSMutableString stringWithString:string];
	[result replaceOccurrencesOfString:@"&" withString:@"&amp;" options:0 range:NSMakeRange(0, result.length)];
	[result replaceOccurrencesOfString:@"<" withString:@"&lt;" options:0 range:NSMakeRange(0, result.length)];
	[result replaceOccurrencesOfString:@">" withString:@"&gt;" options:0 range:NSMakeRange(0, result.length)];
	[result replaceOccurrencesOfString:@"\"" withString:@"&quot;" options:0 range:NSMakeRange(0, result.length)];
	return result;
}

- (void)searchFor:(NSString*)query {
	if ([query length] == 0) return;
	
	[twitter selectSearchTimelineWithQuery:query];
	[twitter reloadCurrentTimeline];
	
	// Call delegate to tell it we're about to load a new timeline
	if ([twitter.delegate respondsToSelector:@selector(twitter:willLoadTimelineWithName:tabName:)]) {
		NSString *pageName = [NSString stringWithFormat: @"Search for &ldquo;<b>%@</b>&rdquo;", [self htmlSafeString:query]];
		[twitter.delegate twitter:twitter willLoadTimelineWithName:pageName tabName:@"Results"];
	}
	
	if (popover) {
		[popover dismissPopoverAnimated:YES];
		[popover.delegate popoverControllerDidDismissPopover:popover]; // Make sure delegate knows popover has been removed
	}
}	

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row < twitter.currentAccount.savedSearches.count) {
		NSString *query = [twitter.currentAccount.savedSearches objectAtIndex: indexPath.row];
		[self searchFor:query];
	}
}

#pragma mark -
#pragma mark Search bar delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	NSString *query = searchBar.text;
	[self searchFor:query];
}

@end

