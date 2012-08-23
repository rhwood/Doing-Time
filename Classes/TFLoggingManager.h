//
//  TFPermissions.h
//  Doing Time
//
//  Created by Randall Wood on 16/4/2012.
//  Copyright (c) 2012 Alexandria Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TFLoggingManager : NSObject

@property (nonatomic, readonly) Boolean authorized;
@property (nonatomic, strong) NSString *userDefaultsKey;
@property (nonatomic, strong) NSString *requestTitle;
@property (nonatomic, strong) NSString *requestMessage;

- (void)requestAuthorization;

+ (TFLoggingManager *)sharedInstance;

@end
