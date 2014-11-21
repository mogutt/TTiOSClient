//  DDDatabaseUtil.m
//  Duoduo
//
//  Created by zuoye on 14-3-21.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDDatabaseUtil.h"
#import "DDMessageEntity.h"
#import "DDUserEntity.h"
#import "DDUserModule.h"
#import "DDGroupEntity.h"
#import "NSString+DDPath.h"
#import "NSDictionary+Safe.h"
#import "DDepartment.h"
#define DB_FILE_NAME                    @"Duoduo.sqlite"
#define TABLE_MESSAGE                   @"message"
#define TABLE_RECENT_CONTACTS           @"recentContacts"
#define TABLE_ALL_CONTACTS              @"allContacts"
#define TABLE_DEPARTMENTS               @"departments"
#define TABLE_RECENT_GROUPS             @"recentGroups"
#define SQL_CREATE_MESSAGE              [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (messageID text primary key,sessionId text,fromUserId text,toUserId text,content text, status integer, msgTime real, sessionType integer,messageContentType integer,messageType integer,info text,reserve1 integer,reserve2 text)",TABLE_MESSAGE]
#define SQL_CREATE_MESSAGE_INDEX        [NSString stringWithFormat:@"CREATE INDEX sessionId on %@(sessionId)",TABLE_MESSAGE]
#define SQL_CREATE_RECENT_CONTACTS      [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (ID text UNIQUE,Name text,Nick text,Avatar text, Role integer, updated real,reserve1 integer,reserve2 text)",TABLE_RECENT_CONTACTS]

#define SQL_CREATE_DEPARTMENTS      [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (ID text UNIQUE,parentID text,title text, description text,leader text, status integer,count integer)",TABLE_DEPARTMENTS]

#define SQL_CREATE_ALL_CONTACTS      [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (ID text UNIQUE,Name text,Nick text,Avatar text, Title text, Department text,DepartID text, Email text,Postion text,Role integer, JobNum integer,Telphone text,Sex integer,updated real)",TABLE_ALL_CONTACTS]

#define SQL_CREATE_RECENT_GROUPS     [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (ID text UNIQUE,Avatar text, GroupType integer, Name text,CreatID text,Users Text,LastMessage Text,updated real,isshield integer)",TABLE_RECENT_GROUPS]

#define SQL_CREATE_CONTACTS_INDEX        [NSString stringWithFormat:@"CREATE UNIQUE ID on %@(ID)",TABLE_ALL_CONTACTS]


@implementation DDDatabaseUtil
{
    FMDatabase* _database;
    FMDatabaseQueue* _dataBaseQueue;
}
+ (instancetype)instance
{
    static DDDatabaseUtil* g_databaseUtil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_databaseUtil = [[DDDatabaseUtil alloc] init];
        [NSString stringWithFormat:@""];
    });
    return g_databaseUtil;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        //初始化数据库
        [self openCurrentUserDB];
    }
    return self;
}

- (void)openCurrentUserDB
{
    if (_database)
    {
        [_database close];
        _database = nil;
    }
    _dataBaseQueue = [FMDatabaseQueue databaseQueueWithPath:[DDDatabaseUtil dbFilePath]];
    _database = [FMDatabase databaseWithPath:[DDDatabaseUtil dbFilePath]];
    
    if (![_database open])
    {
        DDLog(@"打开数据库失败");
    }
    else
    {
        
        //创建
        [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        if (![_database tableExists:TABLE_MESSAGE])
        {
            [self createTable:SQL_CREATE_MESSAGE];
        }
        if (![_database tableExists:TABLE_RECENT_CONTACTS])
        {
            [self createTable:SQL_CREATE_RECENT_CONTACTS];
        }
        if (![_database tableExists:TABLE_DEPARTMENTS])
        {
            [self createTable:SQL_CREATE_DEPARTMENTS];
        }
        if (![_database tableExists:TABLE_ALL_CONTACTS]) {
            [self createTable:SQL_CREATE_ALL_CONTACTS];
        }
        if (![_database tableExists:SQL_CREATE_RECENT_GROUPS]) {
            [self createTable:SQL_CREATE_RECENT_GROUPS];
        }
        }];
    }
}

