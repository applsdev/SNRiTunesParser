//
//  SNRiTunesTrack.h
//  SNRiTunesParser
//
//  Created by Indragie Karunaratne on 11-11-06.
//  Copyright (c) 2011 indragie.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNRiTunesTrack : NSObject  {
@public
    NSNumber *_trackID;
    NSString *_name;
    NSString *_artist;
    NSString *_albumArtist;
    NSString *_composer;
    NSString *_album;
    NSString *_genre;
    NSString *_kind;
    NSNumber *_size;
    NSNumber *_totalTime;
    NSNumber *_trackNumber;
    NSNumber *_trackCount;
    NSNumber *_discNumber;
    NSNumber *_discCount;
    NSNumber *_year;
    NSDate *_dateModified;
    NSDate *_dateAdded;
    NSNumber *_bitRate;
    NSNumber *_sampleRate;
    NSNumber *_playCount;
    NSDate *_playDate;
    NSNumber *_artworkCount;
    NSString *_persistentID;
    NSString *_trackType;
    NSURL *_location;
    NSNumber *_fileFolderCount;
    NSNumber *_libraryFolderCount;
    NSNumber *_rating;
    NSNumber *_ratingComputed;
    NSNumber *_albumRating;
    NSString *_comments;
    NSNumber *_purchased;
    NSNumber *_hasVideo;
    NSNumber *_HD;
    NSNumber *_videoWidth;
    NSNumber *_videoHeight;
    NSNumber *_musicVideo;
    NSNumber *_unplayed;
    NSNumber *_iTunesU;
    NSNumber *_movie;
    NSNumber *_podcast;
}
@property (nonatomic, retain, readonly) NSNumber *trackID;
@property (nonatomic, retain, readonly) NSString *name;
@property (nonatomic, retain, readonly) NSString *artist;
@property (nonatomic, retain, readonly) NSString *albumArtist;
@property (nonatomic, retain, readonly) NSString *composer;
@property (nonatomic, retain, readonly) NSString *album;
@property (nonatomic, retain, readonly) NSString *genre;
@property (nonatomic, retain, readonly) NSString *kind;
@property (nonatomic, retain, readonly) NSNumber *size;
@property (nonatomic, retain, readonly) NSNumber *totalTime;
@property (nonatomic, retain, readonly) NSNumber *trackNumber;
@property (nonatomic, retain, readonly) NSNumber *trackCount;
@property (nonatomic, retain, readonly) NSNumber *discNumber;
@property (nonatomic, retain, readonly) NSNumber *discCount;
@property (nonatomic, retain, readonly) NSNumber *year;
@property (nonatomic, retain, readonly) NSDate *dateModified;
@property (nonatomic, retain, readonly) NSDate *dateAdded;
@property (nonatomic, retain, readonly) NSNumber *bitRate;
@property (nonatomic, retain, readonly) NSNumber *sampleRate;
@property (nonatomic, retain, readonly) NSNumber *playCount;
@property (nonatomic, retain, readonly) NSDate *playDate;
@property (nonatomic, retain, readonly) NSNumber *artworkCount;
@property (nonatomic, retain, readonly) NSString *persistentID;
@property (nonatomic, retain, readonly) NSString *trackType;
@property (nonatomic, retain, readonly) NSURL *location;
@property (nonatomic, retain, readonly) NSNumber *fileFolderCount;
@property (nonatomic, retain, readonly) NSNumber *libraryFolderCount;
@property (nonatomic, retain, readonly) NSNumber *rating;
@property (nonatomic, retain, readonly) NSNumber *ratingComputed; // Boolean
@property (nonatomic, retain, readonly) NSNumber *albumRating;
@property (nonatomic, retain, readonly) NSString *comments;
@property (nonatomic, retain, readonly) NSNumber *purchased; // Boolean
@property (nonatomic, retain, readonly) NSNumber *unplayed; // Boolean
@property (nonatomic, retain, readonly) NSNumber *iTunesU; // Boolean
@property (nonatomic, retain, readonly) NSNumber *podcast; // Boolean

// Video only
@property (nonatomic, retain, readonly) NSNumber *hasVideo; // Boolean
@property (nonatomic, retain, readonly) NSNumber *HD; // Boolean
@property (nonatomic, retain, readonly) NSNumber *videoWidth;
@property (nonatomic, retain, readonly) NSNumber *videoHeight;
@property (nonatomic, retain, readonly) NSNumber *musicVideo; // Boolean
@property (nonatomic, retain, readonly) NSNumber *movie; // Boolean
@end