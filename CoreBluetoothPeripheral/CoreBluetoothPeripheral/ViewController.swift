//
//  ViewController.swift
//  CoreBluetoothPeripheral
//
//  Created by 山田一希 on 2017/10/25.
//  Copyright © 2017年 KazukiYamada. All rights reserved.
//

import UIKit
import CoreBluetooth
//ペリフェラル側の実装

class ViewController: UIViewController, CBPeripheralManagerDelegate{
    //ペリフェラルマネージャを宣言する
    var peripheralManager: CBPeripheralManager!
    //サービスの宣言
    var service: CBMutableService!
    //キャラクタ理スティックのUUIDを宣言する
    var characteristicUUID: CBUUID!
    //サービスUUIDを宣言する
    var serviceUUID: CBUUID!
    //キャラクタ理スティック
    var characteristic : CBMutableCharacteristic!

    //サービスの宣言２
    var service2: CBMutableService!

    //サービスUUIDを宣言する
    var serviceUUID2: CBUUID!

    //ペリフェラルマネージャが生成されると、デリゲートのこのオブジェクトが生成される
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        print("state\(peripheral.state)")
    }




    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        //ペリフェラルマネージャのインスタンスを生成する
        //ディスパッチメインキューで自分自信にイベントを受け取る
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)

        //サービス生成
        serviceUUID = CBUUID(string: "DE8BEC5F-DAFF-4115-B610-9949DC9FBBA0")
        //UUIDをサービスに登録する
        service = CBMutableService(type: serviceUUID, primary: true)

        var myData = Data()
        do {
            myData = try Data(contentsOf: URL(string: "https://www.1110city.com/img/mainimage_kawaguchi-pr-movie.jpg")!)
        }catch  {
            print("dataを作成することができませんでした")
            return
        }

        let string1 = "Hello world kawaguchi"

        //サービス生成
        serviceUUID2 = CBUUID(string: "DE8BEC5F-DAFF-4115-B610-9949DC9FBBA1")
        //UUIDをサービスに登録する
        service2 = CBMutableService(type: serviceUUID, primary: true)

        guard let myDataString = string1.data(using: .utf8) else {
            print("myDataStringの生成に失敗しました")
            return
        }

        //キャラクタ理スティックを作成する
        characteristicUUID = CBUUID(string: "0FD755D9-CB39-448D-8B0F-6F201046B7E3")
        characteristic = CBMutableCharacteristic(type: characteristicUUID, properties: CBCharacteristicProperties.read, value: myDataString, permissions: CBAttributePermissions.readable)
        //characteristic.value = Data(base64Encoded: "わい、キャラクタ理スティックやで")

    }

    //サービス追加結果を取得する
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        //エラーが発生した
        if error != nil {
            print("Service Add Failed...")
            return
        }
        //エラーなし
        print("Service Add Success")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //アドバタイズの結果を取得する
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if error != nil {
            print("****Advertising ERROR")
            print("error: \(error)")
            return
        }
        print("Advertising success")
    }

    //セントラルからの読み書きに応答する
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        if request.characteristic.uuid == self.characteristicUUID {
            request.value = Data(base64Encoded: "readable responds リクエストに応答しました")
            peripheralManager.respond(to: request, withResult: CBATTError.success)
        }else {
            print("UUIDが一致しませんでした")
            return
        }

    }


    @IBAction func startAdPeripheralButtonTap(_ sender: Any) {
        //サービスにキャラクタ理スティックを追加
        service.characteristics = [characteristic]

        //ペリフェラルにサービスを追加する
        self.peripheralManager.add(service)
        self.peripheralManager.add(service2)


        let advertisementData = [CBAdvertisementDataServiceUUIDsKey: [serviceUUID, serviceUUID2]]
        peripheralManager.startAdvertising(advertisementData)

    }

    @IBAction func finishAdPeripheralButtonTap(_ sender: Any) {
        peripheralManager.stopAdvertising()
    }
}

