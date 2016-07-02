//
//  UserInfo+CoreDataProperties.h
//  DailyNote
//
//  Created by Messi on 16/5/31.
//  Copyright © 2016年 Messi. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "UserInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface UserInfo (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *nickName;
@property (nullable, nonatomic, retain) NSString *signature;

@end

NS_ASSUME_NONNULL_END
