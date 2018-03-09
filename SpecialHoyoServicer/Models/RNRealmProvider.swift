//
//  RNRealmProvider.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/7/5.
//  Copyright © 2017年 roni. All rights reserved.
//

import Foundation
import RealmSwift


//MARK: - Realm 中间层


//MARK: - 增

/// 写事务: 单个对象 -- 也可以通过主键更新整个对象
///
/// - Parameters:
///   - object: 写入对象
///   - isPrimaryKey: 是否有主键  -- 不能够给未定义主键的对象类型传递 update: true
internal func realmWirte(model object: Object, isPrimaryKey: Bool = true) {
    
    let realm = try! Realm() // 获取默认的 realm 实例
    
    do {
        
        try realm.write {
            realm.add(object, update: isPrimaryKey) // 写事务, 将数据添加到 realm 数据库中....
        }
        
    }
    catch let error {
        
        print("realm 写入错误: \(error.localizedDescription) and Objetct: \(object)")
    }
    
}

/// 写事务: 多个对象 -- 也可以通过主键更新整个对象
///
/// - Parameters:
///   - objects: 写入对象数据
///   - isPrimaryKey: 是否有主键  -- 不能够给未定义主键的对象类型传递 update: true
internal func realmWirteModels(models objects: [Object], isPrimaryKey: Bool = true) {
    
    let realm = try! Realm() // 获取默认的 realm 实例
    
    do {
        
        try realm.write {
            realm.add(objects, update: isPrimaryKey) // 写事务, 将数据添加到 realm 数据库中....
        }
    }
    catch let error {
        
        print("realm 写入错误: \(error.localizedDescription) and Objetct: \(objects)")
    }
    
}



/// 删除数据库老数据并写入新数据
///
/// - Parameters:
///   - objects: 需要写入的数据
///   - isPrimaryKey: 主键
///   - Obj: 需要删除的老数据类型
///   - condition: 满足删除的条件
internal func realmWriteNewData<T: Object>(models objects: [Object], isPrimaryKey: Bool = true, Obj: T.Type, condition: (Results<T>) -> Results<T>?) {
    
    let realm = try! Realm() // 获取默认的 realm 实例
    
    do {
        
        try realm.write {
            
            let results = realm.objects(Obj)
            let model = condition(results)
            if let m = model {
                realm.delete(m)
            }
            realm.add(objects, update: isPrimaryKey) // 写事务, 将数据添加到 realm 数据库中....
        }
    }
    catch let error {
        
        print("realm 写入错误: \(error.localizedDescription) and Objetct: \(objects)")
    }

}


//MARK: - 删

/// 删除单个对象
///
/// - Parameters:
///   - Obj: 类
///   - condition: 满足条件的对象
internal func realmDeleteObject<T: Object>(Model Obj: T.Type, condition: (Results<T>) -> T?) {
    
    let realm = try! Realm() // 获取默认的 realm 实例
    
    let results = realm.objects(Obj)
    
    let model = condition(results)
    guard let m = model else {
        
        #if DEBUG
            
        #else
             print("没找到符合条件的对象")
        #endif
       
        return
    }
    
    do {
        
        try realm.write {
            
            realm.delete(m)
        }
    }
    catch let error {
        
        print("realm 删除错误: \(error.localizedDescription)")
    }
    
}

/// 删除满足条件的多个对象
///
/// - Parameters:
///   - Obj: 类
///   - condition: 满足条件的对象
internal func realmDeleteObjects<T: Object>(Model Obj: T.Type, condition: (Results<T>) -> Results<T>?) {
    
    let realm = try! Realm() // 获取默认的 realm 实例
    
    let results = realm.objects(Obj)
    
    let models = condition(results)
    guard let m = models else {
        print("没找到符合条件的对象")
        return
    }
    
    do {
        
        try realm.write {
            
            realm.delete(m)
        }
    }
    catch let error {
        
        print("realm 删除错误: \(error.localizedDescription)")
    }
    
}


