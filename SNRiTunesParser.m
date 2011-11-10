//
//  SNRiTunesParser.m
//  SNRiTunesParser
//
//  Created by Indragie Karunaratne on 11-11-05.
//  Copyright (c) 2011 indragie.com. All rights reserved.
//

#import "SNRiTunesParser.h"
#import "SNRiTunesTrack.h"
#import "SNRiTunesPlaylist.h"
#include <libxml/SAX.h>

#define BUFFER_MULTIPLIER 2

static const char* iTunesDatabasePath();

static void SetGeneralPropertyValue(SNRiTunesParser *p);
static void SetLibraryPropertyValue(SNRiTunesParser *p);
static void SetTrackPropertyValue(SNRiTunesParser *p);
static void SetPlaylistPropertyValue(SNRiTunesParser *p);
static void SetPlaylistItemPropertyValue(SNRiTunesParser *p);

#pragma mark - Conversions (C->ObjC)
static NSNumber* BooleanFromCurrentValue(SNRiTunesParser *p);
static NSNumber* IntFromCurrentValue(SNRiTunesParser *p);
static NSString* StringFromCurrentValue(SNRiTunesParser *p);
static NSDate* DateFromCurrentValue(SNRiTunesParser *p);
static NSURL* URLFromCurrentValue(SNRiTunesParser *p);

#pragma mark - Strings
static int StringHasBooleanValue(const char *ch);
static void AppendStringToBuffer(const char *ch, SNRiTunesParser *p, size_t len);

#pragma mark - SAX Handler Callbacks
static void ParseStartElementNs(void *ctx, const xmlChar *localname, const xmlChar *prefix, const xmlChar *URI, int nb_namespaces, const xmlChar **namespaces, int nb_attributes, int nb_defaulted, const xmlChar **attributes);
static void ParseEndElementNs(void* ctx, const xmlChar* localname, const xmlChar* prefix, const xmlChar* URI);
static void ParseCharacters(void *ctx, const xmlChar *ch, int len);

static xmlSAXHandler _saxHandlerStruct = {
    NULL,           /* internalSubset */
    NULL,           /* isStandalone   */
    NULL,           /* hasInternalSubset */
    NULL,           /* hasExternalSubset */
    NULL,           /* resolveEntity */
    NULL,           /* getEntity */
    NULL,           /* entityDecl */
    NULL,           /* notationDecl */
    NULL,           /* attributeDecl */
    NULL,           /* elementDecl */
    NULL,           /* unparsedEntityDecl */
    NULL,           /* setDocumentLocator */
    NULL,           /* startDocument */
    NULL,           /* endDocument */
    NULL,           /* startElement*/
    NULL,           /* endElement */
    NULL,           /* reference */
    ParseCharacters, /* characters */
    NULL,           /* ignorableWhitespace */
    NULL,           /* processingInstruction */
    NULL,           /* comment */
    NULL,           /* warning */
    NULL,           /* error */
    NULL,           /* fatalError //: unused error() get all the errors */
    NULL,           /* getParameterEntity */
    NULL,           /* cdataBlock */
    NULL,           /* externalSubset */
    XML_SAX2_MAGIC, /* initialized */
    NULL,           /* private */
    ParseStartElementNs,    /* startElementNs */
    ParseEndElementNs,      /* endElementNs */
    NULL,           /* serror */
};

#pragma mark - Plist Keys and Types
static const char *pn_key = "key";
static const char *pn_int = "integer";
static const char *pn_str = "string";
static const char *pn_date = "date";
static const char *pn_true = "true";
static const char *pn_false = "false";
static const char *pn_dict = "dict";
static const char *pn_array = "array";

static const size_t pl_key = 4; 
static const size_t pl_int = 8;
static const size_t pl_str = 7;
static const size_t pl_date = 5;
static const size_t pl_true = 5;
static const size_t pl_false = 6;
static const size_t pl_dict = 5;
static const size_t pl_array = 6;

