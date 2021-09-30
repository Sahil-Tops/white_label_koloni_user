//
//  FAQModels.swift
//  KoloniKube_Swift
//
//  Created by Sam Mehra on 19/07/21.
//  Copyright © 2021 Self. All rights reserved.
//

import Foundation
//import UIKit

class FAQDataModel{
    
    var id: Int?
    var question = ""
    var answer = ""
    
}

extension UIViewController{
    
    func parseFaqData(array: [[String:Any]]) -> [FAQDataModel]{
        var dataArray: [FAQDataModel] = []
        for item in array{
            let faqDatalModel = FAQDataModel()
            faqDatalModel.id = item["id"]as? Int ?? 0
            faqDatalModel.question = item["question"]as? String ?? ""
            faqDatalModel.answer = item["answer"]as? String ?? ""
            dataArray.append(faqDatalModel)
        }
        return dataArray
    }
    
}
