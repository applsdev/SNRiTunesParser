//
//  SNRiTunesPlaylist.h
//  SNRiTunesParser
//
//  Created by Indragie Karunaratne on 11-11-06.
//  Copyright (c) 2011 indragie.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNRiTunesPlaylist : NSObject {
@public
    NSArray *_tracks;
    NSString *_name;
    NSNumber *_master;
    NSNumber *_playlistID;
    NSString *_playlistPersistentID;
    NSNumber *_visible;
    NSNumber *_allItems;
    NSNumber *_distinguishedKind;
    NSNumber *_music;
    NSNumber *_movies;
    NSNumber *_tvShows;
    NSNumber *_iTunesU;
    NSNumber *_books;
    NSNumber *_audiobooks;
    NSNumber *_partyShuffle;
    NSNumber *_podcasts;
    NSNumber *_purchasedMusic;
}
@property (nonatomic, retain, readonly) NSArray *tracks;
@property (nonatomic, retain, readonly) NSString *name;
@property (nonatomic, retain, readonly) NSNumber *master; // Boolean
@property (nonatomic, retain, readonly) NSNumber *playlistID;
@property (nonatomic, retain, readonly) NSString *playlistPersistentID;
@property (nonatomic, retain, readonly) NSNumber *visible; // Boolean
@property (nonatomic, retain, readonly) NSNumber *allItems; // Boolean
@property (nonatomic, retain, readonly) NSNumber *distinguishedKind;
@property (nonatomic, retain, readonly) NSNumber *music; // Boolean
@property (nonatomic, retain, readonly) NSNumber *movies; // Boolean
@property (nonatomic, retain, readonly) NSNumber *tvShows; // Boolean
@property (nonatomic, retain, readonly) NSNumber *iTunesU; // Boolean
@property (nonatomic, retain, readonly) NSNumber *books; // Boolean
@property (nonatomic, retain, readonly) NSNumber *audiobooks; // Boolean
@property (nonatomic, retain, readonly) NSNumber *partyShuffle; // Boolean
@property (nonatomic, retain, readonly) NSNumber *podcasts; // Boolean
@property (nonatomic, retain, readonly) NSNumber *purchasedMusic; // Boolean
@end
