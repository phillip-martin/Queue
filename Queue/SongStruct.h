//
//  SongStruct.h
//  Queue
//
//  Created by Ethan on 12/26/13.
//  Copyright (c) 2013 Ethan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface SongStruct : NSObject

@property (nonatomic) NSString *artist;
@property (nonatomic) NSString *title;
@property (nonatomic) NSUInteger votes;
@property (nonatomic) NSString *strIdentifier;
@property (nonatomic) NSData *buffer;
@property (nonatomic) UIImage *artwork;
@property (nonatomic) NSURL *mediaURL;

-(id)initWithTitle:(NSString *)strTitle artist:(NSString *)strArtist voteCount:(NSInteger) count bufferData:(NSData *)data songURL:(NSURL *)url albumArtwork:(UIImage *)image;
-(NSString *)identifier;
-(void) Vote;

@end
