//
//  ViewController.swift
//  oke
//
//  Created by Student on 2017/07/12.
//  Copyright © 2017年 Student. All rights reserved.
//

import UIKit
import CoreLocation
import AFNetworking

protocol KazeDelegate:class
{
    func kazeGetSpeed(speed:Double,latt:Double,lonn:Double,name:String)
}

class Kaze {
    let API_KEY = "0418ece30149fb931b11919e72cce28e"
    weak var delegate:KazeDelegate?
    
    func json(lat:Double, lon:Double)
    {
        let url = "http://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=\(self.API_KEY)"
        let manager = AFHTTPSessionManager()
        manager.get(url, parameters: nil,
        success: {(operation,json) in
            
        let dict = json as! [String: AnyObject]
            let name = dict["name"] as AnyObject
        let coord = dict["coord"] as AnyObject
        let latt = coord["lat"] as AnyObject
        let lonn = coord["lon"] as AnyObject
        let wind = dict["wind"] as AnyObject
        let speed = wind["speed"] as AnyObject
            
            
            self.delegate?.kazeGetSpeed(speed: speed as! Double, latt: latt as! Double,lonn: lonn as! Double,name: name as! String)
        },
        failure: {(operation, error) in
        print("Error: \(error)")
        })
    }
}

class ViewController: UIViewController, KazeDelegate
{
    var score:Double = 0
    var locationManager: CLLocationManager!
    
    @IBOutlet weak var JLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet var OkeSpace: [UIImageView]!
    override func viewDidLoad() {

        
        // Do any additional setup after loading the view, typically from a nib.
        locationManager = CLLocationManager() // インスタンスの生成
        locationManager.delegate = self // CLLocationManagerDelegateプロトコルを実装するクラスを指定する
        locationManager.distanceFilter = kCLDistanceFilterNone
        self.score += UserDefaults.standard.double(forKey: "score")
        

        

    }
       override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func kazeGetSpeed(speed: Double,latt:Double,lonn:Double,name:String)
    {
        self.score += speed
        UserDefaults.standard.set(self.score,forKey:"score")
        let scoretext:String = String(format:"%.0f",self.score)
        scoreLabel.text = "在庫:\(scoretext)\n毎秒:\(speed)"
        print(latt)
        print(lonn)
        JLabel.text = name
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            print("ユーザーはこのアプリケーションに関してまだ選択を行っていません")
            // 許可を求めるコードを記述する（後述）
            locationManager.requestWhenInUseAuthorization() // 起動中のみの取得許可を求める
            break
        case .denied:
            print("ローケーションサービスの設定が「無効」になっています (ユーザーによって、明示的に拒否されています）")
            // 「設定 > プライバシー > 位置情報サービス で、位置情報サービスの利用を許可して下さい」を表示する
            break
        case .restricted:
            print("このアプリケーションは位置情報サービスを使用できません(ユーザによって拒否されたわけではありません)")
            // 「このアプリは、位置情報を取得できないために、正常に動作できません」を表示する
            break
        case .authorizedAlways:
            print("常時、位置情報の取得が許可されています。")
            // 位置情報取得の開始処理
            locationManager.startUpdatingLocation()
            break
        case .authorizedWhenInUse:
            print("起動時のみ、位置情報の取得が許可されています。")
            // 位置情報取得の開始処理
            locationManager.startUpdatingLocation()
            break
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        for location in locations {
           let lat = location.coordinate.latitude
           let lon = location.coordinate.longitude
            let kaze = Kaze()
            kaze.delegate = self
            kaze.json(lat: lat, lon: lon)
        }
        
        
    }
    

}
