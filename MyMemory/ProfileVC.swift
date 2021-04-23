//
//  ProfileVC.swift
//  MyMemory
//
//  Created by prologue on 2017. 6. 9..
//  Copyright © 2017년 rubypaper. All rights reserved.
//

import UIKit
class ProfileVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    /*
        테이블 뷰는 사용하지만 테이블 뷰 컨트롤러는 아니다.
        따라서 테이블 뷰를 위한 프로토콜을 직접 추가해줘야한다.
        UITableViewDelegate는 테이블 뷰에서 발생하는 사용자 액션에 응답하기 위한 프로토콜이며
        UITableViewDataSource는 테이터 소스를 이용하여 테이블 뷰를 구성하기 위해 필요한 프로토콜이다.
        또한 필수 구현 메소드가 포함되어 있기 때문에 이를 구현하지 않으면 컴파일러의 오류가 발생한다.
        */
    
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    let uinfo = UserInfoManager() // 개인정보 관리 매니저
    let profileImage = UIImageView() // 프로필 사진 이미지
    let tv = UITableView() // 프로필 목록
    var isCalling = false
  
    override func viewDidLoad() {
        self.navigationItem.title = "프로필"
    
    // 뒤로 가기 버튼 처리
        let backBtn = UIBarButtonItem(title: "닫기", style: .plain, target: self, action: #selector( close(_:) ))
        self.navigationItem.leftBarButtonItem = backBtn
    
    // 추가되는 부분) 배경 이미지 설정
        let bg = UIImage(named: "profile-bg")
        let bgImg = UIImageView(image: bg)
        bgImg.frame.size = CGSize(width: bgImg.frame.size.width, height: bgImg.frame.size.height)
        bgImg.center = CGPoint(x: self.view.frame.width / 2, y: 40)
        bgImg.layer.cornerRadius = bgImg.frame.size.width / 2
        bgImg.layer.borderWidth = 0
        bgImg.layer.masksToBounds = true
    
        self.view.addSubview(bgImg)
    
        self.view.bringSubviewToFront(self.tv)
        self.view.bringSubviewToFront(self.profileImage)
    
        // 1 프로필 사진에 들어갈 기본 이미지
        //let image = UIImage(named: "account.jpg")
        let image = self.uinfo.profile
    
        // 2 프로필 이미지 처리
        self.profileImage.image = image
        self.profileImage.frame.size = CGSize(width: 100, height: 100)
        self.profileImage.center = CGPoint(x: self.view.frame.width / 2, y: 270)
    
        // 3 프로필 이미지 둥글게 만들기
        self.profileImage.layer.cornerRadius = self.profileImage.frame.width / 2
        self.profileImage.layer.borderWidth = 0
        self.profileImage.layer.masksToBounds = true
    
        // 4 루트 뷰에 추가
        self.view.addSubview(self.profileImage)
    
        // 테이블 뷰
        self.tv.frame = CGRect(x: 0,
                           y: self.profileImage.frame.origin.y + self.profileImage.frame.size.height + 20,
                           width: self.view.frame.width,
                           height: 100)
        self.tv.dataSource = self
        self.tv.delegate = self
        self.view.addSubview(self.tv)
    
        // 내비게이션 바 숨김 처리
        self.navigationController?.navigationBar.isHidden = true
    
        self.drawBtn()
    
    
        // 프로필 이미지 뷰 객체에 탭 제스처를 등록하고 이를 profile(_:)과 연결합니다.
        let tap = UITapGestureRecognizer(target: self, action: #selector(profile(_:)))
        self.profileImage.addGestureRecognizer(tap)
        self.profileImage.isUserInteractionEnabled = true
    }
  
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
  
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
    
        cell.textLabel?.font = UIFont.systemFont(ofSize: 14)
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 13)
        cell.accessoryType = .disclosureIndicator
    
    switch indexPath.row {
        case 0 :
            cell.textLabel?.text = "이름"
            //cell.detailTextLabel?.text = "lgvv9898"
            cell.detailTextLabel?.text = self.uinfo.name ?? "Login Please"
        case 1 :
            cell.textLabel?.text = "계정"
            //cell.detailTextLabel?.text = "lgvv9898.tistory"
            cell.detailTextLabel?.text = self.uinfo.account ?? "Login Please"
        default :
            ()
        }
        return cell
    }
  
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.uinfo.isLogin == false { // 로그인이 되어 있지 않다면 창의 띄워준다.
            self.doLogin(self.tv)
        }
    }
    
    @objc func close(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true)
    }
    
    @objc func doLogin(_ sender : Any){
        if self.isCalling == true {
            self.alert("waiting for response...")
            return
        } else {
            self.isCalling = true
        }
        let loginAlert = UIAlertController(title: "LOGIN", message: nil, preferredStyle: .alert)
        
        loginAlert.addTextField { (tf) in
            tf.placeholder = "Your Account"
        }
        
        loginAlert.addTextField { (tf) in
            tf.placeholder = "Password"
            tf.isSecureTextEntry = true
        }
        
        loginAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel){
            (_) in
            self.isCalling = false
        })
        loginAlert.addAction(UIAlertAction(title: "Login", style: .destructive, handler: { (_) in
            self.indicatorView.startAnimating() // 인디케이터 실행
            let account = loginAlert.textFields?[0].text ?? "" // 문법 중 하나인데 트루면 앞에 거짓이면 뒤에
            let passwd = loginAlert.textFields?[1].text ?? ""
            /* 동기식 코드
            if self.uinfo.login(account: account, passwd: passwd success :){
                self.tv.reloadData() // 테이블 뷰를 갱신한다
                self.profileImage.image = self.uinfo.profile // 이미지 프로필을 갱신한다.
                self.drawBtn() // 로그인 상태에 따라 적절히 로그인/로그아웃 버튼을 출력한다.
            } else {
                let msg = "로그인에 실패함"
                let alert = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
            
            }*/
            
            // 비동기식 코드로 바꿈
            self.uinfo.login(account: account, passwd: passwd, success: {
                self.indicatorView.stopAnimating() // 인디케이터 종료
                self.isCalling = false
                // UI갱신
                self.tv.reloadData()
                self.profileImage.image = self.uinfo.profile
                self.drawBtn()
            }, fail: { msg in
                self.indicatorView.stopAnimating() // 인디케이터 종료
                self.isCalling = false
                self.alert(msg)
            })
        }))
        
        self.present(loginAlert, animated: false, completion: nil)
        
    }
    
    @objc func doLogout(_ sender : Any) {
        let msg = "로그아웃 하시겠습니까?"
        let alert = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel){
            (_) in
            self.isCalling = false
        })
        
        alert.addAction(UIAlertAction(title: "확인", style: .destructive, handler: { (_) in
            if self.uinfo.logout() {
                self.tv.reloadData() // 테이블 뷰를 갱신한다
                self.profileImage.image = self.uinfo.profile // 이미지 프로필을 갱신한다.
                self.drawBtn() // 로그인 상태에 따라 적절히 로그인/로그아웃 버튼을 출력한다.
            }
        }))
        
        self.present(alert, animated: false, completion: nil)
    }
    
    func drawBtn() {
        // 버튼을 감쌀 뷰를 정의한다.
        let v = UIView()
        v.frame.size.width = self.view.frame.width
        v.frame.size.height = 40
        v.frame.origin.x = 0
        v.frame.origin.y = self.tv.frame.origin.y + self.tv.frame.height
        v.backgroundColor = UIColor(red:0.98, green:0.98, blue:0.98, alpha:1.0)
        
        self.view.addSubview(v)
        
        // 버튼을 정의한다.
        let btn = UIButton(type: .system)
        btn.frame.size.width = 100
        btn.frame.size.height = 30
        btn.center.x = v.frame.size.width / 2
        btn.center.y = v.frame.size.height / 2
        
        // 로그인 상태일 때는 로그아웃 버튼을, 로그아웃 상태일 때에는 로그인 버튼을 만들어 준다.
        if self.uinfo.isLogin == true {
          btn.setTitle("로그아웃", for: .normal)
          btn.addTarget(self, action: #selector(doLogout(_:)), for: .touchUpInside)
        } else {
          btn.setTitle("로그인", for: .normal)
          btn.addTarget(self, action: #selector(doLogin(_:)), for: .touchUpInside)
        }
        v.addSubview(btn)
    }
    
    func imgPicker( _ source : UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.sourceType = source
        picker.delegate = self
        picker.allowsEditing = true
        self.present(picker, animated: true, completion: nil)
    }
    
    @objc func profile(_ sender : UIButton) { // 프ㅗ필 사진의 소스 타입을 선택하는 메소드
        guard self.uinfo.account != nil else { // 로그인이 되어 있지 않은 경우는 프로필 이미지 등록을 막고 대신 로그인 창을 띄워준다.
            self.doLogin(self)
            return
        }
        
        let alert = UIAlertController(title: nil, message: "사진을 가져올 곳을 선택해 주세요", preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "camera", style: .default){ (_) in
                self.imgPicker(.camera)
            })
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            alert.addAction(UIAlertAction(title: "saved albums", style: .default){ (_) in
                self.imgPicker(.savedPhotosAlbum)
            })
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            alert.addAction(UIAlertAction(title: "photo library", style: .default){ (_) in
                self.imgPicker(.photoLibrary)
            })
        }
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
            
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let img = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.uinfo.profile = img
            self.profileImage.image = img
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func backProfileVC(_ segue : UIStoryboardSegue) { // unwind 세그웨이 프로그래밍적으로 구현 - 왜냐하면 바로 이전화면이 아니라 더더 이전화면을 건너가야하는 경우도 생기니까.
        // 단지 프로필 화면으로 되돌아오기 위한 표식 역할만 할 뿐이므로 아무 내용도 작성하지 않는다.
        
    }
    
    
}