#pragma mark - Library Information
/* kn stands for key name; kl stands for key length */
static const char *kn_majVersion = "Major Version";
static const char *kn_minVersion = "Minor Version";
static const char *kn_appVersion = "Application Version";
static const char *kn_features = "Features";
static const char *kn_showRatings = "Show Content Ratings";
static const char *kn_musicFolder = "Music Folder";
static const char *kn_libPerID = "Library Persistent ID";

static const size_t kl_majVersion = 14;
static const size_t kl_minVersion = 14;
static const size_t kl_appVersion = 20;
static const size_t kl_features = 9;
static const size_t kl_showRatings = 21;
static const size_t kl_musicFolder = 13;
static const size_t kl_libPerID = 22;

#pragma mark - Track Information
static const char *kn_trackID = "Track ID";
static const char *kn_name = "Name";
static const char *kn_artist = "Artist";
static const char *kn_albumArtist = "Album Artist";
static const char *kn_composer = "Composer";
static const char *kn_album = "Album";
static const char *kn_genre = "Genre";
static const char *kn_kind = "Kind";
static const char *kn_size = "Size";
static const char *kn_totalTime = "Total Time";
static const char *kn_trackNumber = "Track Number";
static const char *kn_trackCount = "Track Count";
static const char *kn_discNumber = "Disc Number";
static const char *kn_discCount = "Disc Count";
static const char *kn_year = "Year";
static const char *kn_dateModified = "Date Modified";
static const char *kn_dateAdded = "Date Added";
static const char *kn_bitRate = "Bit Rate";
static const char *kn_sampleRate = "Sample Rate";
static const char *kn_playCount = "Play Count";
static const char *kn_playDate = "Play Date UTC";
static const char *kn_artworkCount = "Artwork Count";
static const char *kn_persistentID = "Persistent ID";
static const char *kn_trackType = "Track Type";
static const char *kn_location = "Location";
static const char *kn_fileFolderCount = "File Folder Count";
static const char *kn_libraryFolderCount = "Library Folder Count";
static const char *kn_rating = "Rating";
static const char *kn_ratingComputed = "Rating Computed";
static const char *kn_albumRating = "Album Rating";
static const char *kn_comments = "Comments";
static const char *kn_purchased = "Purchased";
static const char *kn_unplayed = "Unplayed";
static const char *kn_movie = "Movie";
static const char *kn_podcast = "Podcast";

static const size_t kl_trackID = 9;
static const size_t kl_name = 5;
static const size_t kl_artist = 7;
static const size_t kl_albumArtist = 13;
static const size_t kl_composer = 9;
static const size_t kl_album = 6;
static const size_t kl_genre = 6;
static const size_t kl_kind = 5;
static const size_t kl_size = 5;
static const size_t kl_totalTime = 11;
static const size_t kl_trackNumber = 13;
static const size_t kl_trackCount = 12;
static const size_t kl_discNumber = 12;
static const size_t kl_discCount = 11;
static const size_t kl_year = 5;
static const size_t kl_dateModified = 14;
static const size_t kl_dateAdded = 11;
static const size_t kl_bitRate = 9;
static const size_t kl_sampleRate = 12;
static const size_t kl_playCount = 11;
static const size_t kl_playDate = 14;
static const size_t kl_artworkCount = 14;
static const size_t kl_persistentID = 14;
static const size_t kl_trackType = 11;
static const size_t kl_location = 9;
static const size_t kl_fileFolderCount = 18;
static const size_t kl_libraryFolderCount = 21;
static const size_t kl_rating = 7;
static const size_t kl_ratingComputed = 16;
static const size_t kl_albumRating = 13;
static const size_t kl_comments = 9;
static const size_t kl_purchased = 10;
static const size_t kl_unplayed = 9;
static const size_t kl_movie = 6;
static const size_t kl_podcast = 8;

#pragma mark - Track Information (Video)
static const char *kn_hasVideo = "Has Video";
static const char *kn_HD = "HD";
static const char *kn_videoWidth = "Video Width";
static const char *kn_videoHeight = "Video Height";
static const char *kn_musicVideo = "Music Video";

