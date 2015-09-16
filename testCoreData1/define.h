//
//  define.h
//  testCoreData1
//
//  Created by Smiley.V on 15/9/9.
//  Copyright (c) 2015年 2crazyones. All rights reserved.
//

#ifndef testCoreData1_define_h
#define testCoreData1_define_h


#define DEBUG_RUNNING if(1 == debug){NSLog(@"ruinning %@ '%@'",self.class,NSStringFromSelector(_cmd));}

#define DEBUG_OUT(_X,...) if(1 == debug){NSLog(_X, ## __VA_ARGS__);}

#endif