+(NSString *)dbFilePath
{
    NSString* directorPath = [NSString userExclusiveDirection];
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    //改用户的db是否存在，若不存在则创建相应的DB目录
    BOOL isDirector = NO;
    BOOL isExiting = [fileManager fileExistsAtPath:directorPath isDirectory:&isDirector];
    
    if (!(isExiting && isDirector))
    {
        BOOL createDirection = [fileManager createDirectoryAtPath:directorPath
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:nil];
        if (!createDirection)
        {
            DDLog(@"创建DB目录失败");
        }
    }
    
    
    NSString *dbPath = [directorPath stringByAppendingPathComponent:DB_FILE_NAME];
    return dbPath;
}

-(BOOL)createTable:(NSString *)sql          //创建表
{
    BOOL result = NO;
    [_database setShouldCacheStatements:YES];
    NSString *tempSql = [NSString stringWithFormat:@"%@",sql];
    result = [_database executeUpdate:tempSql];
    [_database executeUpdate:SQL_CREATE_MESSAGE_INDEX];
    //BOOL dd =[_database executeUpdate:SQL_CREATE_CONTACTS_INDEX];
    
    return result;
}
-(BOOL)clearTable:(NSString *)tableName
{
    BOOL result = NO;
    [_database setShouldCacheStatements:YES];
    NSString *tempSql = [NSString stringWithFormat:@"DELETE FROM %@",tableName];
    result = [_database executeUpdate:tempSql];
//    [_database executeUpdate:SQL_CREATE_MESSAGE_INDEX];
//    //BOOL dd =[_database executeUpdate:SQL_CREATE_CONTACTS_INDEX];
//    
    return result;
}
- (DDMessageEntity*)messageFromResult:(FMResultSet*)resultSet
{
    
    NSString* sessionID = [resultSet stringForColumn:@"sessionId"];
    NSString* fromUserId = [resultSet stringForColumn:@"fromUserId"];
    NSString* toUserId = [resultSet stringForColumn:@"toUserId"];
    NSString* content = [resultSet stringForColumn:@"content"];
    NSUInteger msgTime = [resultSet longForColumn:@"msgTime"];
    NSUInteger messageType = [resultSet intForColumn:@"messageType"];
    NSUInteger messageContentType = [resultSet intForColumn:@"messageContentType"];
    NSString * messageID = [resultSet stringForColumn:@"messageID"];
    NSUInteger messageState = [resultSet intForColumn:@"status"];
    DDMessageEntity* messageEntity = [[DDMessageEntity alloc] initWithMsgID:messageID
                                                                    msgType:messageType
                                                                    msgTime:msgTime
                                                                  sessionID:sessionID
                                                                   senderID:fromUserId
                                                                 msgContent:content
                                                                   toUserID:toUserId];
    messageEntity.state = messageState;
    messageEntity.msgContentType = messageContentType;
    NSString* infoString = [resultSet stringForColumn:@"info"];
    if (infoString)
    {
        NSData* infoData = [infoString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary* info = [NSJSONSerialization JSONObjectWithData:infoData options:0 error:nil];
        NSMutableDictionary* mutalInfo = [NSMutableDictionary dictionaryWithDictionary:info];
        messageEntity.info = mutalInfo;

    }
    return messageEntity;
}

- (DDUserEntity*)userFromResult:(FMResultSet*)resultSet
{
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic safeSetObject:[resultSet stringForColumn:@"Name"] forKey:@"name"];
    [dic safeSetObject:[resultSet stringForColumn:@"Nick"] forKey:@"nickName"];
    [dic safeSetObject:[resultSet stringForColumn:@"ID"] forKey:@"userId"];
    [dic safeSetObject:[resultSet stringForColumn:@"Department"] forKey:@"department"];
    [dic safeSetObject:[resultSet stringForColumn:@"Title"] forKey:@"title"];
    [dic safeSetObject:[resultSet stringForColumn:@"Postion"] forKey:@"position"];
    [dic safeSetObject:[NSNumber numberWithInt:[resultSet intForColumn:@"Sex"]] forKey:@"sex"];
    [dic safeSetObject:[NSNumber numberWithInt:[resultSet intForColumn:@"Role"]] forKey:@"roleStatus"];
    [dic safeSetObject:[resultSet stringForColumn:@"DepartID"] forKey:@"departId"];
    [dic safeSetObject:[resultSet stringForColumn:@"JobNum"] forKey:@"jobNum"];
    [dic safeSetObject:[resultSet stringForColumn:@"Telphone"] forKey:@"telphone"];
    [dic safeSetObject:[resultSet stringForColumn:@"Avatar"] forKey:@"avatar"];
    [dic safeSetObject:[resultSet stringForColumn:@"Email"] forKey:@"email"];
    [dic safeSetObject:@([resultSet longForColumn:@"updated"]) forKey:@"lastUpdateTime"];
    DDUserEntity* user = [DDUserEntity dicToUserEntity:dic];
    
    return user;
}

