//
//  HelpTipsViewController.swift
//  KoloniKube_Swift
//
//  Created by Sahil Mehra on 11/6/20.
//  Copyright © 2020 Self. All rights reserved.
//

import UIKit

class HelpTipsViewController: UIViewController {
    
//    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var title_lbl: UILabel!
    @IBOutlet weak var close_btn: UIButton!
    @IBOutlet weak var underLine1_lbl: UILabel!
    @IBOutlet weak var underLine2_lbl: UILabel!
    @IBOutlet weak var havingTroubleText_textView: UITextView!
    @IBOutlet weak var one_lbl: UILabel!
    @IBOutlet weak var two_lbl: UILabel!
    @IBOutlet weak var third_lbl: UILabel!
    @IBOutlet weak var htmlTextView: UITextView!
    
    var bookNowVc: BookNowVC?
    
    //MARK: - Default Function's
    override func viewDidLoad() {
        super.viewDidLoad()
        self.welcomePopUp_Web()
    }
    
    override func viewDidLayoutSubviews() {
        self.loadContent()
        self.loadUI()
    }
    
    //MARK:- @IBAction's
    @IBAction func tapCloseBtn(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK:- Custom Function's
    
    func loadUI(){
        self.title_lbl.textColor = CustomColor.primaryColor
        self.underLine1_lbl.backgroundColor = CustomColor.primaryColor
        self.underLine2_lbl.backgroundColor = CustomColor.primaryColor
    }
    
    func loadContent(){
        self.one_lbl.circleObject()
        self.two_lbl.circleObject()
        self.third_lbl.circleObject()
        
        let string = "Having trouble? You can check out the FAQ or report an issue."
        let rangOfFaq = (string as NSString).range(of: "FAQ")
        let rangOfReportIssue = (string as NSString).range(of: "report an issue.")
        let attributedString = NSMutableAttributedString.init(string: string)
        attributedString.addAttributes([NSAttributedString.Key.foregroundColor: CustomColor.primaryColor, NSAttributedString.Key.link: URL(string: "http://www.faq.com")!, NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue], range: rangOfFaq)
        attributedString.addAttributes([NSAttributedString.Key.foregroundColor: CustomColor.primaryColor, NSAttributedString.Key.link: URL(string: "http://www.report_issue.com")!, NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue], range: rangOfReportIssue)
        self.havingTroubleText_textView.attributedText = attributedString
        self.havingTroubleText_textView.linkTextAttributes = [NSAttributedString.Key.foregroundColor: CustomColor.primaryColor]
        self.havingTroubleText_textView.font = UIFont.init(name: "Avenir Next", size: 15.0)
        self.havingTroubleText_textView.delegate = self
        self.havingTroubleText_textView.isEditable = false
    }
    
    func welcomePopUp_Web(){

        let params: NSMutableDictionary = NSMutableDictionary()
        params.setValue("", forKey: "partner_id_white_label")
        params.setValue("\(appDelegate.getCurrentAppVersion)", forKey: "ios_version")
        
        APICall.shared.postWeb("popups", parameters: params, showLoder: true) { (response) in
            if let status = response["FLAG"]as? Int, status == 1{
                if let textStr = response["POPUP_TEXT"]as? String{
                    self.htmlTextView.text = textStr.html2String
                }
            }
        } failure: { (error) in
            self.showTopPop(message: error as? String ?? "", response: false)
        }

    }
    
}

//MARK: - Text View Delegate's
extension HelpTipsViewController: UITextViewDelegate{
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        
        print(URL.absoluteString)
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
            if URL.absoluteString == "http://www.faq.com"{
                let faqVc = FAQViewController(nibName: "FAQViewController", bundle: nil)
                self.bookNowVc?.sideMenuViewController?.setContentViewController(UINavigationController(rootViewController: faqVc), animated: true)
            }else if URL.absoluteString == "http://www.report_issue.com"{
                self.bookNowVc?.showReportAnIssue()
            }
        }
        return false
    }
    
}
