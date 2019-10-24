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

@property (nonatomic, strong) NSPersistentContainer *persistentContainer;
@property (nonatomic, strong) NSManagedObjectContext *context;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.context = self.persistentContainer.viewContext;
    [self createData];
//    [self deleteData];
//    [self updateData];
//    [self readData];
    [self sortData];
}

/// iOS10之前的方法
//- (void)createSqlite {
//    //1.创建模型对象
//
//    //获取模型路径
//    NSURL *modelUrl = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
//    NSLog(@"modelUrl %@", [NSBundle mainBundle].bundlePath);
//    //根据模型文件创建模型对象
//    NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelUrl];
//
//    //2.创建持久化存储助理：数据库
//    //利用模型对象创建助理对象
//    NSPersistentStoreCoordinator *store = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
//
//    //数据库的名称和路径
//    NSString *docStr = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:@"coredata.sqlite"];
//    NSLog(@"数据库路径 %@", docStr);
//    NSURL *sqlUrl = [NSURL fileURLWithPath:docStr];
//
//    NSError *error = nil;
//
//    [store addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:sqlUrl options:nil error:&error];
//
//    if (error) {
//        NSLog(@"添加数据库失败：%@", error);
//    } else {
//        NSLog(@"添加数据库成功");
//    }
//
//    //3.创建上下文 保存数据 对数据库进行操作
//    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
//
//    //关联持久化助理
//    context.persistentStoreCoordinator = store;
//    _context = context;
//
//}

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
    
//    _persistentContainer.persistentStoreDescriptions[0].shouldMigrateStoreAutomatically = YES;
//    _persistentContainer.persistentStoreDescriptions[0].shouldInferMappingModelAutomatically = NO;
    
    return _persistentContainer;
}

- (void)createData {
    
    //1.根据Entity名称和NSManagedObjectContext获取一个新的继承于NSManagedObject的子类Student
    Student *student = [NSEntityDescription insertNewObjectForEntityForName:@"Student" inManagedObjectContext:self.context];
    
    //2.根据表Student中的键值，给NSManagedObject对象赋值
    student.name = [NSString stringWithFormat:@"Mr-%d",arc4random()%100];
    student.age = arc4random()%20;
    student.sex = arc4random()%2 == 0 ?  @"美女" : @"帅哥" ;
    student.height = arc4random()%180;
    student.number = arc4random()%100;
    student.weight = arc4random()%100;
    
    //3.保存插入的数据
    NSError *error = nil;
    if ([self.context save:&error]) {
        NSLog(@"数据插入到数据库成功");
    } else {
        NSLog(@"%@", [NSString stringWithFormat:@"数据插入到数据库失败, %@",error.userInfo]);
    }
    
}

- (void)deleteData {
    //创建删除请求
    NSFetchRequest *deleRequest = [NSFetchRequest fetchRequestWithEntityName:@"Student"];
    
    //删除条件
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"age < %d", 10];
    deleRequest.predicate = pre;
    
    //返回需要删除的对象数组
    NSArray *deleArray = [self.context executeFetchRequest:deleRequest error:nil];
    
    //从数据库中删除
    for (Student *stu in deleArray) {
        [self.context deleteObject:stu];
    }
    
    NSError *err = nil;
    
    //保存
    if ([self.context save:&err]) {
        NSLog(@"删除 age < 10 的数据");
    } else {
        NSLog(@"删除数据失败 %@", err);
    }
}

- (void)updateData {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Student"];
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"sex = %@", @"帅哥"];
    request.predicate = pre;
    
    NSArray *resArray = [self.context executeFetchRequest:request error:nil];
    
    for (Student *stu in resArray) {
        stu.name = @"且行且珍惜";
    }
    
    NSError *err;
    if ([self.context save:&err]) {
        NSLog(@"新所有帅哥的的名字为 且行且珍惜");
    } else {
        NSLog(@"更新失败");
    }
}

- (void)readData {
    /* 谓词的条件指令
    1.比较运算符 > 、< 、== 、>= 、<= 、!=
    例：@"number >= 99"
    
    2.范围运算符：IN 、BETWEEN
    例：@"number BETWEEN {1,5}"
    @"address IN {'shanghai','nanjing'}"
    
    3.字符串本身:SELF
    例：@"SELF == 'APPLE'"
    
    4.字符串相关：BEGINSWITH、ENDSWITH、CONTAINS
    例：  @"name CONTAIN[cd] 'ang'"  //包含某个字符串
    @"name BEGINSWITH[c] 'sh'"    //以某个字符串开头
    @"name ENDSWITH[d] 'ang'"    //以某个字符串结束
    
    5.通配符：LIKE
    例：@"name LIKE[cd] '*er*'"   //代表通配符,Like也接受[cd].
    @"name LIKE[cd] '???er*'"
    
    *注*: 星号 "*" : 代表0个或多个字符
    问号 "?" : 代表一个字符
    
    6.正则表达式：MATCHES
    例：NSString *regex = @"^A.+e$"; //以A开头，e结尾
    @"name MATCHES %@",regex
    
    注:[c]*不区分大小写 , [d]不区分发音符号即没有重音符号, [cd]既不区分大小写，也不区分发音符号。
    
    7. 合计操作
    ANY，SOME：指定下列表达式中的任意元素。比如，ANY children.age < 18。
    ALL：指定下列表达式中的所有元素。比如，ALL children.age < 18。
    NONE：指定下列表达式中没有的元素。比如，NONE children.age < 18。它在逻辑上等于NOT (ANY ...)。
    IN：等于SQL的IN操作，左边的表达必须出现在右边指定的集合中。比如，name IN { 'Ben', 'Melissa', 'Nick' }。
    
    提示:
    1. 谓词中的匹配指令关键字通常使用大写字母
    2. 谓词中可以使用格式字符串
    3. 如果通过对象的key
    path指定匹配条件，需要使用%K
    
    */
    
    //创建查询请求
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Student"];
    //查询条件
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"sex = %@", @"美女"];
    request.predicate = pre;

    // 从第几页开始显示
    // 通过这个属性实现分页
    //request.fetchOffset = 0;
    // 每页显示多少条数据
    //request.fetchLimit = 6;

    //发送查询请求
    NSArray *resArray = [_context executeFetchRequest:request error:nil];

    NSLog(@"查询所有的美女 %@", resArray);
    
}

- (void)sortData {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Student"];
    NSSortDescriptor *ageSort = [NSSortDescriptor sortDescriptorWithKey:@"age" ascending:YES];
    NSSortDescriptor *numberSort = [NSSortDescriptor sortDescriptorWithKey:@"number" ascending:YES];
    request.sortDescriptors = @[ageSort, numberSort];
    
    NSError *err = nil;
    NSArray *resArray = [self.context executeFetchRequest:request error:&err];
    if (err == nil) {
        NSLog(@"排序");
        for (Student *stu in resArray) {
            NSLog(@"%@ %d %d", stu.name, stu.age, stu.number);
        }
    } else {
        NSLog(@"失败");
    }
}

@end