static const size_t kl_hasVideo = 10;
static const size_t kl_HD = 3;
static const size_t kl_videoWidth = 12;
static const size_t kl_videoHeight = 13;
static const size_t kl_musicVideo = 12;

#pragma mark - Playlist Information
static const char *kn_tracks = "Tracks";
static const char *kn_playlists = "Playlists";
static const char *kn_playlistItems = "Playlist Items";
static const char *kn_master = "Master";
static const char *kn_playlistID = "Playlist ID";
static const char *kn_playlistPersistentID = "Playlist Persistent ID";
static const char *kn_visible = "Visible";
static const char *kn_allItems = "All Items";
static const char *kn_distinguishedKind = "Distinguished Kind";
static const char *kn_music = "Music";
static const char *kn_movies = "Movies";
static const char *kn_TVShows = "TV Shows";
static const char *kn_iTunesU = "iTunesU";
static const char *kn_books = "Books";
static const char *kn_audiobooks = "Audiobooks";
static const char *kn_partyShuffle = "Party Shuffle";
static const char *kn_podcasts = "Podcasts";
static const char *kn_purchasedMusic = "Purchased Music";

static const size_t kl_tracks = 7;
static const size_t kl_playlists = 10;
static const size_t kl_playlistItems = 15;
static const size_t kl_master = 7;
static const size_t kl_playlistID = 12;
static const size_t kl_playlistPersistentID = 23;
static const size_t kl_visible = 8;
static const size_t kl_allItems = 10;
static const size_t kl_distinguishedKind = 19;
static const size_t kl_music = 6;
static const size_t kl_movies = 7;
static const size_t kl_TVShows = 9;
static const size_t kl_iTunesU = 8;
static const size_t kl_books = 6;
static const size_t kl_audiobooks = 11;
static const size_t kl_partyShuffle = 14;
static const size_t kl_podcasts = 9;
static const size_t kl_purchasedMusic = 16;

typedef enum {
    SNRiTunesParserObjectTypeNone = 0,
    SNRiTunesParserObjectTypeTracks = 1,
    SNRiTunesParserObjectTypePlaylists = 2,
    SNRiTunesParserObjectTypePlaylistItems = 3
} SNRiTunesParserObjectType;

@implementation SNRiTunesParser
{
    NSMutableDictionary *_allTracks;
    SNRiTunesTrack *_track;
    SNRiTunesPlaylist *_playlist;
    NSMutableArray *_playlistItems;
    NSMutableArray *_playlists;
    
    char *_key;
    char *_charBuffer;
    size_t _charLength;
    size_t _charBufferSize;
    BOOL _storingCharacters;
    SNRiTunesParserObjectType _objectType;
}
@synthesize majorVersion = _majorVersion;
@synthesize minorVersion = _minorVersion;
@synthesize applicationVersion = _applicationVersion;
@synthesize features = _features;
@synthesize showContentRatings = _showContentRatings;
@synthesize musicFolderURL = _musicFolderURL;
@synthesize libraryPersistentID = _libraryPersistentID;
@synthesize tracks = _tracks;
@synthesize playlists = _playlists;
@synthesize master = _master;
@synthesize music = _music;
@synthesize movies = _movies;
@synthesize tvShows = _tvShows;
@synthesize iTunesU = _iTunesU;
@synthesize books = _books;
@synthesize audiobooks = _audiobooks;
@synthesize iTunesDJ = _iTunesDJ;
@synthesize podcasts = _podcasts;
@synthesize purchasedMusic = _purchasedMusic;

- (id)init
{
    if ((self = [super init])) {
        _allTracks = [NSMutableDictionary new];
        _playlists = [NSMutableArray array];
    }
    return self;
}

