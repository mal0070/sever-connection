//
//  ViewController.swift
//  CurrentTime
//
//  Created by 이민아 on 2022/11/25.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var timeCheckButton: UIButton!
    
    @IBOutlet weak var userIdTextField: UITextField!
    @IBOutlet weak var responseView: UITextView!
    @IBOutlet weak var nameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


    @IBAction func callCurrentTime(_ sender: Any) {
        do {
            // 1. URL 설정, GET 방식으로 API 호출
            let url = URL(string: "http://swiftapi.rubypaper.co.kr:2029/practice/currentTime") //URL 객체를 만듬
            let response = try String(contentsOf: url!) //api 읽어옴 -> 문자열로 반환
            
            // 2. 읽어온 값을 레이블에 표시
            self.currentTimeLabel.text = response
            self.currentTimeLabel.sizeToFit()
        }
        catch let e as NSError {
            print(e.localizedDescription)
        }
    }
    
    
    @IBAction func post(_ sender: Any) {
        // 1. 전송할 값 준비
        let userId = (self.userIdTextField.text)
        let name = (self.nameTextField.text)
        let param = "userId=\(userId)&name=\(name)" //key1=value1&ke2=value2
        let paramData = param.data(using: .utf8) //URL 인코딩
        
        // 2. URL 객체 정의
        let url = URL(string: "http://swiftapi.rubypaper.co.kr:2029/practice/echo")
        
        //3. URLRequest 객체를 정의하고, 요청 내용을 담는다.
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.httpBody = paramData
        
        //4. HTTP 메세지 헤더 설정
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue(String(paramData!.count), forHTTPHeaderField: "Content-Length")
        
        //5. URLSession 객체를 통해 전송 및 응답 값 처리 로직 작성
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            // 5-1. 서버가 응답이 없거나 통신이 실패했을 때
            if let e = error {
                NSLog("An error has occured : \(e.localizedDescription)")
                return
            }
            // 5-2. 응답 처리 로직
                // 1) 메인스레드 - 비동기로 처리되도록 -> 비동기 구문은 모두 서브스레드에서 실행(자동)되는데, 이 구문은 UI와 관련되어있기 때문에 메인 스레드에서 실행되어야한다.
            DispatchQueue.main.async() {
                do {
                    let object = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary
                    
                    guard let jsonObject = object else { return }
                    
                // 2)JSON 결과값을 추출한다.
                    let result = jsonObject["result"] as? String
                    let timestamp = jsonObject ["timestamp"] as? String
                    let userId = jsonObject["userId"] as? String
                    let name = jsonObject["name"] as? String
                    
                //3) 결과가 성공일 때만 텍스트뷰에 출력
                    if result == "SUCCESS"{
                        self.responseView.text = "아이디: \(userId!)"+"\n"+"이름: \(name!)"+"\n"+"응답결과: \(result!)"+"\n"+"요청방식: x-www-form-urlencoded"
                    }
                } catch let e as NSError {
                    print("An error has occurred while parsing JSONObject: \(e.localizedDescription)")
                }
            }
        }
        // 6. POST 전송
        task.resume()
    }
    
}


//Synchronous URL loading of https://swiftapi.rubypaper.co.kr:2029/practice/currentTime should not occur on this application's main thread as it may lead to UI unresponsiveness. Please switch to an asynchronous networking API such as URLSession.