-(DDGroupEntity *)groupFromResult:(FMResultSet *)resultSet
{
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic safeSetObject:[resultSet stringForColumn:@"Name"] forKey:@"name"];
    [dic safeSetObject:[resultSet stringForColumn:@"ID"] forKey:@"groupId"];
    [dic safeSetObject:[resultSet stringForColumn:@"Avatar"] forKey:@"avatar"];
    [dic safeSetObject:[NSNumber numberWithInt:[resultSet intForColumn:@"GroupType"]] forKey:@"groupType"];
    [dic safeSetObject:@([resultSet longForColumn:@"updated"]) forKey:@"lastUpdateTime"];
    [dic safeSetObject:[resultSet stringForColumn:@"CreatID"] forKey:@"creatID"];
    [dic safeSetObject:[resultSet stringForColumn:@"Users"] forKey:@"Users"];
    [dic safeSetObject:[resultSet stringForColumn:@"LastMessage"] forKey:@"lastMessage"];
    [dic safeSetObject:[NSNumber numberWithInt:[resultSet intForColumn:@"isshield"]] forKey:@"isshield"];
    DDGroupEntity* group = [DDGroupEntity dicToGroupEntity:dic];
    
    return group;
}

- (DDepartment*)departmentFromResult:(FMResultSet*)resultSet
{
    
    NSDictionary *dic = @{@"departID": [resultSet stringForColumn:@"ID"],
                          @"title":[resultSet stringForColumn:@"title"],
                          @"description":[resultSet stringForColumn:@"description"],
                          @"leader":[resultSet stringForColumn:@"leader"],
                          @"parentID":[resultSet stringForColumn:@"parentID"],
                          @"status":[NSNumber numberWithInt:[resultSet intForColumn:@"status"]],
                          @"count":[NSNumber numberWithInt:[resultSet intForColumn:@"count"]],
                          };
    DDepartment *deaprtment = [DDepartment departmentFromDic:dic];
    return deaprtment;
}
#pragma mark Message
 
- (void)loadMessageForSessionID:(NSString*)sessionID pageCount:(int)pagecount index:(NSInteger)index completion:(LoadMessageInSessionCompletion)completion
{
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        NSMutableArray* array = [[NSMutableArray alloc] init];
        if ([_database tableExists:TABLE_MESSAGE])
        {
            [_database setShouldCacheStatements:YES];
            
            NSString* sqlString = [NSString stringWithFormat:@"SELECT * FROM message where sessionId=? ORDER BY msgTime DESC,messageID DESC limit ?,?"];
            FMResultSet* result = [_database executeQuery:sqlString,sessionID,[NSNumber numberWithInteger:index],[NSNumber numberWithInteger:pagecount]];
            while ([result next])
            {
                DDMessageEntity* message = [self messageFromResult:result];
                [array addObject:message];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(array,nil);
            });
        }
    }];
}

