//
//  Search.h
//  StoreSearch
//
//  Created by 陈旭 on 6/3/15.
//  Copyright (c) 2015 陈旭. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^SearchBlock)(BOOL success);

@interface Search : NSObject

@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, readonly, strong) NSMutableArray *searchResults;

- (void)performSearchForText:(NSString *)text
                    category:(NSInteger)category
                  completion:(SearchBlock)block;

@end
