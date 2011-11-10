//
//  SNRiTunesTrack.m
//  SNRiTunesParser
//
//  Created by Indragie Karunaratne on 11-11-06.
//  Copyright (c) 2011 indragie.com. All rights reserved.
//

#import "SNRiTunesTrack.h"

@implementation SNRiTunesTrack
@synthesize trackID = _trackID;
@synthesize name = _name;
@synthesize artist = _artist;
@synthesize albumArtist = _albumArtist;
@synthesize composer = _composer;
@synthesize album = _album;
@synthesize genre = _genre;
@synthesize kind = _kind;
@synthesize size = _size;
@synthesize totalTime = _totalTime;
@synthesize trackNumber = _trackNumber;
@synthesize trackCount = _trackCount;
@synthesize discNumber = _discNumber;
@synthesize discCount = _discCount;
@synthesize year = _year;
@synthesize dateModified = _dateModified;
@synthesize dateAdded = _dateAdded;
@synthesize bitRate = _bitRate;
@synthesize sampleRate = _sampleRate;
@synthesize playCount = _playCount;
@synthesize playDate = _playDate;
@synthesize artworkCount = _artworkCount;
@synthesize persistentID = _persistentID;
@synthesize trackType = _trackType;
@synthesize location = _location;
@synthesize fileFolderCount = _fileFolderCount;
@synthesize libraryFolderCount = _libraryFolderCount;
@synthesize rating = _rating;
@synthesize ratingComputed = _ratingComputed;
@synthesize albumRating = _albumRating;
@synthesize comments = _comments;
@synthesize purchased = _purchased;
@synthesize hasVideo = _hasVideo;
@synthesize HD = _HD;
@synthesize videoWidth = _videoWidth;
@synthesize videoHeight = _videoHeight;
@synthesize musicVideo = _musicVideo;
@synthesize unplayed = _unplayed;
@synthesize iTunesU = _iTunesU;
@synthesize movie = _movie;
@synthesize podcast = _podcast;

- (NSString*)description
{
    return [NSString stringWithFormat:@"<%@: %p>\nTrack ID: %@\nName: %@\nArtist: %@\nAlbum Artist: %@\nAlbum: %@", NSStringFromClass([self class]), self, self.trackID, self.name, self.artist, self.albumArtist, self.album];
}
@end