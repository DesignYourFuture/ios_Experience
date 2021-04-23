//
//  Utils.swift
//  MyMemory
//
//  Created by Hamlit Jason on 2021/03/28.
//

import UIKit

extension UIViewController {
    // 익스텐션은 원래의 클래스를 수정하거나 편집하지 않고도 원하는 임의의 프로퍼티나 메소드를 추가할 수 있는 스위프트의 문법
    // 저장 프로퍼티는 정의할 수 없고, 오버라이딩도 지원하지 않는다.
    var tutorialSB : UIStoryboard {
        return UIStoryboard(name: "Tutorial", bundle: Bundle.main)
    }
    func instanceTutorialVC(name: String) -> UIViewController? {
        return self.tutorialSB.instantiateViewController(withIdentifier: name)
    }
    
    func alert(_ message : String, completion : (()->Void)? = nil) {
        
        // 메인 스레드에서 실행하도록 변경
        DispatchQueue.main.async {
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "확인", style: .cancel) { (_) in
                completion?() // completion 매개변수의 값이 nil이 아닐 때에만 실행되도록
            }
            alert.addAction(okAction)
            self.present(alert, animated: false, completion: nil)
        }
    }
}
