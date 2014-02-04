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
@property (nonatomic) NSURL *mediaURL;
@property (nonatomic) UIImage *artwork;

-(id)initWithTitle:(NSString *)strTitle artist:(NSString *)strArtist voteCount:(NSInteger) count songURL:(NSURL *)url artwork:(UIImage *)art;
-(NSString *)identifier;
-(void) Vote;
-(void)imageFromURL:(NSURL *)url;

@end
