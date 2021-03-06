//
//  Message.h
//  HelTweetica
//
//  Created by Lucius Kwok on 4/1/10.

/*
 Copyright (c) 2010, Felt Tip Inc. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:  
 1.  Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 2.  Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 3.  Neither the name of the copyright holder(s) nor the names of any contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */


#import <Foundation/Foundation.h>


@interface TwitterStatusUpdate : NSObject {
	NSNumber *identifier;
	NSDate *createdDate;
	NSDate *receivedDate;

	NSNumber *userIdentifier;
	NSString *userScreenName;
	NSString *profileImageURL;
	
	NSNumber *inReplyToStatusIdentifier;
	NSNumber *inReplyToUserIdentifier;
	NSString *inReplyToScreenName;
	NSNumber *retweetedStatusIdentifier;
	
	NSNumber *longitude;
	NSNumber *latitude;

	NSString *text;
	NSString *source;
	BOOL locked;
}
@property (nonatomic, retain) NSNumber *identifier;
@property (nonatomic, retain) NSDate *createdDate;
@property (nonatomic, retain) NSDate *receivedDate;

@property (nonatomic, retain) NSNumber *userIdentifier;
@property (nonatomic, retain) NSString *userScreenName;
@property (nonatomic, retain) NSString *profileImageURL;

@property (nonatomic, retain) NSNumber *inReplyToStatusIdentifier;
@property (nonatomic, retain) NSNumber *inReplyToUserIdentifier;
@property (nonatomic, retain) NSString *inReplyToScreenName;
@property (nonatomic, retain) NSNumber *retweetedStatusIdentifier;

@property (nonatomic, retain) NSNumber *longitude;
@property (nonatomic, retain) NSNumber *latitude;

@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) NSString *source;
@property (assign, getter=isLocked) BOOL locked;

+ (NSArray *)databaseKeys;

- (id)initWithDictionary:(NSDictionary *)d;
- (id)databaseValueForKey:(NSString *)key;
- (void) setValue:(id)value forTwitterKey:(NSString*)key;

- (NSDictionary *)htmlSubstitutions;

@end