/// 删除数据库中某个对象的所有数据
///
/// - Parameter Obj: 模型对象
internal func realmDeleteObjectsWithoutCondition<T: Object>(Model Obj: T.Type) {
    
    let realm = try! Realm() // 获取默认的 realm 实例
    
    let results = realm.objects(Obj)
    
    guard results.count > 0 else {  // 避免崩溃
        return
    }
    
    do {
        
        try realm.write {
            
            realm.delete(results)
        }
    }
    catch let error {
        
        print("realm 删除错误: \(error.localizedDescription)")
    }
    
}



/// 删除所有 -- 慎用
internal func realmDeleteAll() {
    
    let realm = try! Realm() // 获取默认的 realm 实例
    
    do {
        
        try realm.write {
            
            realm.deleteAll()
        }
    }
    catch let error {
        
        print("realm 删除错误: \(error.localizedDescription)")
    }
    
}


//MARK: - 改

/// 主键更新
///
/// - Parameters:
///   - Obj: 需要更新的类
///   - value: 需要更新的字段
///   - isPrimaryKey: 是否有主键
internal func realmUpdate<T: Object>(Model Obj: T.Type, value: [String: Any], isPrimaryKey: Bool = true) {
    
    let realm = try! Realm() // 获取默认的 realm 实例
    
    do {
        
        try realm.write {
            realm.create(Obj, value: value, update: isPrimaryKey)
        }
    }
    catch let error {
        
        print("realm 更新错误: \(error.localizedDescription)")
    }
    
}

/// 键值更新 -- 只针对有主键的 model
///
/// - Parameters:
///   - Obj: 需要更新的类
///   - value: 需要更新的  k-v
///   - isPrimaryKey: 主键
internal func realmUpdateByKVC<T: Object>(Model Obj: T.Type, value: [String: Any], primaryKey: Any) {
    
    let realm = try! Realm() // 获取默认的 realm 实例
    
    let model = realm.object(ofType: Obj, forPrimaryKey: primaryKey)
    
    guard let m = model else {
        print("没找到符合条件的对象")
        return
    }
    
    do {
        
        
        try realm.write {
            
            for (k, v) in value {
                m.setValue(v, forKey: k)
            }
        }
    }
    catch let error {
        
        print("realm 更新错误: \(error.localizedDescription)")
    }
    
}

/// 键值更新
///
/// - Parameters:
///   - Obj: 需要更新的类
///   - value: 需要更新的 k-v
///   - condition: 满足条件的对象
internal func realmUpdateByKVCForResults<T: Object>(Model Obj: T.Type, value: [String: Any], condition: (Results<T>) -> T?) {
    
    let realm = try! Realm() // 获取默认的 realm 实例
    
    let results = realm.objects(Obj)
    
    let model = condition(results)
    guard let m = model else {
        print("没找到符合条件的对象")
        return
    }
    
    do {
        
        try realm.write {
            
            for (k, v) in value {
                m.setValue(v, forKey: k)
            }
        }
    }
    catch let error {
        
        print("realm 更新错误: \(error.localizedDescription)")
    }
    
}


//MARK: - 查

/// 查询对象数组
///
/// - Parameter Obj: 查询的类
/// - Returns: 数组
internal func realmQueryResults<T: Object>(Model Obj: T.Type) -> Results<T> {
    
    let realm = try! Realm() // 获取默认的 realm 实例
    
    return realm.objects(Obj)
}

/// 查询对象
///
/// - Parameters:
///   - Obj: 查询的类
///   - condition: 满足条件
/// - Returns: models
internal func realmQueryModel<T: Object>(Model Obj: T.Type, condition: (Results<T>) -> Results<T>?) -> Results<T>? {
    
    let realm = try! Realm() // 获取默认的 realm 实例
    
    let results = realm.objects(Obj)
    
    return condition(results)
}






