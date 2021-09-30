//
//  ImagePicker.swift
//  CougarX
//
//  Created by Sahil Mehra on 13/03/20.
//  Copyright © 2018 Tops. All rights reserved.
//

import Foundation
import UIKit

protocol ImagePickerPresentable: class {
    
    func showImagePicker()
    func selectedImage(data: Data?,image: UIImage?)
}

fileprivate class ImagePickerHelper: NSObject {
    
    weak var delegate: ImagePickerPresentable?
    
    fileprivate struct `Static` {
        fileprivate static var instance: ImagePickerHelper?
    }
    
    fileprivate class var shared: ImagePickerHelper {
        if ImagePickerHelper.Static.instance == nil {
            ImagePickerHelper.Static.instance = ImagePickerHelper()
        }
        return ImagePickerHelper.Static.instance!
    }
    
    fileprivate func dispose() {
        ImagePickerHelper.Static.instance = nil
    }
    
    func picker(picker: UIImagePickerController, selectedImageData data: Data?,selectedImage image: UIImage?) {
        picker.dismiss(animated: true, completion: nil)
        
        self.delegate?.selectedImage(data: data, image: image)
        self.delegate = nil
        self.dispose()
    }
}

extension ImagePickerPresentable where Self: UIViewController {
    
    fileprivate func pickerControllerActionFor(for type: UIImagePickerController.SourceType, title: String) -> UIAlertAction? {
        guard UIImagePickerController.isSourceTypeAvailable(type) else {
            return nil
        }
        return UIAlertAction(title: title, style: .default) { [unowned self] _ in
            let pickerController           = UIImagePickerController()
            pickerController.delegate      = ImagePickerHelper.shared
            pickerController.sourceType    = type
            //pickerController.allowsEditing = true
            self.present(pickerController, animated: true)
        }
    }
    
    func showImagePicker() {
        ImagePickerHelper.shared.delegate = self
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if let action = self.pickerControllerActionFor(for: .camera, title: "Take photo") {
            optionMenu.addAction(action)
        }
        if let action = self.pickerControllerActionFor(for: .photoLibrary, title: "Select from gallary") {
            optionMenu.addAction(action)
        }
        optionMenu.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(optionMenu, animated: true)
    }
    
    func openGallary(){
        
        ImagePickerHelper.shared.delegate = self
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if let action = self.pickerControllerActionFor(for: .photoLibrary, title: "Select from gallary"){
            alert.addAction(action)
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension ImagePickerHelper: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.picker(picker: picker, selectedImageData: nil, selectedImage: UIImage(named: "profileFill"))
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage]as? UIImage else {
            return self.picker(picker: picker, selectedImageData: nil, selectedImage: nil)
        }
        
        self.picker(picker: picker, selectedImageData: selectedImage.fixOrientation().jpegData(compressionQuality: 0.5), selectedImage: selectedImage)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        self.picker(picker: picker, selectedImageData: image.fixOrientation().jpegData(compressionQuality: 0.5), selectedImage: image)
    }
}
