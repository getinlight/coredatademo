//
//  ViewController.m
//  coredatademo
//
//  Created by z on 2019/10/23.
//  Copyright © 2019 z. All rights reserved.
//

#import "ViewController.h"
#import <CoreData/CoreData.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)createSqlite {
    //1.创建模型对象
    
    //获取模型路径
    NSURL *modelUrl = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    //根据模型文件创建模型对象
    NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelUrl];
    
    //2.创建持久化存储助理：数据库
    //利用模型对象创建助理对象
    NSPersistentStoreCoordinator *store = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    
    //数据库的名称和路径
    NSString *docStr = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:@"coredata.sqlite"];
    NSLog(@"数据库路径 %@", docStr);
    NSURL *sqlUrl = [NSURL fileURLWithPath:docStr];
    
    NSError *error = nil;
    
    [store addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:sqlUrl options:nil error:&error];
    
    if (error) {
        NSLog(@"添加数据库失败：%@", error);
    } else {
        NSLog(@"添加数据库成功");
    }
    
    //3.创建上下文 保存数据 对数据库进行操作
    
    
}

@end