- (void)loadMessageForSessionID:(NSString*)sessionID afterMessage:(DDMessageEntity*)message completion:(LoadMessageInSessionCompletion)completion
{
     [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        NSMutableArray* array = [[NSMutableArray alloc] init];
        if ([_database tableExists:TABLE_MESSAGE])
        {
            [_database setShouldCacheStatements:YES];
            NSString* sqlString = [NSString stringWithFormat:@"select * from %@ where sessionId = ? AND messageID >= ? order by msgTime DESC,rowid DESC",TABLE_MESSAGE];
            FMResultSet* result = [_database executeQuery:sqlString,sessionID,message.msgID];
            while ([result next])
            {
                DDMessageEntity* message = [self messageFromResult:result];
                [array addObject:message];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(array,nil);
            });
        }
    }];
}

- (void)getLasetCommodityTypeImageForSession:(NSString*)sessionID completion:(DDGetLastestCommodityMessageCompletion)completion
{
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        if ([_database tableExists:TABLE_MESSAGE])
        {
            [_database setShouldCacheStatements:YES];
            NSString* sqlString = [NSString stringWithFormat:@"SELECT * from %@ where sessionId=? AND messageType = ? ORDER BY msgTime DESC,rowid DESC limit 0,1",TABLE_MESSAGE];
            FMResultSet* result = [_database executeQuery:sqlString,sessionID,@(4)];
            DDMessageEntity* message = nil;
            while ([result next])
            {
                message = [self messageFromResult:result];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(message);
            });
        }
    }];
}

- (void)getLastestMessageForSessionID:(NSString*)sessionID completion:(DDDBGetLastestMessageCompletion)completion
{
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        if ([_database tableExists:TABLE_MESSAGE])
        {
            [_database setShouldCacheStatements:YES];
            
            NSString* sqlString = [NSString stringWithFormat:@"SELECT * FROM %@ where sessionId=? ORDER BY msgTime DESC,rowid DESC limit 0,1",TABLE_MESSAGE];
            
            FMResultSet* result = [_database executeQuery:sqlString,sessionID];
            DDMessageEntity* message = nil;
            while ([result next])
            {
                message = [self messageFromResult:result];
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(message,nil);
                });
                break;
            }
        }
    }];
}



- (void)getMessagesCountForSessionID:(NSString*)sessionID completion:(MessageCountCompletion)completion
{
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        if ([_database tableExists:TABLE_MESSAGE])
        {
            [_database setShouldCacheStatements:YES];
            
            NSString* sqlString = [NSString stringWithFormat:@"SELECT COUNT(*) FROM %@ where sessionId=?",TABLE_MESSAGE];
            
            FMResultSet* result = [_database executeQuery:sqlString,sessionID];
            int count = 0;
            while ([result next])
            {
                count = [result intForColumnIndex:0];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(count);
            });
        }
    }];
}

- (void)insertMessages:(NSArray*)messages
               success:(void(^)())success
               failure:(void(^)(NSString* errorDescripe))failure
{
     [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        [_database beginTransaction];
        __block BOOL isRollBack = NO;
        @try {
            [messages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                DDMessageEntity* message = (DDMessageEntity*)obj;
                NSString* sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?)",TABLE_MESSAGE];
                NSData* infoJsonData = [NSJSONSerialization dataWithJSONObject:message.info options:NSJSONWritingPrettyPrinted error:nil];
                NSString* json = [[NSString alloc] initWithData:infoJsonData encoding:NSUTF8StringEncoding];
                BOOL result = [_database executeUpdate:sql,message.msgID,message.sessionId,message.senderId,message.toUserID,message.msgContent,@(message.state),@(message.msgTime),@(1),@(message.msgContentType),@(message.msgType),json,@(0),@""];
                
                if (!result)
                {
                    isRollBack = YES;
                    *stop = YES;
                }
            }];
        }
        @catch (NSException *exception) {
            [_database rollback];
            failure(@"插入数据失败");
        }
        @finally {
            if (isRollBack)
            {
                [_database rollback];
                DDLog(@"insert to database failure content");
                failure(@"插入数据失败");
            }
            else
            {
                [_database commit];
                success();
            }
        }
    }];
}

