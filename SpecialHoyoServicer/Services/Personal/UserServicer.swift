//
//  UserServicer.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/7/3.
//  Copyright © 2017年 roni. All rights reserved.
//

import Foundation
import SwiftyJSON

// 有关 User 的网络请求

struct UserServicer {
    
    
    
    /// app版本更新
    ///
    /// - Parameters:
    ///   - parameter: ["code": , "os": , "appname": ] // 当前版本, 系统类型android或ios,应用名
    ///   - successClourue: <#successClourue description#>
    ///   - failureClousure: <#failureClousure description#>
    static func updateAppVersion(_ parameter: [String: Any], successClourue: ((VersionInfo?) -> Void)?, failureClousure: ((String, Int) -> Void)?){
        
        _ = RNNetworkManager.shared.post(NewVersion, parameters: parameter, isToken: false, successClourue: { (result) in
            
            let data = result["data"]
          //  print("=====\(type(of: data)) === \(data)")
            var versionInfo:VersionInfo? = VersionInfo()
            if data == .null { // 数据为空即没有新版本
                versionInfo = nil
            }else{
                
                versionInfo?.id = data["id"].stringValue
                versionInfo?.versionCode = data["versioncode"].stringValue
                versionInfo?.versionName = data["versionname"].stringValue
                versionInfo?.updateCon = data["updatecon"].stringValue
                versionInfo?.os = data["os"].stringValue
                versionInfo?.appName = data["appname"].stringValue
                versionInfo?.downloadurl = data["downloadurl"].stringValue
                versionInfo?.mustUpdate = data["mustupdate"].stringValue
                versionInfo?.updateTime = data["updatetime"].stringValue
                
            }
            
            successClourue?(versionInfo)
            
        }, failureClousure: { (msg, code) in
            failureClousure?(msg, code)
        })
    }
    
    /// 本地登陆 -- 当 token 和 userId 同时存在 即为已登录
    ///
    /// - Parameters:
    ///   - successClourue: 成功回调
    ///   - failureClousure: 失败回调
    static func loginWithLocalInfo(successClourue: (() -> Void)?, failureClousure: ((String, Int) -> Void)?) {
        
        let userToken = UserDefaults.standard.object(forKey: UserDefaultsUserTokenKey) as? String
        let userId = UserDefaults.standard.object(forKey: UserIdKey) as? String
        
        if let token = userToken, let _ = userId {
            
            print("localLogin--->token: \(token)")
            successClourue?()
        }else{
            failureClousure?("token 或 userId不存在,判定为未登录", 9999)
        }
        
    }
    
