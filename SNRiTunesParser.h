//
//  SNRiTunesParser.h
//  SNRiTunesParser
//
//  Created by Indragie Karunaratne on 11-11-05.
//  Copyright (c) 2011 indragie.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SNRiTunesPlaylist;
@interface SNRiTunesParser : NSObject
/* These properties will be set once parsing has completed */
@property (nonatomic, retain, readonly) NSNumber *majorVersion;
@property (nonatomic, retain, readonly) NSNumber *minorVersion;
@property (nonatomic, retain, readonly) NSString *applicationVersion;
@property (nonatomic, retain, readonly) NSNumber *features;
@property (nonatomic, retain, readonly) NSNumber *showContentRatings; // Boolean
@property (nonatomic, retain, readonly) NSURL *musicFolderURL;
@property (nonatomic, retain, readonly) NSString *libraryPersistentID;
@property (nonatomic, retain, readonly) NSArray *tracks;
@property (nonatomic, retain, readonly) NSArray *playlists;

/* Specific playlists for easy access */
@property (nonatomic, retain, readonly) SNRiTunesPlaylist *master;
@property (nonatomic, retain, readonly) SNRiTunesPlaylist *music;
@property (nonatomic, retain, readonly) SNRiTunesPlaylist *movies;
@property (nonatomic, retain, readonly) SNRiTunesPlaylist *tvShows;
@property (nonatomic, retain, readonly) SNRiTunesPlaylist *iTunesU;
@property (nonatomic, retain, readonly) SNRiTunesPlaylist *books;
@property (nonatomic, retain, readonly) SNRiTunesPlaylist *audiobooks;
@property (nonatomic, retain, readonly) SNRiTunesPlaylist *iTunesDJ;
@property (nonatomic, retain, readonly) SNRiTunesPlaylist *podcasts;
@property (nonatomic, retain, readonly) SNRiTunesPlaylist *purchasedMusic;

/* Call to parse synchronously */
- (BOOL)parse;
@end