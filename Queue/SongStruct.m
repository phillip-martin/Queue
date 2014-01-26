//
//  SongStruct.m
//  Queue
//
//  Created by Ethan on 12/26/13.
//  Copyright (c) 2013 Ethan. All rights reserved.
//

#import "SongStruct.h"

@implementation SongStruct
@synthesize title,
            artist,
            votes,
            mediaURL,
            artworkURL;

-(id)initWithTitle:(NSString *)strTitle artist:(NSString *)strArtist voteCount:(NSInteger) count songURL:(NSURL *)url artwork:(NSURL *)artURL
{
    self = [super init];
    
    self.title = strTitle;
    self.artist = strArtist;
    self.votes = count;
    self.strIdentifier = self.identifier;
    self.mediaURL = url;
    self.artworkURL = artURL;
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.title = [coder decodeObjectForKey:@"ASCTitle"];
        self.artist = [coder decodeObjectForKey:@"ASCArtist"];
        self.votes = [coder decodeIntegerForKey:@"ASCVotes"];
        self.mediaURL = [coder decodeObjectForKey:@"ASCURL"];
        self.artworkURL = [coder decodeObjectForKey:@"ASCARTURL"];
        self.strIdentifier = self.identifier;
    }
    return self;
}

-(void)Vote
{
    self.votes++;
}

-(NSString *)identifier
{
    return [NSString stringWithFormat:@"%@%@",self.title,self.artist];
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.title forKey:@"ASCTitle"];
    [coder encodeObject:self.artist forKey:@"ASCArtist"];
    [coder encodeInteger:self.votes forKey:@"ASCVotes"];
    [coder encodeObject:self.mediaURL forKey:@"ASCURL"];
    [coder encodeObject:self.artworkURL forKey:@"ASCARTURL"];
}

@end
