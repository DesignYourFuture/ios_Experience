//
//  CSLogButton.swift
//  MyMemory
//
//  Created by Hamlit Jason on 2021/03/19.
//

import UIKit

public enum CSLogType : Int {
    case basic // 기본 로그 타입
    case title // 버튼의 타이틀을 출력
    case tag // 버튼의 태그값을 출력
}


public class CSLogButton : UIButton {
    public var logType : CSLogType = .basic // 로그 출력 타입
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setBackgroundImage(UIImage(named: "button-bg"), for: .normal)
        self.tintColor = .white
        
        self.addTarget(self, action: #selector(logging(_:)), for: .touchUpInside) // 커스텀으로 버튼 이용시 꼭 이 코드를 추가해야지만 버튼이 반응한다 ㅠㅠ
    }
    
    @objc func logging(_ sender : UIButton){
        switch self.logType {
        case .basic :
            NSLog("button clikced")
        case .title:
            let btnTitle = sender.titleLabel?.text ?? "title not exist" // 코드 해석 : 옵셔널 타입을 헤제하여 상수에 대입하되, 값이 nil이면 뒤의 값을 대신 사용하라
            NSLog("\(btnTitle) button clicked")
        case .tag:
            NSLog("\(sender.tag) button clicked")
        
        }
    }
    
}
