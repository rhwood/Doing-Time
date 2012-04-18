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
@property (nonatomic, retain) NSString *userDefaultsKey;
@property (nonatomic, retain) NSString *requestTitle;
@property (nonatomic, retain) NSString *requestMessage;

- (void)requestAuthorization;

+ (TFLoggingManager *)sharedInstance;

@end
