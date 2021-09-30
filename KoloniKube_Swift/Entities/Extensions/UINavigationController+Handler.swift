//
//  UINavigationController+Handler.swift
//  Booking_system
//
//  Created by Tops on 8/2/16.
//  Copyright © 2016 Tops. All rights reserved.
//

import UIKit

extension UINavigationController {
    func popViewControllerWithHandler(_ completion: @escaping ()->()) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        self.popViewController(animated: true)
        CATransaction.commit()
    }
    
    func popToRootViewControllerWithHandler(_ completion: @escaping ()->()) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        self.popToRootViewController(animated: true)
        CATransaction.commit()
    }
    
    func pushViewController(_ viewController: UIViewController, completion: @escaping ()->()) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        self.pushViewController(viewController, animated: true)
        CATransaction.commit()
    }
    
    func popToViewController(_ viewController:UIViewController, completion:@escaping ()->()) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        self.popToViewController(viewController, animated: false)
        CATransaction.commit()
    }
}
