    //
//  UserPageViewController.m
//  HelTweetica
//
//  Created by Lucius Kwok on 5/2/10.

/*
 Copyright (c) 2010, Felt Tip Inc. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:  
 1.  Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 2.  Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 3.  Neither the name of the copyright holder(s) nor the names of any contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "UserPageViewController.h"
#import "Twitter.h"
#import "TwitterTimeline.h"
#import "TwitterUser.h"
#import "WebBrowserViewController.h"

#import "TwitterLoadTimelineAction.h"

#import "UserPageHTMLController.h"



@implementation UserPageViewController
@synthesize topToolbar, followButton, user;


- (id)initWithTwitterUser:(TwitterUser*)aUser account:(TwitterAccount *)anAccount {
	self = [super initWithNibName:@"UserPage" bundle:nil];
	if (self) {
		self.user = aUser;
		
		// Replace HTML controller with specific one for User Pages
		UserPageHTMLController *controller = [[[UserPageHTMLController alloc] init] autorelease];
		controller.twitter = twitter;
		controller.account = anAccount;
		controller.user = aUser;
		controller.delegate = self;
		self.timelineHTMLController = controller;
	}
	return self;
}

- (void)dealloc {
	[topToolbar release];
	[followButton release];
	[user release];
	[super dealloc];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];
	self.topToolbar = nil;
}


#pragma mark Follow button

- (void)didUpdateFriendshipStatusWithAccountFollowsUser:(BOOL)accountFollowsUser userFollowsAccount:(BOOL)userFollowsAccount {
	
	// Don't change the button from the default disabled state if this is the account's own user.
	if ([timelineHTMLController.account.screenName isEqualToString:user.screenName])
		return;
	
	// Update follow/unfollow button in toolbar
	followButton.action = accountFollowsUser ? @selector(unfollow:) : @selector(follow:);
	followButton.title = accountFollowsUser ? NSLocalizedString (@"Unfollow", @"button") : NSLocalizedString (@"Follow", @"button");
	followButton.enabled = YES;
}

- (void)setFollowButtonToPending {
	followButton.action = nil;
	followButton.title = NSLocalizedString (@"updating...", @"button");
	followButton.enabled = NO;
}

- (IBAction)follow:(id)sender {
	[self setFollowButtonToPending];
	UserPageHTMLController *htmlController = (UserPageHTMLController *)timelineHTMLController;
	[htmlController follow];
}

- (IBAction)unfollow:(id)sender {
	[self setFollowButtonToPending];
	UserPageHTMLController *htmlController = (UserPageHTMLController *)timelineHTMLController;
	[htmlController unfollow];
}

#pragma mark Lists button

- (IBAction) lists: (id) sender {
	if ([self closeAllPopovers] == NO) {
		ListsViewController *lists = [[[ListsViewController alloc] initWithAccount:timelineHTMLController.account] autorelease];
		lists.screenName = self.user.screenName;
		lists.currentLists = self.user.lists;
		lists.currentSubscriptions = self.user.listSubscriptions;
		lists.delegate = self;
		[self presentViewController:lists inNavControllerInPopoverFromItem:sender];
	}
}

#pragma mark Web view delegate methods

- (BOOL)webView:(UIWebView *)aWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	NSURL *url = [request URL];
	
	if ([[url scheme] isEqualToString:@"action"]) {
		NSString *actionName = [url resourceSpecifier];
		UserPageHTMLController *htmlController = (UserPageHTMLController *)self.timelineHTMLController;
		
		// Tabs
		if ([actionName hasPrefix:@"user"]) { // Home Timeline
			NSString *screenName = [actionName lastPathComponent];
			if ([screenName caseInsensitiveCompare:user.screenName] == NSOrderedSame) {
				[htmlController selectUserTimeline:user.screenName];
			} else {
				[self showUserPage:screenName];
			}
			return NO;
		} else if ([actionName isEqualToString:@"favorites"]) { // Favorites
			[htmlController selectFavoritesTimeline:user.screenName];
			return NO;
		}
	}
	
	return [super webView:aWebView shouldStartLoadWithRequest:request navigationType:navigationType];
}


#pragma mark View lifecycle

- (void)viewDidLoad {
 	if (user.screenName == nil)
		NSLog (@"-[UserPageViewController selectUserTimeline:] screenName should not be nil.");
	
	// Download the latest tweets from this user.
	//suppressNetworkErrorAlerts = YES;
	UserPageHTMLController *htmlController = (UserPageHTMLController *)timelineHTMLController;
	[htmlController selectUserTimeline:user.screenName];
	
	// Get the following/follower status, but only if it's a different user from the account.
	if ([timelineHTMLController.account.screenName isEqualToString:user.screenName] == NO) 
		[htmlController loadFriendStatus:user.screenName];
	
	// Get the latest user info
	[htmlController loadUserInfo];
	
	[super viewDidLoad];
	//screenNameButton.title = user.screenName;
	
}

- (void)viewDidUnload {
	[super viewDidUnload];
	self.topToolbar = nil;
	self.followButton = nil;
}

@end
