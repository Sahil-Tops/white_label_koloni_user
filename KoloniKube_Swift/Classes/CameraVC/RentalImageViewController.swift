//
//  RentalImageViewController.swift
//  KoloniKube_Swift
//
//  Created by Tops on 27/06/19.
//  Copyright © 2019 Self. All rights reserved.
//

import UIKit
import AVKit


class RentalImageViewController: UIViewController {
    
    @IBOutlet weak var camView: UIView!
    @IBOutlet weak var btnCam: UIButton!
    @IBOutlet weak var cantTakeImage: UIButton!
    @IBOutlet weak var close_btn: UIButton!
    @IBOutlet weak var title_lbl: UILabel!
    
    
    let cameraController = CameraController()
    var bookNowVC : BookNowVC!
    var lastVc = UIViewController()
    var cameraType = ""     //hub - For hub image, bike - For bike image
    
    
    //MARK: - Default Function's
    override func viewDidLoad(){
        super.viewDidLoad()
        self.btnCam.isHidden = true
        self.camView.isHidden = true
        DispatchQueue.main.async {
            self.setupView()
        }
        // Do any additional setup after loading the view.
    }
    
    //MARK: - @IBAction's
    @IBAction func tapCantTakeImage(_ sender: Any){
        self.bookNowVC.rentalImage = nil
        self.bookNowVC.isCamBroken = true
        self.dismiss(animated: true) {
            self.bookNowVC.uploadImgForFinishRide()
        }
    }
    @IBAction func captureTapped(_ sender: Any){
        
        cameraController.captureImage {(image, error) in
            guard let image = image else {
                print(error ?? "Image capture error")
                return
            }
            print("Image Size", image.size)
            self.bookNowVC.rentalImage = image
            self.bookNowVC.isCamBroken = false
            self.dismiss(animated: true) {
                self.bookNowVC.uploadImgForFinishRide()
            }
        }
    }
    
    @IBAction func tapCloseBtn(_ sender: Any){
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Custom Funtion's
    func setupView(){
        
        self.btnCam.isHidden = false
        self.camView.isHidden = false
        self.configureCameraController()
        if self.cameraType == "hub"{
            self.title_lbl.text = "Take photo showing that you're at hub"
            self.close_btn.isHidden = false
//            self.cantTakeImage.isHidden = true
        }else{
            self.title_lbl.text = "Please capture image"
            self.close_btn.isHidden = true
//            self.cantTakeImage.isHidden = false
        }
        
    }
    
    func configureCameraController() {
        cameraController.prepare {(error) in
            if let error = error {
                print(error)
            }
            try? self.cameraController.displayPreview(on: self.view)
        }
    }
    
    
}



