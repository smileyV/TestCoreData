//
//  Item.h
//  testCoreData1
//
//  Created by Smiley.V on 15/9/10.
//  Copyright (c) 2015年 2crazyones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Item : NSManagedObject

@property (nonatomic, retain) NSNumber * quantity;
@property (nonatomic, retain) NSData * photoData;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * listed;
@property (nonatomic, retain) NSNumber * collected;

@end