    /// 获取当前用户信息 -- 登陆成功之后...不弹错误提示, 后台线程请求, 使用当前用户信息时从数据库获取, 未获取到继续请求, 如果未请求到结果再抛错
    ///
    /// - Parameters:
    ///   - successClourue: 成功回调
    ///   - failureClousure: 失败回调
    /// 说明: 再任何更新了用户的信息的地方都应该调用一次
    static func getCurrentUser(successClourue: ((UserModel) -> Void)?, failureClousure: ((String, Int) -> Void)?) {
        
        _ = RNNetworkManager.shared.post(GetCurrentUserInfo, parameters: nil, successClourue: { (result) in
            
            let data =  result["data"]
            
            // TO DO: -  写的好恶心, 需要好的映射结构 -- model 是 realm, 且命名可以自定义 -- 后台字段的命名太恶心了,一会大写一会小写......
            let user = UserModel()
            user.userId = data["userid"].stringValue
            user.realName = data["realname"].stringValue
           // user.nickName = data["nickname"].stringValue
            user.sex = data["sex"].stringValue
            user.mobile = data["mobile"].stringValue
            
            
            let tmp = data["headimgurl"].stringValue
            var headImageUrl = tmp
            if headImageUrl.contains("http") == false {
                headImageUrl = BASEURL + headImageUrl
            }
            user.headImageUrl = headImageUrl
            
            user.province = data["province"].stringValue
            user.city = data["city"].stringValue
            user.country = data["country"].stringValue
            user.teamId = data["teamid"].stringValue
            
            user.language = data["language"].stringValue
            user.ctime = data["rtime"].stringValue
            user.isReal = data["isreal"].intValue
            user.scope = data["scope"].stringValue
            user.openId = data["openid"].stringValue
            
            user.income = data["IncomeMoney"].stringValue
            user.expenditure = data["ExpenditureMoney"].stringValue
            user.finishOrder = data["finishOrderCount"].stringValue
            user.waitOrder = data["waitOrderCount"].stringValue
            
//            let groupInfo = data["GroupInfoDetails"]
//            user.groupDetails = GroupInfo()
//            user.groupDetails?.groupId = groupInfo["GroupId"].stringValue
//            user.groupDetails?.groupName = groupInfo["GroupName"].stringValue
//            user.groupDetails?.province = groupInfo["Province"].stringValue
//            user.groupDetails?.address = groupInfo["Address"].stringValue
//            user.groupDetails?.country = groupInfo["Country"].stringValue
//            user.groupDetails?.city = groupInfo["City"].stringValue
//            user.groupDetails?.memberScope = groupInfo["MemberScope"].stringValue
//            user.groupDetails?.memberState = groupInfo["MemberState"].stringValue
//            user.groupDetails?.modifyTime = groupInfo["ModifyTime"].stringValue
//            user.groupDetails?.partnerType = groupInfo["PartnerType"].stringValue
//            user.groupDetails?.createTime = groupInfo["CreateTime"].stringValue
//            user.groupDetails?.groupNumber = groupInfo["GroupNumber"].stringValue
//            user.groupDetails?.wareHouse = groupInfo["Warehouse"].stringValue
//            user.groupDetails?.longitude = groupInfo["lng"].doubleValue
//            user.groupDetails?.latitude = groupInfo["lat"].doubleValue
//            user.groupDetails?.deposit = groupInfo["deposit"].stringValue
//            
//            // 服务区域
//            let serviceArea = groupInfo["ServiceAreas"].array
//            if let areas = serviceArea {
//                
//                for item in areas {
//                    
//                    let areaModel = ServiceAreaDetail()
//                    areaModel.id = item["id"].stringValue
//                    areaModel.province = item["Province"].stringValue
//                    areaModel.city = item["City"].stringValue
//                    areaModel.country = item["Country"].stringValue
//                    areaModel.address = item["Address"].stringValue
//                    areaModel.createTime = item["CreateTime"].stringValue
//                    areaModel.groupNumber = item["GroupNumber"].stringValue
//                    areaModel.latitude = item["lat"].doubleValue
//                    areaModel.longitude = item["lng"].doubleValue
//                    
//                    user.groupDetails?.serviceArea.append(areaModel)
//                }
//            }
            
            UserDefaults.standard.setValue(data["mobile"].stringValue, forKey: UserMobile) // 
            realmWirte(model: user, isPrimaryKey: true) // 想数据库中写入数据
            
            successClourue?(user)
            
            
        }, failureClousure: { (msg, code) in
            failureClousure?(msg, code)
        })
    }
    
    
    /// 登录
    ///
    /// - Parameters:
    ///   - phone: 手机号
    ///   - password: 密码
    ///   - successClourue: 成功回调
    ///   - failureClousure: 失败回调
    static func login(_ phone: String, password: String, successClourue: ((UserModel) -> Void)?, failureClousure: ((String, Int) -> Void)?) {
        
        _ = RNNetworkManager.shared.post(APPLogin, parameters:  ["phone": phone,"password": password], isToken: false, successClourue: { (result) in
            
            
            let user = UserModel()
            user.userToken = result["msg"].stringValue
            //  print(type(of: result["data"]!))
            user.userId = result["data"].stringValue
            
            // 保存 token 和 userId -- 用于本地登陆, 退出登陆需要删除
            UserDefaults.standard.set(result["msg"].stringValue, forKey: UserDefaultsUserTokenKey)
            UserDefaults.standard.set(result["data"].stringValue, forKey: UserIdKey)
            
            print("login--->token: \(result["msg"].stringValue)")
            
            realmWirte(model: user, isPrimaryKey: true) // 想数据库中写入数据
            
            successClourue?(user)
            
            
            
        }, failureClousure: { (msg, code) in
            failureClousure?(msg, code)
        })
    }
    
    
    /// 获取验证码
    ///
    /// - Parameters:
    ///   - parameter:  ["mobile": mobile,"order": order,"scope":"engineer"] => 注册: order = register(注册), ResetPassword(修改密码)
    ///   - successClourue: <#successClourue description#>
    ///   - failureClousure: <#failureClousure description#>
    static func sendPhoneCode(_ parameter: [String: Any], successClourue: (() -> Void)?, failureClousure: ((String, Int) -> Void)?){
        RNNetworkManager.shared.post(SendPhoneCode, parameters: parameter,  isToken: false, successClourue: { (_) in
            successClourue?()
        }) { (msg, code) in
            failureClousure?(msg, code)
        }
    }
    
    
    /// 注册
    ///
    /// - Parameters:
    ///   - parameter: [mobil,code,password,yqCode]
    ///   - successClourue: <#successClourue description#>
    ///   - failureClousure: <#failureClousure description#>
    static func register(_ parameter: [String: Any], successClourue: ((UserModel) -> Void)?, failureClousure: ((String, Int) -> Void)?){
        RNNetworkManager.shared.post(APPRegister, parameters: parameter, isToken: false, successClourue: { (result) in
            
            let user = UserModel()
            user.userToken = result["msg"].stringValue
            user.userId = result["data"].stringValue
            
            // 保存 token 和 userId -- 用于本地登陆, 退出登陆需要删除
            UserDefaults.standard.set(result["msg"].stringValue, forKey: UserDefaultsUserTokenKey)
            UserDefaults.standard.set(result["data"].stringValue, forKey: UserIdKey)
            
            print("register--->token: \(result["msg"].stringValue)")
            
            realmWirte(model: user, isPrimaryKey: true) // 想数据库中写入数据
            
            successClourue?(user)

        }) { (msg, code) in
            failureClousure?(msg, code)
        }
    }
    
    
    /// 修改密码
    ///
    /// - Parameters:
    ///   - parameter: ["phone": , "code": , "password": ]
    ///   - successClourue: <#successClourue description#>
    ///   - failureClousure: <#failureClousure description#>
    static func resetPassword(_ parameter: [String: Any], successClourue: (() -> Void)?, failureClousure: ((String, Int) -> Void)?){
        
        RNNetworkManager.shared.post(ResetPassword, parameters: parameter, isToken: false, successClourue: { (_) in
            successClourue?()
        }) { (msg, code) in
            failureClousure?(msg, code)
        }
    }
    
    
    /// 上传实名信息
    ///
    /// - Parameters:
    ///   - parameter: ["name": , "cardid": , "cardfront": cardbehind: ] => 身份证正面，文件名必须为:cardfront; 身份证反面，文件名必须为:cardbehind
    ///   - successClourue: <#successClourue description#>
    ///   - failureClousure: <#failureClousure description#>
    static func uploadAuthinfo(_ parameter: [String: Any], frontImage: UIImage, behindImage: UIImage, successClourue: ((Int) -> Void)?, failureClousure: ((String, Int) -> Void)?){
        
        RNNetworkManager.shared.upload(UploadAuthInfo, parameters: parameter, multipartFormData: { (multipartData) in
            
            let frontData = UIImageJPEGRepresentation(frontImage, 0.1)
            if let data = frontData {
                multipartData.append(data, withName: "cardfront", fileName: "cardfront", mimeType: "image/png")
            }
        
            let behindData = UIImageJPEGRepresentation(behindImage, 0.1)
            if let data = behindData {
                multipartData.append(data, withName: "cardbehind", fileName: "cardbehind", mimeType: "image/png")
            }

            for (key, value) in parameter{
                
                if let v = (value as? String), let r = v.data(using: String.Encoding.utf8, allowLossyConversion: true){
                    multipartData.append(r, withName: key)
                }
            }

            
        }, progressClousure: { (_) in
            //
        }, successClourue: { (result) in
            let state = result["state"].intValue
            successClourue?(state)
            
        })  { (msg, code) in
            failureClousure?(msg, code)
        }
    }
    
    
    /// 获取实名认证信息
    ///
    /// - Parameters:
    ///   - parameter: 登录即可
    ///   - successClourue: <#successClourue description#>
    ///   - failureClousure: <#failureClousure description#>
    static func getAuthinfo(_ parameter: [String: Any], successClourue: ((Int, AuthInfoModel?) -> Void)?, failureClousure: ((String, Int) -> Void)?){
        RNNetworkManager.shared.post(GetAuthInfo, parameters: parameter, successClourue: { (result) in
            
            // 1: 暂未提交, 2: 正在审核, 3: 已通过审核, 4: 已拒绝,请重新提交
            let state = result["state"].intValue
            
            if state == 1 {
                
                successClourue?(state, nil)
                
                return
            }
            let data = result["data"]
            let model = AuthInfoModel()
            model.name = data["name"].stringValue
            model.cardId = data["cardid"].stringValue
            
            let tmp = data["imgfront"].stringValue
            var frontImageUrl = tmp
            if frontImageUrl.contains("http") == false {
                frontImageUrl = BASEURL + frontImageUrl
            }
            model.imageFront = frontImageUrl
            
            let tmp02 = data["imgbehind"].stringValue
            var behindImageUrl = tmp02
            if behindImageUrl.contains("http") == false {
                behindImageUrl = BASEURL + behindImageUrl
            }
            model.imageBehind = behindImageUrl
            
            successClourue?(state, model)
            
        }) { (msg, code) in
            failureClousure?(msg, code)
        }
    }
    