- (BOOL)parse
{
    const char *libPath = iTunesDatabasePath();
    assert(libPath);
    const int min = 4;
    FILE *fp = fopen(libPath, "r");
    assert(fp);
    char buffer[min];
    int i, c;
    for (i = 0; (c = getc(fp)) != EOF && i < min; buffer[i++] = c);
    if (i != min) { 
        fclose(fp);
        return NO; 
    }
    xmlParserCtxtPtr ctx = xmlCreatePushParserCtxt(&_saxHandlerStruct, (__bridge void*)self, buffer, 4, NULL);
    int options = XML_PARSE_RECOVER | XML_PARSE_NOENT | XML_PARSE_DTDLOAD | XML_PARSE_NOBLANKS;
    xmlCtxtUseOptions(ctx, options);
    c = 0;
    while (c != EOF) {
        char chunk[PAGE_SIZE];
        for (i = 0; (c = getc(fp)) != EOF && i < PAGE_SIZE; chunk[i++] = c);
        xmlParseChunk(ctx, chunk, i, 0);
    }
    xmlParseChunk(ctx, NULL, 0, 1);
    xmlFreeParserCtxt(ctx);
    xmlCleanupParser();
    fclose(fp);
    
    _tracks = [_allTracks allValues];
    _allTracks = nil;
    return YES;
}

static const char* iTunesDatabasePath()
{
    NSArray *libraryDatabases = [[[NSUserDefaults standardUserDefaults] persistentDomainForName:@"com.apple.iApps"] objectForKey:@"iTunesRecentDatabases"];
    NSURL *libraryURL = (([libraryDatabases count])) ? [NSURL URLWithString:[libraryDatabases objectAtIndex:0]] : nil;
    return (libraryURL != nil) ? [libraryURL.path UTF8String] : NULL;
}

static void ParseStartElementNs(void *ctx, const xmlChar *localname, const xmlChar *prefix, const xmlChar *URI, int nb_namespaces, const xmlChar **namespaces, int nb_attributes, int nb_defaulted, const xmlChar **attributes)
{
    SNRiTunesParser *p = (__bridge id)ctx;
    const char *name = (const char*)localname;
    /* Create a container object to store the track information */
    if (p->_objectType == SNRiTunesParserObjectTypeTracks && !p->_track) {
        p->_track = [SNRiTunesTrack new];
    } else if (p->_objectType == SNRiTunesParserObjectTypePlaylists && !p->_playlist) {
        p->_playlist = [SNRiTunesPlaylist new];
    } else if (p->_objectType == SNRiTunesParserObjectTypePlaylistItems && !p->_playlistItems) {
        p->_playlistItems = [NSMutableArray new];
    }
    /* If a key hasn't already been read, that means this element must be a key */
    if (!p->_key && p->_objectType != SNRiTunesParserObjectTypePlaylistItems) {
        p->_storingCharacters = !strncmp(name, pn_key, pl_key);
    /* Parse strings, numbers, and dates */
    } else if (!strncmp(name, pn_str, pl_str) || !strncmp(name, pn_int, pl_int) || !strncmp(name, pn_date, pl_date)) {
        p->_storingCharacters = YES;
    /* Check to see if the key value is a boolean */
    } else if (StringHasBooleanValue(name)) {
        free(p->_charBuffer);
        AppendStringToBuffer(name, p, strlen(name));
        SetGeneralPropertyValue(p);
    /* Ignore any other values */
    } else {
        free(p->_key);
        p->_key = NULL;
    }
}