- (void)deleteMesagesForSession:(NSString*)sessionID completion:(DeleteSessionCompletion)completion
{
     [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        NSString* sql = @"DELETE FROM message WHERE sessionId = ?";
        BOOL result = [_database executeUpdate:sql,sessionID];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(result);
        });
    }];
}

- (void)updateMessageForMessage:(DDMessageEntity*)message completion:(DDUpdateMessageCompletion)completion
{
    //(messageID integer,sessionId text,fromUserId text,toUserId text,content text, status integer, msgTime real, sessionType integer,messageType integer,reserve1 integer,reserve2 text)
     [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        NSString* sql = [NSString stringWithFormat:@"UPDATE %@ set sessionId = ? , fromUserId = ? , toUserId = ? , content = ? , status = ? , msgTime = ? , sessionType = ? , messageType = ? ,messageContentType = ? , info = ? where messageID = ?",TABLE_MESSAGE];
        NSData* infoJsonData = [NSJSONSerialization dataWithJSONObject:message.info options:NSJSONWritingPrettyPrinted error:nil];
        NSString* json = [[NSString alloc] initWithData:infoJsonData encoding:NSUTF8StringEncoding];
        BOOL result = [_database executeUpdate:sql,message.sessionId,message.senderId,message.toUserID,message.msgContent,@(message.state),@(message.msgTime),@(1),@(message.msgType),@(message.msgContentType),json,message.msgID];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(result);
        });
    }];
}

#pragma mark - Users
- (void)loadContactsCompletion:(LoadRecentContactsComplection)completion
{
     [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        NSMutableArray* array = [[NSMutableArray alloc] init];
        if ([_database tableExists:TABLE_RECENT_CONTACTS])
        {
            [_database setShouldCacheStatements:YES];
            
            NSString* sqlString = [NSString stringWithFormat:@"SELECT * FROM %@",TABLE_RECENT_CONTACTS];
            FMResultSet* result = [_database executeQuery:sqlString];
            while ([result next])
            {
                DDUserEntity* user = [self userFromResult:result];
                [array addObject:user];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(array,nil);
            });
        }
    }];
}

- (void)updateContacts:(NSArray*)users inDBCompletion:(UpdateRecentContactsComplection)completion
{
     [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        NSString* sql = [NSString stringWithFormat:@"DELETE FROM %@",TABLE_RECENT_CONTACTS];
        BOOL result = [_database executeUpdate:sql];
        if (result)
        {
            //删除原先数据成功，添加新数据
            [_database beginTransaction];
            __block BOOL isRollBack = NO;
            @try {
                [users enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    DDUserEntity* user = (DDUserEntity*)obj;
                    NSString* sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ VALUES(?,?,?,?,?,?,?,?)",TABLE_RECENT_CONTACTS];
                    //ID,Name,Nick,Avatar,Role,updated,reserve1,reserve2
                    BOOL result = [_database executeUpdate:sql,user.objID,user.name,user.nick,user.avatar,@(user.userRole),@(user.lastUpdateTime),@(0),@""];
                    if (!result)
                    {
                        isRollBack = YES;
                        *stop = YES;
                    }
                }];
            }
            @catch (NSException *exception) {
                [_database rollback];
            }
            @finally {
                if (isRollBack)
                {
                    [_database rollback];
                    DDLog(@"insert to database failure content");
                    NSError* error = [NSError errorWithDomain:@"插入最近联系人用户失败" code:0 userInfo:nil];
                    completion(error);
                }
                else
                {
                    [_database commit];
                    completion(nil);
                }
            }
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError* error = [NSError errorWithDomain:@"清除数据失败" code:0 userInfo:nil];
                completion(error);
            });
        }
        
    }];
}

