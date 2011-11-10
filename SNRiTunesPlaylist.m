//
//  SNRiTunesPlaylist.m
//  SNRiTunesParser
//
//  Created by Indragie Karunaratne on 11-11-06.
//  Copyright (c) 2011 indragie.com. All rights reserved.
//

#import "SNRiTunesPlaylist.h"

@implementation SNRiTunesPlaylist
@synthesize name = _name;
@synthesize tracks = _tracks;
@synthesize master = _master;
@synthesize playlistID = _playlistID;
@synthesize playlistPersistentID = _playlistPersistentID;
@synthesize visible = _visible;
@synthesize allItems = _allItems;
@synthesize distinguishedKind = _distinguishedKind;
@synthesize music = _music;
@synthesize movies = _movies;
@synthesize tvShows = _tvShows;
@synthesize iTunesU = _iTunesU;
@synthesize books = _books;
@synthesize audiobooks = _audiobooks;
@synthesize partyShuffle = _partyShuffle;
@synthesize podcasts = _podcasts;
@synthesize purchasedMusic = _purchasedMusic;

- (NSString*)description
{
    return [NSString stringWithFormat:@"<%@: %p>\nPlaylist Name: %@\nPlaylist ID: %@\"", NSStringFromClass([self class]), self, self.name, self.playlistID];
}
@end