static void ParseEndElementNs(void* ctx, const xmlChar* localname, const xmlChar* prefix, const xmlChar* URI) 
{
    SNRiTunesParser *p = (__bridge id)ctx;
    if (p->_objectType == SNRiTunesParserObjectTypeTracks && !strncmp((const char*)localname, pn_dict, pl_dict) && p->_track && p->_track->_trackID) {
        [p->_allTracks setObject:p->_track forKey:p->_track->_trackID];
        p->_track = nil;
    } else if (p->_objectType == SNRiTunesParserObjectTypePlaylistItems && !strncmp((const char*)localname, pn_array, pl_array) && p->_playlist && p->_playlistItems) {
        p->_playlist->_tracks = p->_playlistItems;
        [p->_playlists addObject:p->_playlist];
        p->_objectType = SNRiTunesParserObjectTypePlaylists;
        p->_playlistItems = nil;
        p->_playlist = nil;
    } else if (p->_charBuffer) {
        if (p->_key || p->_objectType == SNRiTunesParserObjectTypePlaylistItems) {
            SetGeneralPropertyValue(p);
        } else {
            if (!strncmp(p->_charBuffer, kn_tracks, kl_tracks)) {
                p->_objectType = SNRiTunesParserObjectTypeTracks;
            } else if (!strncmp(p->_charBuffer, kn_playlists, kl_playlists)) {
                p->_objectType = SNRiTunesParserObjectTypePlaylists;
            } else if (!strncmp(p->_charBuffer, kn_playlistItems, kl_playlistItems)) {
                p->_objectType = SNRiTunesParserObjectTypePlaylistItems;
            } else {
                p->_key = malloc(strlen(p->_charBuffer) + 1);
                strcpy(p->_key, p->_charBuffer);
            }
        }
        free(p->_charBuffer);
        p->_charBuffer = NULL;
    }
    p->_storingCharacters = NO;
}

static void ParseCharacters(void *ctx, const xmlChar *ch, int len) 
{
    SNRiTunesParser *p = (__bridge id)ctx;
    if (p->_storingCharacters) {
        char chars[len + 1];
        strncpy(chars, (const char *)ch, len);
        chars[len] = (char)NULL;
        AppendStringToBuffer(chars, p, len);
    }
}

static void AppendStringToBuffer(const char *ch, SNRiTunesParser *p, size_t len)
{
    if (!p->_charBuffer) {
        p->_charLength = len;
        p->_charBufferSize = (len + 1) * BUFFER_MULTIPLIER;
        p->_charBuffer = malloc(p->_charBufferSize);
        strcpy(p->_charBuffer, ch);
    } else {
        size_t size = p->_charLength + len + 1;
        if (size >= p->_charBufferSize) {
            size *= BUFFER_MULTIPLIER;
            p->_charBuffer = realloc(p->_charBuffer, size);
            p->_charBufferSize = size;
        }
        p->_charLength += len;
        strcat(p->_charBuffer, ch);
    }
}

static int StringHasBooleanValue(const char *ch)
{
    return !strncmp(ch, pn_true, pl_true) || !strncmp(ch, pn_false, pl_false);
}

static NSNumber* BooleanFromCurrentValue(SNRiTunesParser *p)
{
    if (!p->_charBuffer) { return nil; }
    return [NSNumber numberWithBool:!strncmp(p->_charBuffer, pn_true, pl_true)];
}

static NSNumber* IntFromCurrentValue(SNRiTunesParser *p)
{
    if (!p->_charBuffer) { return nil; }
    return [NSNumber numberWithInt:atoi(p->_charBuffer)];
}

static NSString* StringFromCurrentValue(SNRiTunesParser *p)
{
    if (!p->_charBuffer) { return nil; }
    return [NSString stringWithUTF8String:p->_charBuffer];
}

static NSDate* DateFromCurrentValue(SNRiTunesParser *p)
{
    if (!p->_charBuffer) { return nil; }
    return [NSDate dateWithString:StringFromCurrentValue(p)];
}

static NSURL* URLFromCurrentValue(SNRiTunesParser *p)
{
    if (!p->_charBuffer) { return nil; }
    return [NSURL URLWithString:StringFromCurrentValue(p)];
}

static void SetGeneralPropertyValue(SNRiTunesParser *p)
{
    switch (p->_objectType) {
        case SNRiTunesParserObjectTypeTracks:
            SetTrackPropertyValue(p);
            break;
        case SNRiTunesParserObjectTypePlaylists:
            SetPlaylistPropertyValue(p);
            break;
        case SNRiTunesParserObjectTypePlaylistItems:
            SetPlaylistItemPropertyValue(p);
            break;
        default:
            SetLibraryPropertyValue(p);
            break;
    }
}