- (void)updateContact:(DDUserEntity*)user inDBCompletion:(UpdateRecentContactsComplection)completion
{
     [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        
        //#define SQL_CREATE_RECENT_CONTACTS      [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (ID text,Name text,Nick text,Avatar text, Role integer, updated real,reserve1 integer,reserve2 text)",TABLE_RECENT_CONTACTS]

        NSString* sql = [NSString stringWithFormat:@"UPDATE %@ set Name = ? , Nick = ? , Avatar = ? , Role = ? , updated = ? , reserve1 = ? , reserve2 = ?where ID = ?",TABLE_RECENT_CONTACTS];

        BOOL result = [_database executeUpdate:sql,user.name,user.nick,user.avatar,@(user.userRole),@(user.lastUpdateTime),@(1),@(1),user.objID];
        if (result)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil);
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError* error = [NSError errorWithDomain:@"更新数据失败" code:0 userInfo:nil];
                completion(error);
            });
        }
        
    }];
}

- (void)insertUsers:(NSArray*)users completion:(InsertsRecentContactsCOmplection)completion
{
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        [_database beginTransaction];
        __block BOOL isRollBack = NO;
        @try {
            [users enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                DDUserEntity* user = (DDUserEntity*)obj;
                NSString* sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ VALUES(?,?,?,?,?,?,?,?)",TABLE_RECENT_CONTACTS];
                //ID,Name,Nick,Avatar,Role,updated,reserve1,reserve2
                BOOL result = [_database executeUpdate:sql,user.objID,user.name,user.nick,user.avatar,@(user.userRole),@(user.lastUpdateTime),@(0),@""];
                if (!result)
                {
                    isRollBack = YES;
                    *stop = YES;
                }
            }];
        }
        @catch (NSException *exception) {
            [_database rollback];
        }
        @finally {
            if (isRollBack)
            {
                [_database rollback];
                DDLog(@"insert to database failure content");
                NSError* error = [NSError errorWithDomain:@"插入最近联系人用户失败" code:0 userInfo:nil];
                completion(error);
            }
            else
            {
                [_database commit];
                completion(nil);
            }
        }
    }];
}
- (void)insertDepartments:(NSArray*)departments completion:(InsertsRecentContactsCOmplection)completion
{
     [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        [_database beginTransaction];
        __block BOOL isRollBack = NO;
        @try {
            [departments enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                DDepartment* department = [DDepartment departmentFromDic:obj];
                NSString* sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ VALUES(?,?,?,?,?,?,?)",TABLE_DEPARTMENTS];
                //ID,Name,Nick,Avatar,Role,updated,reserve1,reserve2
                BOOL result = [_database executeUpdate:sql,department.ID,department.parentID,department.title,department.description,department.leader,@(department.status),@(department.count)];
                if (!result)
                {
                    isRollBack = YES;
                    *stop = YES;
                }
            }];
        }
        @catch (NSException *exception) {
            [_database rollback];
        }
        @finally {
            if (isRollBack)
            {
                [_database rollback];
                DDLog(@"insert to database failure content");
                NSError* error = [NSError errorWithDomain:@"批量插入部门信息失败" code:0 userInfo:nil];
                completion(error);
            }
            else
            {
                [_database commit];
                completion(nil);
            }
        }
    }];
}
- (void)getDepartmentFromID:(NSString*)departmentID completion:(void(^)(DDepartment *department))completion
{
     [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        if ([_database tableExists:TABLE_DEPARTMENTS])
        {
            [_database setShouldCacheStatements:YES];
            
            NSString* sqlString = [NSString stringWithFormat:@"SELECT * FROM %@ where ID=?",TABLE_DEPARTMENTS];
            
            FMResultSet* result = [_database executeQuery:sqlString,departmentID];
            DDepartment* department = nil;
            while ([result next])
            {
                department = [self departmentFromResult:result];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(department);
            });
        }
    }];
}

