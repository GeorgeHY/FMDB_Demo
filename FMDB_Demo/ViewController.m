//
//  ViewController.m
//  FMDB_Demo
//
//  Created by GE on 15/12/14.
//  Copyright © 2015年 GE. All rights reserved.
//

#import "ViewController.h"
#import "FMDB.h"

@interface ViewController ()

@property (nonatomic, strong) NSString * dbPath;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString * doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    self.dbPath = [doc stringByAppendingString:@"MyDataBase.db"];
    
}

#pragma mark - 创建表
- (void)createTable
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.dbPath]) {
        FMDatabase * db = [FMDatabase databaseWithPath:self.dbPath];
        if ([db open]) {
            NSString * sql = @"CREATE TABLE 'User' ('id' INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL , 'name' VARCHAR(50), 'password' VARCHAR(50))";
            BOOL flag = [db executeUpdate:sql];
            if (flag) {
                NSLog(@"创建成功");
            }else{
                NSLog(@"创建失败");
            }
            
        }else{
            NSLog(@"[db open]失败");
        }
    }
}

#pragma mark - 插入
- (void)insertData{
    FMDatabase *db = [FMDatabase databaseWithPath:self.dbPath];
    if ([db open]) {
        NSString * sql = @"insert into User (name, password) values(?, ?) ";
        NSString * name = @"telcolor";
        BOOL res = [db executeUpdate:sql, name, @"123456"];
        if (res) {
            NSLog(@"插入成功");
        } else {
            NSLog(@"插入失败");
        }
        [db close];
    }else{
        NSLog(@"[db open]失败");
    }
}

#pragma mark - 更新
- (void)updateData{
    FMDatabase *db = [FMDatabase databaseWithPath:self.dbPath];
    if ([db open]) {
        NSString *sql = @"update User set password = ? where name = ?";
        NSString *passWord = @"112233";
        NSString *name = @"telcolor";
        BOOL res = [db executeUpdate:sql ,passWord ,name];
        if (res) {
            NSLog(@"更新成功");
        }else{
            NSLog(@"更新失败");
        }
    }else{
        NSLog(@"[db open]失败");
    }
}

#pragma mark - SELECT
- (void)selectData{
    FMDatabase *db = [FMDatabase databaseWithPath:self.dbPath];
    if ([db open]) {
        NSString *sql = @"select * from User";
        FMResultSet *set = [db executeQuery:sql];
        while ([set next]) {
            int userId = [set intForColumn:@"id"];
            NSString * name = [set stringForColumn:@"name"];
            NSString * pass = [set stringForColumn:@"password"];
            NSLog(@"user id = %d, name = %@, pass = %@", userId, name, pass);
        }
        [db close];
    }else{
        NSLog(@"[db open]失败");
    }
}

#pragma mark - TRUNCATE
- (void)truncateData{
    FMDatabase *db = [FMDatabase databaseWithPath:self.dbPath];
    if ([db open]) {
        NSString * sql = @"delete from User";
        BOOL res = [db executeUpdate:sql];
        if (res) {
            NSLog(@"删除成功");
        } else {
            NSLog(@"删除失败");
        }
        [db close];
    }else{
        NSLog(@"[db open]失败");
    }
}

#pragma mark - MULTITHREAD
- (void)mutliThread{
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:self.dbPath];
    dispatch_queue_t q1 = dispatch_queue_create("queue1", NULL);
    dispatch_queue_t q2 = dispatch_queue_create("queue2", NULL);
    
    dispatch_async(q1, ^{
        for (int i = 0; i < 100; i++) {
            [queue inDatabase:^(FMDatabase *db) {
                NSString * sql = @"insert into user (name, password) values(?, ?) ";
                NSString * name = [NSString stringWithFormat:@"user11 %d", i];
                BOOL res = [db executeUpdate:sql, name, @"boy"];
                if (res) {
                    NSLog(@"插入成功");
                } else {
                    NSLog(@"插入失败");
                }
            }];
        }
    });
    
    dispatch_async(q2, ^{
        for (int i = 0; i < 100; i++) {
            [queue inDatabase:^(FMDatabase *db) {
                NSString * sql = @"insert into user (name, password) values(?, ?) ";
                NSString * name = [NSString stringWithFormat:@"user22 %d", i];
                BOOL res = [db executeUpdate:sql, name, @"boy"];
                if (res) {
                    NSLog(@"插入成功");
                } else {
                    NSLog(@"插入失败");
                }
            }];
        }
    });
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