static void SetLibraryPropertyValue(SNRiTunesParser *p)
{
    if (!p->_majorVersion && !strncmp(p->_key, kn_majVersion, kl_majVersion)) {
        p->_majorVersion = IntFromCurrentValue(p);
    } else if (!p->_minorVersion && !strncmp(p->_key, kn_minVersion, kl_minVersion)) {
        p->_minorVersion = IntFromCurrentValue(p);
    } else if (!p->_applicationVersion && !strncmp(p->_key, kn_appVersion, kl_appVersion)) {
        p->_applicationVersion = StringFromCurrentValue(p);
    } else if (!p->_features && !strncmp(p->_key, kn_features, kl_features)) {
        p->_features = IntFromCurrentValue(p);
    } else if (!p->_showContentRatings && !strncmp(p->_key, kn_showRatings, kl_showRatings)) {
        p->_showContentRatings = BooleanFromCurrentValue(p);
    } else if (!p->_musicFolderURL && !strncmp(p->_key, kn_musicFolder, kl_musicFolder)) {
        p->_musicFolderURL = URLFromCurrentValue(p);
    } else if (!p->_libraryPersistentID && !strncmp(p->_key, kn_libPerID, kl_libPerID)) {
        p->_libraryPersistentID = StringFromCurrentValue(p);
    }
    free(p->_charBuffer);
    p->_charBuffer = NULL;
    free(p->_key);
    p->_key = NULL;
}