- (void)insertAllUser:(NSArray*)users completion:(InsertsRecentContactsCOmplection)completion
{
     [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        [_database beginTransaction];
        __block BOOL isRollBack = NO;
        @try {
            if ([self clearTable:TABLE_ALL_CONTACTS]) {
                [users enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    DDUserEntity* user = (DDUserEntity *)obj;
             
                    NSString* sql = [NSString stringWithFormat:@"REPLACE INTO %@ VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?)",TABLE_ALL_CONTACTS];
                    //ID,Name,Nick,Avatar,Role,updated,reserve1,reserve2
                    BOOL result = [_database executeUpdate:sql,user.objID,user.name,user.nick,user.avatar,user.title,user.department,user.departId,user.email,user.position,@(user.roleStatus),@(user.jobNum),user.telphone,@(user.sex),user.lastUpdateTime];
                    
                    if (!result)
                    {
                        isRollBack = YES;
                        *stop = YES;
                    }
               
                }];
            }
        }
        @catch (NSException *exception) {
            [_database rollback];
        }
        @finally {
            if (isRollBack)
            {
                [_database rollback];
                DDLog(@"insert to database failure content");
                NSError* error = [NSError errorWithDomain:@"批量插入全部用户信息失败" code:0 userInfo:nil];
                completion(error);
            }
            else
            {
                [_database commit];
                completion(nil);
            }
        }
    }];
}

- (void)getAllUsers:(LoadAllContactsComplection )completion
{
     [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        if ([_database tableExists:TABLE_ALL_CONTACTS])
        {
            [_database setShouldCacheStatements:YES];
            NSMutableArray* array = [[NSMutableArray alloc] init];
            NSString* sqlString = [NSString stringWithFormat:@"SELECT * FROM %@ ",TABLE_ALL_CONTACTS];
            FMResultSet* result = [_database executeQuery:sqlString];
            DDUserEntity* user = nil;
            while ([result next])
            {
                user = [self userFromResult:result];
                [array addObject:user];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(array,nil);
            });
        }
    }];
}

- (void)getUserFromID:(NSString*)userID completion:(void(^)(DDUserEntity *user))completion
{
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        if ([_database tableExists:TABLE_ALL_CONTACTS])
        {
            [_database setShouldCacheStatements:YES];
            
            NSString* sqlString = [NSString stringWithFormat:@"SELECT * FROM %@ where ID= ?",TABLE_ALL_CONTACTS];
            FMResultSet* result = [_database executeQuery:sqlString,userID];
            DDUserEntity* user = nil;
            while ([result next])
            {
                user = [self userFromResult:result];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(user);
            });
        }
    }];
}


- (void)loadGroupsCompletion:(LoadRecentContactsComplection)completion
{
     [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        NSMutableArray* array = [[NSMutableArray alloc] init];
        if ([_database tableExists:TABLE_RECENT_GROUPS])
        {
            [_database setShouldCacheStatements:YES];
            
            NSString* sqlString = [NSString stringWithFormat:@"SELECT * FROM %@",TABLE_RECENT_GROUPS];
            FMResultSet* result = [_database executeQuery:sqlString];
            while ([result next])
            {
                DDGroupEntity* group = [self groupFromResult:result];
                [array addObject:group];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(array,nil);
            });
        }
    }];
}

- (void)updateRecentGroup:(DDGroupEntity *)group completion:(InsertsRecentContactsCOmplection)completion
{
   [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        [_database beginTransaction];
        __block BOOL isRollBack = NO;
        @try {
     
   
                NSString* sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ VALUES(?,?,?,?,?,?,?,?,?)",TABLE_RECENT_GROUPS];
                //ID Avatar GroupType Name CreatID Users  LastMessage
            NSString *users = @"";
            if ([group.groupUserIds count]>0) {
                users=[group.groupUserIds componentsJoinedByString:@"-"];
            }
                BOOL result = [_database executeUpdate:sql,group.objID,group.avatar,@(group.groupType),group.name,group.groupCreatorId,users,group.lastMsg,@(group.lastUpdateTime),@(group.isShield)];
                if (!result)
                {
                    isRollBack = YES;
                }

        }
        @catch (NSException *exception) {
            [_database rollback];
        }
        @finally {
            if (isRollBack)
            {
                [_database rollback];
                DDLog(@"insert to database failure content");
                NSError* error = [NSError errorWithDomain:@"插入最近群失败" code:0 userInfo:nil];
                completion(error);
            }
            else
            {
                [_database commit];
                completion(nil);
            }
        }
    }];
}
@end