    /// 获取用户身份标识
    ///
    /// - Parameters:
    ///   - parameter: ["userid": userid]
    ///   - successClourue: <#successClourue description#>
    ///   - failureClousure: <#failureClousure description#>
    static func memberIdentifier(_ parameter: [String: Any], successClourue: ((UserIdentifier) -> Void)?, failureClousure: ((String, Int) -> Void)?){
        
        _ = RNNetworkManager.shared.post(MemberIdentifier, parameters: parameter, successClourue: { (result) in
            let dataContent = result["data"]
            
            let userIndentifier = UserIdentifier()
            userIndentifier.identifier = result["state"].stringValue
            
            // 1 = 该用户为团队创建人
            // 2 = 该用户为小组负责人
            // 3 = 该用户为小组成员
            // 4 = 该用户未在任何团队中
            switch userIndentifier.identifier {
                
            case "1"?:
                userIndentifier.groupId = dataContent["GroupNumber"].stringValue
                userIndentifier.state = dataContent["GropState"].stringValue
                
                break
            case "2"?:
                userIndentifier.groupId = dataContent["TeamID"].stringValue
                userIndentifier.state = dataContent["AuditState"].stringValue
                break
            case  "3"?:
                userIndentifier.groupId = dataContent["TeamID"].stringValue
                userIndentifier.state = dataContent["State"].stringValue
                break
            default:
                break

            }
            
            successClourue?(userIndentifier)
            
        }, failureClousure: { (msg, code) in
            failureClousure?(msg, code)
        })
    }
    
    
    
