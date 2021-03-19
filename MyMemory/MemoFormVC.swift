//
//  MemoFormVC.swift
//  MyMemory
//
//  Created by Hamlit Jason on 2021/03/08.
//

import UIKit

class MemoFormVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {

    var subject : String!
    
    @IBOutlet weak var contents: UITextView!
    @IBOutlet weak var preview: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.contents.delegate = self // 셀프로 지정함으로써 사용자가 무언가 입력할 때 델리게이트를 통해 자동으로 호출해 주도록 한다.
        // Do any additional setup after loading the view.
        
        let bgImage = UIImage(named: "memo-background.png")!
        self.view.backgroundColor = UIColor(patternImage: bgImage) // 패턴화된 이미지를 배경 색상처럼 사용할 수 있는 초기화 메소드를 제공 이미지가 작으면 퍂턴처럼 반복된다.
        
        // 텍스트 뷰의 기본 속성
        self.contents.layer.borderWidth = 0
        self.contents.layer.borderColor = UIColor.clear.cgColor
        self.contents.backgroundColor = UIColor.clear // 배경색 제거
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 9
        self.contents.attributedText = NSAttributedString(string: " ", attributes: [.paragraphStyle : style])
        self.contents.text = ""
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 사용자가 뷰를 터치했을 때, 나타나는 이벤트로 토글을 처리하기 위해 따로 액션 메소드를 구현하지 않아도 된다.
        let bar = self.navigationController?.navigationBar
        
        let ts = TimeInterval(0.3) // 시간간격 3초
        UIView.animate(withDuration: ts) {
            bar?.alpha = ( bar?.alpha == 0 ? 1 : 0) // 투명도에 대한건데, 바의 투명도에 따라 1과 0을 반복 0.3초씩 반복되면서
        }
    }
    
    // 저장 버튼 클릭 시 호출되는 메소드
    @IBAction func save(_ sender: Any) {
        // 경고창에 사용될 컨텐츠 뷰 컨트롤러의 구성
        let alertV = UIViewController()
        let iconImage = UIImage(named: "warning-icon-60")
        alertV.view = UIImageView(image: iconImage)
        alertV.preferredContentSize = iconImage?.size ?? CGSize.zero
        
        guard self.contents.text?.isEmpty == false else {
            // 내용을 입력하지 않았을 경우 경고한다.
            let alert = UIAlertController(title: nil, message: "내용을 입력해주세요.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            alert.setValue(alertV, forKey: "contentViewController")
            self.present(alert, animated: true)
            return
        }
        
        let data = MemoData() // 메모 데이타 객체를 생성하고, 데이터를 담는다.
        
        data.title = self.subject
        data.contents = self.contents.text
        data.image = self.preview.image
        data.regdate = Date() // 작성 시각
        
        // 앱 델리게이트 객체를 읽어온 다음, memolist 배열에 MemoData 객체를 추가한다.
        /*
         우리는 UIApplication.shared.delegate 이 코드를 주목해 봐야하는데, 직접 참조가 불가능해서 이렇게 해야한다.*/
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.memolist.append(data)
        
        // 작성폼 화면을 종료하고 이전 화면으로 되돌아간다.
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    // 카메라 버튼 클릭 시 호출되는 메소드
    @IBAction func pick(_ sender: Any) {
        // 이미지 피커 인스턴스를 생성합니다.
        let picker = UIImagePickerController()
    
        picker.delegate = self
        picker.allowsEditing = true
        
        // 이미지 피커 화면을 표시한다.
        self.present(picker, animated: false)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {// 사용자가 이미지를 선택하면 자동으로 이 메소드를 호출함
        
        // 선택된 이미지를 미리보기에 출력한다
        self.preview.image = info[.editedImage] as? UIImage
        
        // 이미지 피커 컨트롤러를 닫는다.
        picker.dismiss(animated: true)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        // 사용자가 텍스트 뷰에 무언가 작성하면 자동으로 호출된다
        // 최대 15자리까지 읽어서 서브젝 변수에 저장한다.
        /*
         옵셔널 문제 때문에 15자리 보다 적으면 문제발생할 수 있어서 이렇게 사용하기.
         */
        let contents = textView.text as NSString
        let length = ( (contents.length > 15 ) ? 15 : contents.length )
        self.subject = contents.substring(with: NSRange(location: 0, length: length))
        
        self.navigationItem.title = self.subject // 네비게이션 타이틀에 표시한다.
    }
}
