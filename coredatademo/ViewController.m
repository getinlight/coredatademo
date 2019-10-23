//
//  ViewController.m
//  coredatademo
//
//  Created by z on 2019/10/23.
//  Copyright © 2019 z. All rights reserved.
//

#import "ViewController.h"
#import <CoreData/CoreData.h>
#import "Student+CoreDataClass.h"
#import "Student+CoreDataProperties.h"

@interface ViewController ()

@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSPersistentContainer *persistentContainer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self createSqlite];
    [self create];
}

/// iOS10之前的方法
- (void)createSqlite {
    //1.创建模型对象
    
    //获取模型路径
    NSURL *modelUrl = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    NSLog(@"modelUrl %@", [NSBundle mainBundle].bundlePath);
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
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    
    //关联持久化助理
    context.persistentStoreCoordinator = store;
    _context = context;
    
}

- (NSPersistentContainer *)persistentContainer {
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"Model"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription * storeDescription, NSError *error) {
                if (error != nil) {
                    NSLog(@"Unresolved error %@: %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

- (void)create {
    //1.根据Entity名称和NSManagedObjectContext获取一个新的继承于NSManagedObject的子类Student
    Student *student = [NSEntityDescription insertNewObjectForEntityForName:@"Student" inManagedObjectContext:self.persistentContainer.viewContext];
    
    //2.根据表Student中的键值，给NSManagedObject对象赋值
    student.name = [NSString stringWithFormat:@"Mr-%d",arc4random()%100];
    student.age = arc4random()%20;
    student.sex = arc4random()%2 == 0 ?  @"美女" : @"帅哥" ;
    student.height = arc4random()%180;
    student.number = arc4random()%100;
    
    //3.保存插入的数据
    NSError *error = nil;
    if ([_context save:&error]) {
        NSLog(@"数据插入到数据库成功");
    }else{
        NSLog(@"%@", [NSString stringWithFormat:@"数据插入到数据库失败, %@",error.userInfo]);
    }
    
}

@end