    /// 小组列表 - 团队
    ///
    /// - Parameters:
    ///   - parameter:  ["groupid": groupId]
    ///   - successClourue: <#successClourue description#>
    ///   - failureClousure: <#failureClousure description#>
    static func groupListInTeam(_ parameter: [String: Any], successClourue: (([GroupDetail]) -> Void)?, failureClousure: ((String, Int) -> Void)?){
        _ = RNNetworkManager.shared.post(TeamList, parameters: parameter, successClourue: { (data) in
            
            let dataContent = data["data"].array
            
            var dataArray = [GroupDetail]()
            for item in dataContent! {
                let model = GroupDetail()
                model.groupName = item["TeamName"].stringValue
                model.groupId = item["TeamID"].stringValue
                model.leaderId = item["LeaderID"].stringValue
                dataArray.append(model)
            }
            
            successClourue?(dataArray)
        },  failureClousure: { (msg, code) in
            failureClousure?(msg, code)
        })
    }
    
    
    /// 团队详情
    ///
    /// - Parameters:
    ///   - parameter: ["groupid": teamId]
    ///   - successClourue: <#successClourue description#>
    ///   - failureClousure: <#failureClousure description#>
    static func teamDetail(_ parameter: [String: Any], successClourue: ((GroupDetail) -> Void)?, failureClousure: ((String, Int) -> Void)?){
        
        _ = RNNetworkManager.shared.post(GroupDetails, parameters: parameter, successClourue: { (data) in
            
            let dataContent = data["data"]
            
            let model = GroupDetail()
            
            model.groupId = dataContent["GroupId"].stringValue
            model.groupName = dataContent["GroupName"].stringValue
            model.leaderName = dataContent["LeaderName"].stringValue
            model.mobile = dataContent["LeaderPhone"].stringValue
            model.title = dataContent["PartnerType"].stringValue
            
            let areas = dataContent["servicearea"].array
            
            if let arr = areas {
                
                for item in arr {
                    let areaModel = ServiceAreaDetail()
                    areaModel.id = item["id"].stringValue
                    areaModel.address = item["Address"].stringValue
                    areaModel.province = item["Province"].stringValue
                    areaModel.city = item["City"].stringValue
                    areaModel.country = item["Country"].stringValue
                    areaModel.latitude = item["lat"].doubleValue
                    areaModel.longitude = item["lng"].doubleValue
                    model.serviceArea.append(areaModel)
                }
            }
            
            
            successClourue?(model)

        }, failureClousure: { (msg, code) in
            failureClousure?(msg, code)
        })
    }
    
