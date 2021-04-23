//
//  SideBarVC.swift
//  MyMemory
//
//  Created by Hamlit Jason on 2021/03/21.
//

import UIKit

class SideBarVC: UITableViewController {
    
    let uinfo = UserInfoManager() // 개인정보 관리 매니저
    let nameLabel = UILabel() // 이름 레이블
    let emailLabel = UILabel() // 이메일 레이블
    let profileImage = UIImageView() // 프로필 이미지
    
    let titles = ["새글 작성하기", "친구 새글", "달력으로 보기", "공지사항", "통계", "계정 관리"]
    
    let icons = [
        UIImage(named: "icon01.png"),
        UIImage(named: "icon02.png"),
        UIImage(named: "icon03.png"),
        UIImage(named: "icon04.png"),
        UIImage(named: "icon05.png"),
        UIImage(named: "icon06.png")
    ]
    
    override func viewDidLoad() {
        // 테이블 뷰의 헤더 역할을 할 뷰를 정의한다
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 70))
        headerView.backgroundColor = .brown
        // 테이블 뷰의 헤더 뷰로 지정한다.
        self.tableView.tableHeaderView = headerView
        
        // 이름 레이블의 속성을 정의하고, 헤더 뷰에 추가한다.
        self.nameLabel.frame = CGRect(x: 70, y: 15, width: 100, height: 30)
        //self.nameLabel.text = "lgvv study"
        self.nameLabel.textColor = .white
        self.nameLabel.font = UIFont.boldSystemFont(ofSize: 15)
        self.emailLabel.backgroundColor = .clear
        headerView.addSubview(self.nameLabel)
        
        // 이메일 레이블 속성 정의하고 헤더뷰에 추가
        self.emailLabel.frame = CGRect(x: 70, y: 30, width: 100, height: 30)
        //self.emailLabel.text = "rldd.tistory"
        self.emailLabel.textColor = .white
        self.emailLabel.font = UIFont.boldSystemFont(ofSize: 11)
        self.emailLabel.backgroundColor = .clear
        headerView.addSubview(self.emailLabel)
        
        //let defaultProfile = UIImage(named: "account.jpg")
        //self.profileImage.image = defaultProfile
        self.profileImage.frame = CGRect(x: 10, y: 10, width: 50, height: 50)
        
        view.addSubview(self.profileImage)
        
        self.profileImage.layer.cornerRadius = (self.profileImage.frame.width / 2) // 반원 형태로 라운딩
        self.profileImage.layer.borderWidth = 0 // 테두리 두께 0으로
        self.profileImage.layer.masksToBounds = true // 마스크 효과 - 마스크 기법인데 원을 레이어로 해서 기존에 노출된 부분을 가리고 노출되지 않은 부분을 보이게 하는 기법
        view.addSubview(self.profileImage) // 헤더 뷰에 추가
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) { // 뷰 디드 로드는 한번만이니까 화면이 표시될 때마다 바뀌게 해줌
        self.nameLabel.text = self.uinfo.name ?? "Guset"
        self.emailLabel.text = self.uinfo.account ?? ""
        self.profileImage.image = self.uinfo.profile
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.titles.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // 재사용 큐에서 테이블 셀을 꺼내 온다. 없으면 새로 생성한다.
        let id = "memucell"
        let cell = tableView.dequeueReusableCell(withIdentifier: id) ?? UITableViewCell(style: .default, reuseIdentifier: id)
        
        // 타이틀과 이미지를 대입한다.
        cell.textLabel?.text = self.titles[indexPath.row]
        cell.imageView?.image = self.icons[indexPath.row]
        
        // 폰트 설정
        cell.textLabel?.font = UIFont.systemFont(ofSize: 14)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 { // 선택된 행이 새글 작성 메뉴일 때
            /*
             사이드 바 컨트롤러에서 프론트 컨트롤러를 직접 참조할 방법은 없다.
             revealViewController 메소드는 메인 컨트롤러 객체를 가져오는 메소드
             frontViewController 속성이 바로 프론트 컨트롤러를 가르킨다
             그리고 우리가 원하는 것은 pushViewController 이고 이것은 UINavigationController에만 정의되어 있어서 캐스팅이 필수적이다.
             
             이렇게 화면전환 코드 작성시, 사이드 바 혹은 화면 전체가 전환되는 일 없이 목록 영역에 해당하는 프론트 뷰 컨트롤러 영역만 쓰기 화면으로 전환된다.
             */
            let uv = self.storyboard?.instantiateViewController(identifier: "MemoForm") // 스토리보드를 탐색하여 메모폼의 아이디를 가진 스토리보드를 가져온다.
            let target = self.revealViewController()?.frontViewController as! UINavigationController
            target.pushViewController(uv!, animated: true)
            self.revealViewController()?.revealToggle(self) // 사이드바를 닫아주는 코드
        } else if indexPath.row == 5 { // 선택된 행이 계정관리일 경우
            /*
             이번에는 프레젠트 방식인데 굳이 프론트영역에서 열릴 필요가 없기 때문에.
             .fullScreen으로 준것은 ios13의 업데이트와 관련이 있다. 화면 전환과 관련한 기본 속성값이 바뀌어서
             기본값이 ios13부터는 전체를 덮는게 아닌 부모가 뒤에 남아있기 때문이다
             --> 이렇게 바뀐 디자인을 가르켜 레이어릴 디자인이라고 한다. 애플에 따르면 이 디자인은 사용자로 하여금
             현재 자신이 앱에서 어디에 있는지 인지할 수 있는 컨텍스트를 제공하며, 둥근 상단 모양을 통해 현재의 뷰가 interactively dismmised 될 수 있음을 알게해준다.
             */
            let uv = self.storyboard?.instantiateViewController(identifier: "_Profile")
            uv?.modalPresentationStyle = .fullScreen
            self.present(uv!, animated: true){
                self.revealViewController()?.revealToggle(self) // 이 코드는 모달 형식으로 화면이 바뀌더라도 사이드바는 닫아주어야 하기 때문에
            }
        }
    }
    
}
