//
//  JoinVC.swift
//  MyMemory
//
//  Created by Hamlit Jason on 2021/04/23.
//

import UIKit
import Alamofire

class JoinVC : UIViewController, UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var profile: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var indicatiorView: UIActivityIndicatorView!
    // 테이블 뷰에 들어갈 텍스트 필드
    var fieldAccount : UITextField! // 계정 필드
    var fieldPassword : UITextField! // 비밀번호 필드
    var fieldName : UITextField! // 이름 필드
    
    var isCalling = false // API 호출 상태값을 관리할 변수
    
    override func viewDidLoad() {
        // 테이블 뷰에 연결
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        // 프로필 이미지를 원형으로 설정
        self.profile.layer.cornerRadius = self.profile.frame.width / 2
        self.profile.layer.masksToBounds = true
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tappedProfile(_:)))
        self.profile.addGestureRecognizer(gesture)
        self.view.bringSubviewToFront(self.indicatiorView) // 인디케이터 뷰를 화면 맨 앞으로 가져오기 - 프로그래밍 방식으로 생성한 객체에 가려 보이지 않을 수도 있기에 화면 로드시 제일 마지막에 배치하면 제일 앞으로 가져와주기
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // 사용자가 이미지를 클릭하였을 때 실행될 델리게이트 메소드
        let rawVal = UIImagePickerController.InfoKey.originalImage.rawValue
        
        if let img = info[UIImagePickerController.InfoKey(rawValue: rawVal)] as? UIImage {
            self.profile.image = img
        }
        
        self.dismiss(animated: true)
    }
    
    
    @objc func tappedProfile(_ sender: Any) {
        // 전반부) 원하는 소스 타입을 선택할 수 있는 액션 시트 구현
        let msg = "프로필 이미지를 읽어올 장소를 선택하세요."
        let sheet = UIAlertController(title: msg, message: nil, preferredStyle: .actionSheet)
      
        sheet.addAction(UIAlertAction(title: "취소", style: .cancel))

        sheet.addAction(UIAlertAction(title: "저장된 앨범", style: .default) { (_) in
            selectLibrary(src: .savedPhotosAlbum) // 저장된 앨범에서 이미지 선택하기
        })
        
        sheet.addAction(UIAlertAction(title: "포토 라이브러리", style: .default) { (_) in
            selectLibrary(src: .photoLibrary) // 포토 라이브러리에서 이미지 선택하기
        })
        
        sheet.addAction(UIAlertAction(title: "카메라", style: .default) { (_) in
            selectLibrary(src: .camera) // 카메라에서 이미지 촬영하기
        })
        
        self.present(sheet, animated: false)
      
        // 후반부) 전달된 소스 타입에 맞게 이미지 피커 창을 여는 내부 함수
        func selectLibrary(src: UIImagePickerController.SourceType) {
            if UIImagePickerController.isSourceTypeAvailable(src) {
                let picker = UIImagePickerController()
                picker.delegate = self
                picker.allowsEditing = true
          
                self.present(picker, animated: false)
            } else {
                self.alert("사용할 수 없는 타입입니다.")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        
        // 각 테이블 뷰 셀 모두에 공통으로 적용될 프레임 객체
        let tfFrame = CGRect(x: 20, y: 0, width: cell.bounds.width - 20, height: 37)
        switch indexPath.row {
            case 0 :
                self.fieldAccount = UITextField(frame: tfFrame)
                self.fieldAccount.placeholder = "계정(이메일)"
                self.fieldAccount.borderStyle = .none
                self.fieldAccount.autocapitalizationType = .none
                self.fieldAccount.font = UIFont.systemFont(ofSize: 14)
                cell.addSubview(self.fieldAccount)
            case 1 :
                self.fieldPassword = UITextField(frame: tfFrame)
                self.fieldPassword.placeholder = "비밀번호"
                self.fieldPassword.borderStyle = .none
                self.fieldPassword.isSecureTextEntry = true
                self.fieldPassword.font = UIFont.systemFont(ofSize: 14)
                cell.addSubview(self.fieldPassword)
            case 2 :
                self.fieldName = UITextField(frame: tfFrame)
                self.fieldName.placeholder = "이름"
                self.fieldName.borderStyle = .none
                self.fieldName.font = UIFont.systemFont(ofSize: 14)
                cell.addSubview(self.fieldName)
            default :
                ()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    
    
    @IBAction func submit(_ sender: Any) {
        if self.isCalling == true { // 이 코드는 중복 실행 방지를 위하여 사용한다.
            // 처음 done을 눌렀을 떄에는 상태값을 true로 변경하도록 하고 이 값이 true인 동안은 다시 버튼을 눌러도 실행되지 않도록 막기
            self.alert("진행중임 잠깐만 기다려줘!")
            return
        } else {
            self.isCalling = true
        }
        
        
        self.indicatiorView.startAnimating() // 인디케이터 뷰 애니메이션 시작
        
        // 전달할 값 준비
        let profile = self.profile.image!.pngData()?.base64EncodedString() // 이미지를 Base64 인코딩 처리
        
        // 전달값을 Parameters 타입의 객체로 정의
        let param : Parameters = [
            "account" : self.fieldAccount.text!,
            "passwd" : self.fieldPassword.text!,
            "name" : self.fieldName.text!,
            "profile_image" : profile!
        ]
        
        // api 호출
        let url = "http://swiftapi.rubypaper.co.kr:2029/userAccount/join"
        let call = AF.request(url, method: HTTPMethod.post, parameters: param, encoding: JSONEncoding.default)
    
        // 서버 응답 완료
        call.responseJSON { res in // JSON 형식이 잘 전달되었는지를 확인
            
            self.indicatiorView.stopAnimating() // 인디케이션 뷰 애니메이션 종료
            
            guard let jsonObject = try! res.result.get() as? [String:Any] else {
                self.isCalling = false // false로 바꾸어 사용자가 다시 등록할 수 있게 해주기
                self.alert("server call error")
                return
            }
        
            let resultCode = jsonObject["result_code"] as! Int
            if resultCode == 0 { // 응답코드가 0 이면 성공
                self.alert("가입이 완료되었습니다.") {
                    self.performSegue(withIdentifier: "backProfileVC", sender: self) // 복귀용 세그웨이를 호출하는 구문을 클로저로 작성
                    // self.alert는 평소에는 생략가능하지만 두 번쨰 매개변수인 completion을 가지고 있다.
                }
            } else { // 0이 아니면 에러
                self.isCalling = false // 계정 가입 실패했어도 isCalling false로 바꿔주기
                let errorMsg = jsonObject["error_msg"] as! String
                self.alert("error : \(errorMsg)")
            }
        }
    }
        
}
