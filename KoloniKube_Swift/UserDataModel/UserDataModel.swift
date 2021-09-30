//
//  UserDataModel.swift
//  KoloniKube_Swift
//
//  Created by Sam Mehra on 30/06/21.
//  Copyright © 2021 Self. All rights reserved.
//

import Foundation

class UserDataModel: NSObject{
    
    static var sharedInstance: UserDataModel?
    var dictionary: [String:Any] = [:]
    
    init(dict: [String:Any]) {
        super.init()
        self.dictionary = dict
        type(of: self).sharedInstance = self
    }
    
    var userId: String{
        return self.dictionary["id"]as? String ?? ""
    }
    
    var apple_id: String{
        return self.dictionary["apple_id"]as? String ?? ""
    }
    
    var affiliate_id: String{
        return self.dictionary["affiliate_id"]as? String ?? "0"
    }
    
    var affiliate_status: String{
        return self.dictionary["affiliate_status"]as? String ?? "0"
    }
    
    var bt_customer_id: String{
        return self.dictionary["bt_customer_id"]as? String ?? "0"
    }
    
    var date_of_birth: String{
        return self.dictionary["date_of_birth"]as? String ?? ""
    }
    
    var email_id: String{
        return self.dictionary["email_id"]as? String ?? ""
    }
    
    var expiry_date: String{
        return self.dictionary["expiry_date"]as? String ?? ""
    }
    
    var first_name: String{
        return self.dictionary["first_name"]as? String ?? ""
    }
    
    var gender: String{
        return self.dictionary["gender"]as? String ?? "0"
    }
        
    var google_id: String{
        return self.dictionary["google_id"]as? String ?? ""
    }
    
    var is_affiliated_user: String{
        return self.dictionary["is_affiliated_user"]as? String ?? "0"
    }
    
    var is_eighteen_plus: String{
        return self.dictionary["is_eighteen_plus"]as? String ?? "0"
    }
    
    var is_email_verified: String{
        return self.dictionary["is_email_verified"]as? String ?? "0"
    }
    
    var is_mobile_verified: String{
        return self.dictionary["is_mobile_verified"]as? String ?? "0"
    }
    
    var is_profile_incompleted: String{
        return self.dictionary["is_profile_incompleted"]as? String ?? "0"
    }
    
    var is_social: String{
        return self.dictionary["is_social"]as? String ?? "0"
    }
    
    var is_social_email_verified: String{
        return self.dictionary["is_social_email_verified"]as? String ?? "0"
    }
    
    var is_verify: String{
        return self.dictionary["is_verify"]as? String ?? "0"
    }
    
    var last_name: String{
        return self.dictionary["last_name"]as? String ?? ""
    }
    
    var latitude: String{
        return self.dictionary["latitude"]as? String ?? ""
    }
    
    var longitude: String{
        return self.dictionary["longitude"]as? String ?? ""
    }
    
    var mobile_number: String{
        return self.dictionary["mobile_number"]as? String ?? ""
    }
    
    var profile_image: String{
        return self.dictionary["profile_image"]as? String ?? ""
    }
    
    var status: String{
        return self.dictionary["status"]as? String ?? "0"
    }
    
    var twitter_id: String{
        return self.dictionary["twitter_id"]as? String ?? ""
    }
    
    var username: String{
        return self.dictionary["username"]as? String ?? ""
    }
    
    var primary_account: String{
        return self.dictionary["primary_login"]as? String ?? "0"
    }
    
    var totalNumberOfRides: Int{
        return Singleton.userProfileData.object(forKey: "RIDES")as? Int ?? 0
    }
    
}