    /// 成员列表 - 小组
    ///
    /// - Parameters:
    ///   - parameter:  ["teamid": teamId]
    ///   - success: <#success description#>
    ///   - failure: <#failure description#>
    static func teamMemberList(_ parameter: [String: Any], successClourue: (([TeamMembers]) -> Void)?, failureClousure: ((String, Int) -> Void)?){
        _ =   RNNetworkManager.shared.post(MemberList, parameters: parameter, successClourue: { (result) in
            
            let dataContent = result["data"].array
            
            var dataArray = [TeamMembers]()
            
            if let content = dataContent {
                
                for item in content {
                    let model = TeamMembers()
                    let tmp = item["headimgurl"].stringValue
                    var headImageUrl = tmp
                    if headImageUrl.contains("http") == false {
                        headImageUrl = BASEURL + headImageUrl
                    }
                    model.headimageurl = headImageUrl
                    
                    model.userid = item["engineerid"].stringValue
                    model.nickname = item["realname"].stringValue
                    model.title = item["partnertype"].stringValue
                    dataArray.append(model)
                }
                
            }
            
           // realmWirteModels(models: dataArray)
            successClourue?(dataArray)
        }, failureClousure: { (msg, code) in
            failureClousure?(msg, code)
        })
    }

    
    /// 小组详情
    ///
    /// - Parameters:
    ///   - parameter:  ["teamid": teamId]
    ///   - successClourue: <#successClourue description#>
    ///   - failureClousure: <#failureClousure description#>
    static func groupDetail(_ parameter: [String: Any], successClourue: ((GroupDetail) -> Void)?, failureClousure: ((String, Int) -> Void)?){
        
        _ = RNNetworkManager.shared.post(TeamDetail, parameters: parameter, successClourue: { (data) in
            
            let dataContent = data["data"]
            
            let model = GroupDetail()
            
            model.groupId = dataContent["teamid"].stringValue
            model.groupName = dataContent["teamname"].stringValue
            model.leaderName = dataContent["leadername"].stringValue
            model.mobile = dataContent["mobile"].stringValue
            model.title = dataContent["partnertype"].stringValue
            
            let areas = dataContent["servicearea"].array
            
            if let arr = areas {
                
                for item in arr {
                    let areaModel = ServiceAreaDetail()
                    areaModel.id = item["id"].stringValue
                    areaModel.address = item["Address"].stringValue
                    areaModel.province = item["Province"].stringValue
                    areaModel.city = item["City"].stringValue
                    areaModel.country = item["Country"].stringValue
                    areaModel.latitude = item["lat"].doubleValue
                    areaModel.longitude = item["lng"].doubleValue
                    model.serviceArea.append(areaModel)
                }
            }
            
            
            successClourue?(model)

        },  failureClousure: { (msg, code) in
            failureClousure?(msg, code)
        })
    }
    
    
    /// 成员详情
    ///
    /// - Parameters:
    ///   - parameter:  ["userid": userid]
    ///   - successClourue: <#successClourue description#>
    ///   - failureClousure: <#failureClousure description#>
    static func teamMemberDetails(_ parameter: [String: Any], successClourue: ((TeamMembers) -> Void)?, failureClousure: ((String, Int) -> Void)?){
        _ = RNNetworkManager.shared.post(MemberDetail, parameters: parameter, successClourue: { (data) in
            let dataContent = data["data"]
            
            let model = TeamMembers()
            
            model.mobile = dataContent["mobile"].stringValue
            
            let areas = dataContent["servicearea"].array
            
            if let arr = areas {
                
                for item in arr {
                    let areaModel = ServiceAreaDetail()
                    areaModel.id = item["id"].stringValue
                    areaModel.address = item["Address"].stringValue
                    areaModel.province = item["Province"].stringValue
                    areaModel.city = item["City"].stringValue
                    areaModel.country = item["Country"].stringValue
                    areaModel.latitude = item["lat"].doubleValue
                    areaModel.longitude = item["lng"].doubleValue
                    model.serviceArea.append(areaModel)
                }
            }
            
            successClourue?(model)

        },failureClousure: { (msg, code) in
            failureClousure?(msg, code)
        })
    }
    
    
    /// 搜索小组列表
    ///
    /// - Parameters:
    ///   - parameter: ["query": query]
    ///   - successClourue: <#successClourue description#>
    ///   - failureClousure: <#failureClousure description#>
    static func queryTeamList(_ parameter: [String: Any], successClourue: (([GroupDetail]) -> Void)?, failureClousure: ((String, Int) -> Void)?){
        
        _ = RNNetworkManager.shared.post(QueryTeamList, parameters: parameter, successClourue: { (data) in
            
            let dataContent = data["data"].array
            
            var dataArray = [GroupDetail]()
            for item in dataContent! {
                let model = GroupDetail()
                model.groupName = item["TeamName"].stringValue
                model.groupId = item["TeamId"].stringValue
                model.leaderId = item["LeaderID"].stringValue
                dataArray.append(model)
            }
            
            successClourue?(dataArray)
        }, failureClousure: { (msg, code) in
            failureClousure?(msg, code)
        })
    }
    
    
    /// 加入小组
    ///
    /// - Parameters:
    ///   - parameter: ["teamid": teamId]
    ///   - successClourue: <#successClourue description#>
    ///   - failureClousure: <#failureClousure description#>
    static func joinTeam(_ parameter: [String: Any], successClourue: (() -> Void)?, failureClousure: ((String, Int) -> Void)?){
        
        _ = RNNetworkManager.shared.post(JoinTeam, parameters: parameter, successClourue: { (data) in
            successClourue?()
        }, failureClousure: { (msg, code) in
            failureClousure?(msg, code)
        })
    }
    
    
    /// 创建团队
    ///
    /// - Parameters:
    ///   - parameter: <#parameter description#>
    ///   - successClourue: <#successClourue description#>
    ///   - failureClousure: <#failureClousure description#>
    static func createTeam(_ parameter: [String: Any], successClourue: (() -> Void)?, failureClousure: ((String, Int) -> Void)?){
        
        _ = RNNetworkManager.shared.post(CreateGroup, parameters: parameter, successClourue: { (data) in
            successClourue?()
        },  failureClousure: { (msg, code) in
            failureClousure?(msg, code)
        })
    }
    
    
    /// 创建小组
    ///
    /// - Parameters:
    ///   - parameter: <#parameter description#>
    ///   - successClourue: <#successClourue description#>
    ///   - failureClousure: <#failureClousure description#>
    static func createGroup(_ parameter: [String: Any], successClourue: (() -> Void)?, failureClousure: ((String, Int) -> Void)?){
        
        _ = RNNetworkManager.shared.post(CreateTeam, parameters: parameter, successClourue: { (data) in
            successClourue?()
        },  failureClousure: { (msg, code) in
            failureClousure?(msg, code)
        })
    }

    
    /// 绑定极光推送
    ///
    /// - Parameters:
    ///   - parameter: ["notifyid":notifyid]
    ///   - successClourue: <#successClourue description#>
    ///   - failureClousure: <#failureClousure description#>
    static func bingJpush(_ parameter: [String: Any], successClourue: (() -> Void)?, failureClousure: ((String, Int) -> Void)?){
        _ = RNNetworkManager.shared.post(BingJpushId, parameters: parameter, successClourue: { (data) in
            successClourue?()
        },  failureClousure: { (msg, code) in
            failureClousure?(msg, code)
        })
    }
    
    
    /// 更新个人信息
    ///
    /// - Parameters:
    ///   - parameter:  ["headImage": imageData,"province": province,"city": city,"sex": sexParam]
    ///   - headImage: 头像文件
    ///   - successClourue: <#successClourue description#>
    ///   - failureClousure: <#failureClousure description#>
    static func updateUserInfo(_ parameter: [String: Any], headImage: UIImage?,successClourue: (() -> Void)?, failureClousure: ((String, Int) -> Void)?){
        
        _ = RNNetworkManager.shared.upload(UpdateUserInfo, parameters: parameter, multipartFormData: { (multipartData) in
            
            
            if let image = headImage {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyyMMddHHmmss"
                let name = formatter.string(from: Date())
                let fileName = NSString(format: "%@", name)
                
                let imageData = UIImageJPEGRepresentation(image, 0.1)
                
                if let data = imageData{
                    multipartData.append(data, withName:String(format: "%@%d", fileName,01), fileName: "headImage", mimeType: "image/png")
                }
            }
          
            for (key, value) in parameter{
                
                if let v = (value as? String), let r = v.data(using: String.Encoding.utf8, allowLossyConversion: true){
                    multipartData.append(r, withName: key)
                    
                }
            }
            
        }, progressClousure: { (pregress) in
            //
        }, successClourue: { (result) in
            successClourue?()
        }, failureClousure: { (msg, code) in
            failureClousure?(msg, code)
        })
    }
    
    
    /// 我的考试
    ///
    /// - Parameters:
    ///   - parameter: [pageindex: ,pagesize:]
    ///   - successClourue: <#successClourue description#>
    ///   - failureClousure: <#failureClousure description#>
    static func getMyExam(_ parameter: [String: Any], successClourue: (([ExamModel]) -> Void)?, failureClousure: ((String, Int) -> Void)?){
        
        RNNetworkManager.shared.post(Examination, parameters: parameter, successClourue: { (data) in
            
            if parameter["pageindex"] as! Int == 1 {
                // 移除数据库数据
               realmDeleteObjectsWithoutCondition(Model: ExamModel.self)
            }
            

            
            let dataContent = data["data"].array
            
            var dataArray = [ExamModel]()
            
            if let datas = dataContent {
                for item in datas {
                    
                    let model = ExamModel()
                    model.id = item["ID"].stringValue
                    model.subject = item["Subject"].stringValue
                    model.userName = item["UserName"].stringValue
                    model.fullName = item["FullName"].stringValue
                    model.department = item["Department"].stringValue
                    model.post = item["Post"].stringValue
                    model.score = item["Score"].stringValue
                    model.isPass = item["IsPass"].stringValue
                  //  model.testDate = item["TestDate"].stringValue
                    model.createTime = item["CreateTime"].stringValue
                    
                    let time = item["TestDate"].stringValue
                    if time != "" {
                        let date = RNDateTool.dateFromServiceTimeStamp(time)
                        if let d = date {
                            model.testDate = RNDateTool.stringFromDate(d, dateFormat: "yyyy/MM/dd")
                        }else{
                            model.testDate = ""
                        }
                    }else{
                        model.testDate = time
                    }

                    dataArray.append(model)
                }

            }
            
            realmWirteModels(models: dataArray)
            successClourue?(dataArray.map({ (model) -> ExamModel in
                return model.copy() as! ExamModel
            }))
        }, failureClousure: { (msg, code) in
            failureClousure?(msg, code)
        })
    }
    
    
    /// 直通车信息查询
    ///
    /// - Parameters:
    ///   - parameter: ["serviceid":serviceid]
    ///   - successClourue: <#successClourue description#>
    ///   - failureClousure: <#failureClousure description#>
    static func checkServiceTrain(_ parameter: [String: Any], successClourue: ((_ ServiceId:String,_ MachineKind:String,_ MachineBrand:String,_ UserPhone:String) -> Void)?, failureClousure: ((String, Int) -> Void)?){
        
        RNNetworkManager.shared.post(ServiceTrain, parameters: parameter, successClourue: { (result) in
            
            let data = result["data"]
            let serviceId = data["ServiceId"].stringValue
            let machineKind = data["MachineKind"].stringValue
            let machineBrand = data["MachineBrand"].stringValue
            let userPhone = data["UserPhone"].stringValue
            
            successClourue?(serviceId, machineKind, machineBrand, userPhone)
            
        }, failureClousure: { (msg, code) in
            failureClousure?(msg, code)
        })

    }
    
    
    /// 更新直通车信息
    ///
    /// - Parameters:
    ///   - parameter: ["serviceid":serviceid,"MachineKind":MachineKind,"MachineBrand":MachineBrand,"UserPhone":UserPhone]
    ///   - successClourue: <#successClourue description#>
    ///   - failureClousure: <#failureClousure description#>
    static func updateServiceTrain(_ parameter: [String: Any], successClourue: (() -> Void)?, failureClousure: ((String, Int) -> Void)?){
        
        RNNetworkManager.shared.post(UpdateServiceTrain, parameters: parameter, successClourue: { (data) in
        
            successClourue?()
        },  failureClousure: { (msg, code) in
        
            failureClousure?(msg, code)
        })
    }
    
    
    /// 直通车记录
    ///
    /// - Parameters:
    ///   - parameter: ["servicecode":servicecode,"pageindex":pageindex,"pagesize":pagesize]
    ///   - successClourue: <#successClourue description#>
    ///   - failureClousure: <#failureClousure description#>
    static func serviceTrainRecord(_ parameter: [String: Any], successClourue: (([Order]) -> Void)?, failureClousure: ((String, Int) -> Void)?){
        
        let _ = RNNetworkManager.shared.post(ServiceTrainRecord, parameters: parameter, successClourue: { (result) in
            
            let data = result["data"].array
            if let items = data {
                
                var array = [Order]()
                for item in items {
                    
                    let order = Order()
                    
                    
                    order.crmId = item["CRMID"].stringValue
                    order.serviceItem = item["ServiceItem"].stringValue
                    order.clientName = item["ClientName"].stringValue
                    order.clientMobile = item["ClientMobile"].stringValue
                    order.userPhone = item["UserPhone"].stringValue
                    order.createTime = item["CreateTime"].stringValue
                    
                    order.province = item["Province"].stringValue
                    order.city = item["City"].stringValue
                    order.country = item["Country"].stringValue
                    order.address = item["Address"].stringValue
                    order.describle = item["Describe"].stringValue
                    order.latitude = item["Lat"].doubleValue
                    order.longitude = item["Lng"].doubleValue
                    order.actionType = item["ActionType"].stringValue
                    
                    let productInfo = item["productinfo"]
                    order.productInfo = ProductInfo()
                    order.productInfo?.companyID = productInfo["CompanyID"].stringValue
                    order.productInfo?.companyName = productInfo["CompanyName"].stringValue
                    order.productInfo?.productNumber = productInfo["ProductNumber"].stringValue
                    order.productInfo?.productModel = productInfo["ProductModel"].stringValue
                    order.productInfo?.productName = productInfo["ProductName"].stringValue
                    order.productInfo?.image = productInfo["Image"].stringValue
                    order.productInfo?.productKind = productInfo["ProductKind"].stringValue
                    
                    
                    array.append(order)
                }
                
                successClourue?(array)
                
            }else{
                let array = [Order]()
                successClourue?(array)
            }
            
        }) { (msg, code) in
            failureClousure?(msg, code)
        }

    }
}
