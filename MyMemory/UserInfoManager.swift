//
//  UserInfoManager.swift
//  MyMemory
//
//  Created by Hamlit Jason on 2021/03/28.
//

import UIKit
import Alamofire

struct UserInfoKey {
    //저장에 사용할 키
    static let loginId = "LOGINID"
    static let account = "ACCOUNT"
    static let name = "MAME"
    static let profile = "PROFILE"
    static let tutorial = "TUTORIAL"
}

// 계정 및 사용자 정보를 저장 관리하는 클래스
class  UserInfoManager {
    
    var loginId : Int {
        get { // 읽기
            return UserDefaults.standard.integer(forKey: UserInfoKey.loginId)
        }
        set(v){ // 쓰기
            let ud = UserDefaults.standard
            ud.set(v,forKey: UserInfoKey.loginId)
            ud.synchronize()
        }
    }
    
    var account : String? {
        get { // 읽기
            return UserDefaults.standard.string(forKey: UserInfoKey.account)
        }
        set(v){ // 쓰기
            let ud = UserDefaults.standard
            ud.set(v,forKey: UserInfoKey.account)
            ud.synchronize()
        }
    }
    
    var name : String? {
        get { // 읽기
            return UserDefaults.standard.string(forKey: UserInfoKey.name)
        }
        set(v){ // 쓰기
            let ud = UserDefaults.standard
            ud.set(v,forKey: UserInfoKey.name)
            ud.synchronize()
        }
    }
    
    var profile : UIImage? {
        get { // 읽기
            let ud = UserDefaults.standard
            if let _profile = ud.data(forKey: UserInfoKey.profile) {
                return UIImage(data: _profile) // 이미지가 없다면 기본 이미지로
            } else {
                return UIImage(named: "account.jpg") // 이미지가 없다면 기본 이미지로
            }
            
        }
        set(v){ // 쓰기
            if v != nil {
                let ud = UserDefaults.standard
                ud.set(v!.pngData(),forKey: UserInfoKey.profile) // UIImage를 Data타입으로 변환하기 위해 pngData()사용 - 이미지를 직접 저장할 수 없어서 Data타입으로 변환해야한다.
                ud.synchronize()
            }
        }
    }
    
    var isLogin : Bool {
        // 로그인 아이디가 0이거나 계정이 비어 있으면
        if self.loginId == 0 || self.account == nil {
            return false
        } else {
            return true
        }
    }
    
    func login(account: String, passwd: String, success: (()->Void)? = nil, fail:((String)->Void)? = nil) {
        /*
         반환타입도 비동기식으로 바꾸면서 변경하였는데
         성공시에는 인자값 없이 그냥 호출할 수 있는 타입인 반면
         실패시에는 string 타입으로 한다 왜냐하면 실패 사유를 확인해야 하기 때문이다.
         */
        
        
        /* 동기식방식의 코드
        if account.isEqual("lgvv") && passwd.isEqual("1234") { // 서버와 연결하기 전 샘플 계정
            let ud = UserDefaults.standard
            ud.set(100, forKey: UserInfoKey.loginId)
            ud.set(account, forKey: UserInfoKey.account)
            ud.set("건우 씨", forKey: UserInfoKey.name)
            ud.synchronize()
            return true
        } else {
            return false
        }
         */
        
        // 1. URL과 전송할 값 준비
        let url = "http://swiftapi.rubypaper.co.kr:2029/userAccount/login"
        let param: Parameters = [
          "account": account,
          "passwd" : passwd
        ]
     
        let call = AF.request(url,method: .post, parameters: param, encoding: JSONEncoding.default) // API 호출
        
        // API 호출 결과 처리
        call.responseJSON { res in
            let result = try! res.result.get()
            guard let jsonObject =  result as? NSDictionary else { // JSON형식으로 응답했는지 확인
                fail?("잘못된 응답 형식 : \(result)")
                return
            }
        
        
            let resultCode = jsonObject["result_code"] as! Int // user_info 이하 항목을 딕셔너리 형태로 추출하여 저장
            if resultCode == 0 { // 응답코드 0 이면 성공 - 로그인 성공
                let user = jsonObject["user_info"] as! NSDictionary
                self.loginId = user["user_id"] as! Int
                self.account = user["account"] as? String
                self.name = user["name"] as? String
            
                if let path = user["profile_path"] as? String {
                    if let imageData = try? Data(contentsOf: URL(string: path)!) {
                        self.profile = UIImage(data: imageData)
                    }
                }
                success?() // 인자값으로 입력된 success 클로저 블록을 실행한다.
        
            } else { // 그렇지 않으면 실패 - 로그인 실패
                let msg = (jsonObject["error_msg"] as? String) ?? "로그인이 실패하였습니다."
                fail?(msg)
            }
        }
    }

    func logout() -> Bool {
        let ud = UserDefaults.standard
        ud.removeObject(forKey: UserInfoKey.loginId)
        ud.removeObject(forKey: UserInfoKey.account)
        ud.removeObject(forKey: UserInfoKey.name)
        ud.removeObject(forKey: UserInfoKey.profile)
        ud.synchronize()
        return true
    }
    
}
