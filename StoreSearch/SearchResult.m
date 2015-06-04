//
//  SearchResult.m
//  StoreSearch
//
//  Created by 陈旭 on 5/27/15.
//  Copyright (c) 2015 陈旭. All rights reserved.
//

#import "SearchResult.h"

@implementation SearchResult

- (NSComparisonResult)compareName:(SearchResult *)other
{
    return [self.name localizedCompare:other.name];
}

- (NSString *)kindForDisplay
{
    if ([self.kind isEqualToString:@"album"]) {
        return NSLocalizedString(@"Album", @"Localized kind: Album") ;
    } else if ([self.kind isEqualToString:@"audiobook"]) {
        return NSLocalizedString(@"Audio Book", @"Localized kind: Audio Book") ;
    } else if ([self.kind isEqualToString:@"book"]) {
        return NSLocalizedString(@"Book", @"Localized kind: Book");
    } else if ([self.kind isEqualToString:@"ebook"]) {
        return NSLocalizedString(@"E-Book", @"Localized kind: E-Book");
    } else if ([self.kind isEqualToString:@"feature-movie"]) {
        return NSLocalizedString(@"Movie", @"Localized kind: Feature Movie");
    } else if ([self.kind isEqualToString:@"music-video"]) {
        return NSLocalizedString(@"Music Video", @"Localized kind: Music Video");
    } else if ([self.kind isEqualToString:@"podcast"]) {
        return NSLocalizedString(@"Podcast", @"Localized kind: Podcast");
    } else if ([self.kind isEqualToString:@"software"]) {
        return NSLocalizedString(@"App", @"Localized kind: Software");
    } else if ([self.kind isEqualToString:@"song"]) {
        return NSLocalizedString(@"Song", @"Localized kind: Song");
    } else if ([self.kind isEqualToString:@"tv-episode"]) {
        return NSLocalizedString(@"TV Episode", @"Localized kind: TV Episode");
    } else {
        return self.kind;
    }
}

@end

