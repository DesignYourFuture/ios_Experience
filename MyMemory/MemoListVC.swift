//
//  MemoListVC.swift
//  MyMemory
//
//  Created by Hamlit Jason on 2021/03/08.
//

import UIKit

class MemoListVC: UITableViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    lazy var dao = MemoDAO()
    
    // 앱 델리게이트 객체의 참조 정보를 읽어온다.
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var lgwCodeParity = 0
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        searchBar.enablesReturnKeyAutomatically = false // 검색 바에 값이 입력되지 않은 상태에서는 검색 버튼도 활성화 되지 않기 때문에 이에 대한 수정이 필요 - 검색 바의 키보드에서 리턴 키가 활성화될 수 있도록 처리
        
        if let revealVC = self.revealViewController() { // SWRevealViewController 라이브러리의 객체를 읽어온다
            
            // bar 버튼 아이템 객체를 정의
            let btn = UIBarButtonItem()
            btn.image = UIImage(named: "sidemenu.png") // 버튼의 이미지
            btn.target = revealVC // 버튼 클릭 시 호출할 메소드가 정의된 객체를 지정
            btn.action = #selector(revealVC.revealToggle(_:)) // 버튼 클릭시 revealToggle(_:) 메소드 호출
            
            self.navigationItem.leftBarButtonItem = btn // 정의된 바 버튼을 내비게이션 바의 왼쪽 아이템으로 등록한다.
            
            self.view.addGestureRecognizer(revealVC.panGestureRecognizer()) // 제스쳐 객체를 뷰에 추가한다.
            
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        // 화면이 나타날 때마다 호출되는 메소드
        self.appDelegate.memolist = self.dao.fetch() // 코어 데이터에 저장된 데이터를 가져온다.
        
        self.tableView.reloadData() // 테이블 데이터를 다시 읽어 들이기. 이에 따라 행을 구성하는 로직이 재실행 될 것임. - 항상 최신 목록을 유지할 수 있다.
        let ud = UserDefaults.standard
        if ud.bool(forKey: UserInfoKey.tutorial) == false && lgwCodeParity == 0 { // 튜토리얼 값이 없다면 튜토리얼 화면 띄워주기
            // 여기서 패리티를 내가 직접 만들어서 초기에 한번만 사용하게끔 했는데 이건 수정 필요
            
            let vc = self.instanceTutorialVC(name: "MasterVC")
            vc?.modalPresentationStyle = .automatic
            self.present(vc!, animated: false, completion: nil)
            
            lgwCodeParity += 1
            
            return
        }
    }
    
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 테이블 행의 개수를 결정하는 메소드
        
        let count = self.appDelegate.memolist.count
        return count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // 테이블 행을 구성하는 메소드
        
        // 1. memolist 배열 데이터에서 주어진 행에 맞는 데이터를 꺼낸다
        let row = self.appDelegate.memolist[indexPath.row]
        // 2. 이미지 속성이 비어 있을 경우 "memoCell", 아니면 "memoCellWithImage"
        let cellID = row.image == nil ? "memoCell" : "memoCellWithImage"
        // 3. 재사용 큐로부터 프로토타입 셀의 인스턴스를 전달받는다.
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID) as? MemoCell
        
        // 4. memoCell의 내용을 구성한다
        cell!.subject?.text = row.title
        cell!.contents?.text = row.contents
        cell!.img?.image = row.image
        
        // 5. Date타입의 날짜를 아래의 포맷에 맞게 변경한다
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        cell!.regdate?.text = formatter.string(from: row.regdate!)
        
        // 객체를 리턴한다
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 테이블 특정 행이 선택되었을 때 호출되는 메소드. 선택된 행의 정보는 indexPath에 담겨 전달된다.
        
        // 메모리스트 배열에서 선택된 행에 있는 데이터 가져오고
        let row = self.appDelegate.memolist[indexPath.row]
        
        // 상세 화면의 인스턴스를 생성
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "MemoRead") as? MemoReadVC else {
            // 같은 아이디가 없다면 바로 종료하게끔
            return
        }
        
        // 값을 전달한 다음, 상세 화면을 이동
        vc.param = row
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let data = self.appDelegate.memolist[indexPath.row]
        
        // 코어 데이터에서 삭제한 다음, 배열 내 데이터 및 테이블 뷰 행을 차례로 삭제한다.
        if dao.delete(data.objectID!) {
            self.appDelegate.memolist.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func searchBarSearchButtonClicked(_ senderBar: UISearchBar) {
        let keyword = searchBar.text // 검색 바에 입력된 키워드를 가져온다
        
        // 키워드를 적용하여 데이터를 검색하고, 테이블 뷰를 갱신한다.
        self.appDelegate.memolist = self.dao.fetch(keyword: keyword)
        self.tableView.reloadData()
    }

}
