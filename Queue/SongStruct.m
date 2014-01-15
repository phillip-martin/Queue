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
            buffer,
            artwork,
            mediaURL;

-(id)initWithTitle:(NSString *)strTitle artist:(NSString *)strArtist voteCount:(NSInteger) count bufferData:(NSData *)data songURL:(NSURL *)url albumArtwork:(UIImage *)image
{
    self = [super init];
    
    self.title = strTitle;
    self.artist = strArtist;
    self.votes = count;
    self.strIdentifier = self.identifier;
    self.buffer = data;
    self.artwork = [(MPMediaItemArtwork *)image imageWithSize:CGSizeMake(280,280)];
    self.mediaURL = url;
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.title = [coder decodeObjectForKey:@"ASCTitle"];
        self.artist = [coder decodeObjectForKey:@"ASCArtist"];
        self.votes = [coder decodeIntegerForKey:@"ASCVotes"];
        self.artwork = [[UIImage alloc] initWithData:[coder decodeObjectForKey:@"UIImage"]];
        self.buffer = [coder decodeObjectForKey:@"ASCBuffer"];
        self.mediaURL = [coder decodeObjectForKey:@"ASCURL"];
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
    NSData *imageData = UIImagePNGRepresentation(self.artwork);
    [coder encodeObject:imageData forKey:@"UIImage"];
    [coder encodeObject:self.buffer forKey:@"ASCBuffer"];
    [coder encodeObject:self.mediaURL forKey:@"ASCURL"];
}

@end