static void SetTrackPropertyValue(SNRiTunesParser *p)
{
    SNRiTunesTrack *t = p->_track;
    if (!t->_trackID && !strncmp(p->_key, kn_trackID, kl_trackID)) {
        t->_trackID = IntFromCurrentValue(p);
    } else if (!t->_name && !strncmp(p->_key, kn_name, kl_name)) {
        t->_name = StringFromCurrentValue(p);
    } else if (!t->_artist && !strncmp(p->_key, kn_artist, kl_artist)) {
        t->_artist = StringFromCurrentValue(p);
    } else if (!t->_albumArtist && !strncmp(p->_key, kn_albumArtist, kl_albumArtist)) {
        t->_albumArtist = StringFromCurrentValue(p);
    } else if (!t->_composer && !strncmp(p->_key, kn_composer, kl_composer)) {
        t->_composer = StringFromCurrentValue(p);
    } else if (!t->_album && !strncmp(p->_key, kn_album, kl_album)) {
        t->_album = StringFromCurrentValue(p);
    } else if (!t->_genre && !strncmp(p->_key, kn_genre, kl_genre)) {
        t->_genre = StringFromCurrentValue(p);
    } else if (!t->_kind && !strncmp(p->_key, kn_kind, kl_kind)) {
        t->_kind = StringFromCurrentValue(p);
    } else if (!t->_size && !strncmp(p->_key, kn_size, kl_size)) {
        t->_size = IntFromCurrentValue(p);
    } else if (!t->_totalTime && !strncmp(p->_key, kn_totalTime, kl_totalTime)) {
        t->_totalTime = IntFromCurrentValue(p);
    } else if (!t->_trackNumber && !strncmp(p->_key, kn_trackNumber, kl_trackNumber)) {
        t->_trackNumber = IntFromCurrentValue(p);
    } else if (!t->_trackCount && !strncmp(p->_key, kn_trackCount, kl_trackCount)) {
        t->_trackCount = IntFromCurrentValue(p);
    } else if (!t->_discNumber && !strncmp(p->_key, kn_discNumber, kl_discNumber)) {
        t->_discNumber = IntFromCurrentValue(p);
    } else if (!t->_discCount && !strncmp(p->_key, kn_discCount, kl_discCount)) {
        t->_discCount = IntFromCurrentValue(p); 
    } else if (!t->_year && !strncmp(p->_key, kn_year, kl_year)) {
        t->_year = IntFromCurrentValue(p);
    } else if (!t->_dateModified && !strncmp(p->_key, kn_dateModified, kl_dateModified)) {
        t->_dateModified = DateFromCurrentValue(p);
    } else if (!t->_dateAdded && !strncmp(p->_key, kn_dateAdded, kl_dateAdded)) {
        t->_dateAdded = DateFromCurrentValue(p);
    } else if (!t->_bitRate && !strncmp(p->_key, kn_bitRate, kl_bitRate)) {
        t->_bitRate = IntFromCurrentValue(p);
    } else if (!t->_sampleRate && !strncmp(p->_key, kn_sampleRate, kl_sampleRate)) {
        t->_sampleRate = IntFromCurrentValue(p);
    } else if (!t->_playCount && !strncmp(p->_key, kn_playCount, kl_playCount)) {
        t->_playCount = IntFromCurrentValue(p);
    } else if (!t->_playDate && !strncmp(p->_key, kn_playDate, kl_playDate)) {
        t->_playDate = DateFromCurrentValue(p);
    } else if (!t->_artworkCount && !strncmp(p->_key, kn_artworkCount, kl_artworkCount)) {
        t->_artworkCount = IntFromCurrentValue(p);
    } else if (!t->_persistentID && !strncmp(p->_key, kn_persistentID, kl_persistentID)) {
        t->_persistentID = StringFromCurrentValue(p);
    } else if (!t->_trackType && !strncmp(p->_key, kn_trackType, kl_trackType)) {
        t->_trackType = StringFromCurrentValue(p);
    } else if (!t->_location && !strncmp(p->_key, kn_location, kl_location)) {
        t->_location = URLFromCurrentValue(p);
    } else if (!t->_fileFolderCount && !strncmp(p->_key, kn_fileFolderCount, kl_fileFolderCount)) {
        t->_fileFolderCount = IntFromCurrentValue(p);
    } else if (!t->_libraryFolderCount && !strncmp(p->_key, kn_libraryFolderCount, kl_fileFolderCount)) {
        t->_libraryFolderCount = IntFromCurrentValue(p);
    } else if (!t->_rating && !strncmp(p->_key, kn_rating, kl_rating)) {
        t->_rating = IntFromCurrentValue(p);
    } else if (!t->_ratingComputed && !strncmp(p->_key, kn_ratingComputed, kl_ratingComputed)) {
        t->_ratingComputed = BooleanFromCurrentValue(p);
    } else if (!t->_albumRating && !strncmp(p->_key, kn_albumRating, kl_albumRating)) {
        t->_albumRating = IntFromCurrentValue(p);
    } else if (!t->_comments && !strncmp(p->_key, kn_comments, kl_comments)) {
        t->_comments = StringFromCurrentValue(p);
    } else if (!t->_purchased && !strncmp(p->_key, kn_purchased, kl_purchased)) {
        t->_purchased = BooleanFromCurrentValue(p);
    } else if (!t->_unplayed && !strncmp(p->_key, kn_unplayed, kl_unplayed)) {
        t->_unplayed = BooleanFromCurrentValue(p);
    } else if (!t->_iTunesU && !strncmp(p->_key, kn_iTunesU, kl_iTunesU)) {
        t->_iTunesU = BooleanFromCurrentValue(p);
    } else if (!t->_hasVideo && !strncmp(p->_key, kn_hasVideo, kl_hasVideo)) {
        t->_hasVideo = BooleanFromCurrentValue(p);
    } else if (!t->_podcast && !strncmp(p->_key, kn_podcast, kl_podcast)) {
        t->_podcast = BooleanFromCurrentValue(p);
    }
    if ([t->_hasVideo boolValue]) {
        if (!t->_HD && !strncmp(p->_key, kn_HD, kl_HD)) {
            t->_HD = BooleanFromCurrentValue(p);
        } else if (!t->_videoWidth && !strncmp(p->_key, kn_videoWidth, kl_videoWidth)) {
            t->_videoWidth = IntFromCurrentValue(p);
        } else if (!t->_videoHeight && !strncmp(p->_key, kn_videoHeight, kl_videoHeight)) {
            t->_videoHeight = IntFromCurrentValue(p);
        } else if (!t->_musicVideo && !strncmp(p->_key, kn_musicVideo, kl_musicVideo)) {
            t->_musicVideo = BooleanFromCurrentValue(p);
        } else if (!t->_movie && !strncmp(p->_key, kn_movie, kl_movie)) {
            t->_movie = BooleanFromCurrentValue(p);
        }
    }
    free(p->_charBuffer);
    p->_charBuffer = NULL;
    free(p->_key);
    p->_key = NULL;
}

