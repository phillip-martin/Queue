//
//  SongStruct.h
//  Queue
//
//  Created by Ethan on 12/26/13.
//  Copyright (c) 2013 Ethan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SongStruct : NSObject

@property (nonatomic) NSString *artist;
@property (nonatomic) NSString *title;
@property (nonatomic) NSUInteger votes;
@property (nonatomic) NSString *strIdentifier;

-(id)initWithTitle:(NSString *)strTitle artist:(NSString *)strArtist voteCount:(NSInteger) count;
-(NSString *)identifier;
-(void) Vote;

@end
