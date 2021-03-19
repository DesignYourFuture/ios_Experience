//
//  MemoReadVC.swift
//  MyMemory
//
//  Created by Hamlit Jason on 2021/03/08.
//

import UIKit

class MemoReadVC: UIViewController {

    var param: MemoData? // 콘텐츠 데이터를 저장하는 변수
    
    @IBOutlet var subject: UILabel!
    @IBOutlet var contents: UILabel!
    @IBOutlet var img: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 제목과 내용, 이미지를 출력
        self.subject.text = param?.title
        self.contents.text = param?.contents
        self.img.image = param?.image
        
        // 날짜 포맷 변환
        let formatter = DateFormatter()
        formatter.dateFormat = "dd일 HH:mm분에 작성됨" // 이런식으로 형식을 넣어 출력 가능
        let dateString = formatter.string(from: (param?.regdate)!)
        
        // 네이게이션 타이틀에 날짜를 표시
        self.navigationItem.title = dateString
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