static void SetPlaylistPropertyValue(SNRiTunesParser *p)
{
    SNRiTunesPlaylist *l = p->_playlist;
    if (!l->_name && !strncmp(p->_key, kn_name, kl_name)) {
        l->_name = StringFromCurrentValue(p);
    } else if (!l->_master && !strncmp(p->_key, kn_master, kl_master)) {
        l->_master = BooleanFromCurrentValue(p);
        p->_master = p->_playlist;
    } else if (!l->_playlistID && !strncmp(p->_key, kn_playlistID, kl_playlistID)) {
        l->_playlistID = IntFromCurrentValue(p);
    } else if (!l->_playlistPersistentID && !strncmp(p->_key, kn_playlistPersistentID, kl_playlistPersistentID)) {
        l->_playlistPersistentID = StringFromCurrentValue(p);
    } else if (!l->_visible && !strncmp(p->_key, kn_visible, kl_visible)) {
        l->_visible = BooleanFromCurrentValue(p);
    } else if (!l->_allItems && !strncmp(p->_key, kn_allItems, kl_allItems)) {
        l->_allItems = BooleanFromCurrentValue(p);
    } else if (!l->_distinguishedKind && !strncmp(p->_key, kn_distinguishedKind, kl_distinguishedKind)) {
        l->_distinguishedKind = BooleanFromCurrentValue(p);
    } else if (!l->_music && !strncmp(p->_key, kn_music, kl_music)) {
        l->_music = BooleanFromCurrentValue(p);
        p->_music = p->_playlist;
    } else if (!l->_movies && !strncmp(p->_key, kn_movies, kl_movies)) {
        l->_movies = BooleanFromCurrentValue(p);
        p->_movies = p->_playlist;
    } else if (!l->_tvShows && !strncmp(p->_key, kn_TVShows, kl_TVShows)) {
        l->_tvShows = BooleanFromCurrentValue(p);
        p->_tvShows = p->_playlist;
    } else if (!l->_iTunesU && !strncmp(p->_key, kn_iTunesU, kl_iTunesU)) {
        l->_iTunesU = BooleanFromCurrentValue(p);
        p->_iTunesU = p->_playlist;
    } else if (!l->_books && !strncmp(p->_key, kn_books, kl_books)) {
        l->_books = BooleanFromCurrentValue(p);
        p->_books = p->_playlist;
    } else if (!l->_audiobooks && !strncmp(p->_key, kn_audiobooks, kl_audiobooks)) {
        l->_audiobooks = BooleanFromCurrentValue(p);
        p->_audiobooks = p->_playlist;
    } else if (!l->_partyShuffle && !strncmp(p->_key, kn_partyShuffle, kl_partyShuffle)) {
        l->_partyShuffle = BooleanFromCurrentValue(p);
        p->_iTunesDJ = p->_playlist;
    } else if (!l->_podcasts && !strncmp(p->_key, kn_podcasts, kl_podcasts)) {
        l->_podcasts = BooleanFromCurrentValue(p);
        p->_podcasts = p->_playlist;
    } else if (!l->_purchasedMusic && !strncmp(p->_key, kn_purchasedMusic, kl_purchasedMusic)) {
        l->_purchasedMusic = BooleanFromCurrentValue(p);
        p->_purchasedMusic = p->_playlist;
    }
    free(p->_charBuffer);
    p->_charBuffer = NULL;
    free(p->_key);
    p->_key = NULL;
}

static void SetPlaylistItemPropertyValue(SNRiTunesParser *p)
{
    NSNumber *trackID = IntFromCurrentValue(p);
    SNRiTunesTrack *track = [p->_allTracks objectForKey:trackID];
    if (track) { [p->_playlistItems addObject:track]; }
    free(p->_charBuffer);
    p->_charBuffer = NULL;
}

@end