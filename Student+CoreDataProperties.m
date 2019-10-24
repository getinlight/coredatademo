//
//  Student+CoreDataProperties.m
//  coredatademo
//
//  Created by z on 2019/10/24.
//  Copyright © 2019 z. All rights reserved.
//
//

#import "Student+CoreDataProperties.h"

@implementation Student (CoreDataProperties)

+ (NSFetchRequest<Student *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"Student"];
}

@dynamic age;
@dynamic height;
@dynamic name;
@dynamic number;
@dynamic sex;
@dynamic weight;

@end
