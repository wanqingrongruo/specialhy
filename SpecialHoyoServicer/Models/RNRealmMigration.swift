//
//  RNRealmMigration.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/7/6.
//  Copyright © 2017年 roni. All rights reserved.
//

import Foundation
import RealmSwift


// 数据库迁移文件
// 每次更新之后修改!!!!! 特别是发布前!!!!!!!!, 如果有 model 属性的变更必须修改

/**
 * ## 说明 --- [文档](https://realm.io/cn/docs/swift/latest/#migration)
 * 新增删除表，Realm不需要做迁移
 * 新增删除字段，Realm需要做迁移, 同时需要更改版本号schemaVersion。
 * <#item2#>
 * <#item3#>
 */


internal func realmMigration() {
    
    var config = Realm.Configuration(
        
        schemaVersion: 11, // 设置新的架构版本。这个版本号必须高于之前所用的版本号（如果您之前从未设置过架构版本，那么这个版本号设置为 0）
        
        // 设置闭包，这个闭包将会在打开低于上面所设置版本号的 Realm 数据库的时候被自动调用
        migrationBlock: { migration, oldSchemaVersion in
            
            // 迁移实例
            if (oldSchemaVersion < 1) {
                
                //  migration.enumerateObjects(ofType: <#T##String#>, <#T##block: (MigrationObject?, MigrationObject?) -> Void##(MigrationObject?, MigrationObject?) -> Void#>) // 值更新
                
            }
            
            if  (oldSchemaVersion < 2){
                migration.enumerateObjects(ofType: Order.className(), { (oldObject, newObject) in  // 新增字段
                    newObject?["countdownTime"] = 0
                    newObject?["countdownString"] = nil
                })
            }
            
            //aimAddress
            if  (oldSchemaVersion < 3){
                migration.enumerateObjects(ofType: OrderDetail.className(), { (oldObject, newObject) in  // 新增字段
                    newObject?["aimAddress"] = nil
                })
                
            }
            
            // comment
            if  (oldSchemaVersion < 4){
                migration.enumerateObjects(ofType: CompletedOrderDetail.className(), { (oldObject, newObject) in  // 新增字段
                    newObject?["comment"] = nil
                })
            }

            if  (oldSchemaVersion < 5){
                migration.enumerateObjects(ofType: UserModel.className(), { (oldObject, newObject) in  // 新增字段
                    
                    newObject?["income"] = nil
                    newObject?["expenditure"] = nil
                    newObject?["finishOrder"] = nil
                    newObject?["waitOrder"] = nil
                })
            }

            if  (oldSchemaVersion < 8){
                migration.enumerateObjects(ofType: OrderDetail.className(), { (oldObject, newObject) in  // 新增字段
                    newObject?["yjCompany"] = ""
                    newObject?["yjLinker"] = ""
                    newObject?["yjPhone"] = ""
                    newObject?["yjMobile"] = ""
                })
                migration.enumerateObjects(ofType: CompletedOrderDetail.className(), { (oldObject, newObject) in  // 新增字段
                    newObject?["yjCompany"] = ""
                    newObject?["yjLinker"] = ""
                    newObject?["yjPhone"] = ""
                    newObject?["yjMobile"] = ""
                })
            }
            
            if (oldSchemaVersion < 9) {
                migration.enumerateObjects(ofType: CompletedOrderDetail.className(), { (oldObject, newObject) in  // 新增字段
                    newObject?["payMoney"] = 0.0
                })
            }
            
            if (oldSchemaVersion < 10) {
                migration.enumerateObjects(ofType: OrderDetail.className(), { (oldObject, newObject) in  // 新增字段
                    newObject?["payMoney"] = 0.0
                })
            }
            
            if (oldSchemaVersion < 11) {
                migration.enumerateObjects(ofType: OrderDetail.className(), { (oldObject, newObject) in  // 新增字段
                    newObject?["documentNumber"] = ""
                    newObject?["serviceType"] = ""
                })
                migration.enumerateObjects(ofType: CompletedOrderDetail.className(), { (oldObject, newObject) in  // 新增字段
                    newObject?["documentNumber"] = ""
                    newObject?["serviceType"] = ""
                })
            }

        }
    )
    
    config.fileURL = config.fileURL!.deletingLastPathComponent()
        .appendingPathComponent("hoyoservicer-v\(config.schemaVersion).realm")
    Realm.Configuration.defaultConfiguration = config // 告诉 Realm 为默认的 Realm 数据库使用这个新的配置对象
    
    // 现在我们已经告诉了 Realm 如何处理架构的变化，打开文件之后将会自动执行迁移
    let _ = try! Realm()
}
