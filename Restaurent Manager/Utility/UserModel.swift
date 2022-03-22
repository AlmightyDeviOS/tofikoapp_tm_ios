
//
//  UserModel.swift
//  Rapt
//
//  Created by Jecky Kukadiya on 28/11/16.
//  Copyright © 2016 Jecky Kukadiya. All rights reserved.
//

import UIKit

class UserModel: NSObject, NSCoding {
    
    var user_id : String?
    var deviceToken : String?
    var name : String?
    var email : String?
    var password : String?
    var country: String?
    var city: String?
    var street: String?
    var building_no: String?
    var province: String?
    var profile_image: String?
    var zip_code: String?
    var latitude: String?
    var longitude: String?
    var website: String?
    var status: String?
    var push_notification: String? //customer,rider
    var email_notification: String? //Facebook,Twitter,Email
    var auth_token: String?
    var store_id: String?
    
    var avg_meal_min: String?
    var avg_meal_hour: String?
    var seating_capacity: String?
    
    var app_language : String?
    var app_version: String?

    static var userModel: UserModel?
    static func sharedInstance() -> UserModel {
        if UserModel.userModel == nil {
            if let data = UserDefaults.standard.value(forKey: "UserModel") as? Data {
                let retrievedObject = NSKeyedUnarchiver.unarchiveObject(with: data)
                if let objUserModel = retrievedObject as? UserModel {
                    UserModel.userModel = objUserModel
                    return objUserModel
                }
            }
            
            if UserModel.userModel == nil {
                UserModel.userModel = UserModel.init()
            }
            return UserModel.userModel!
        }
        return UserModel.userModel!
    }
    
    override init() {
        
    }
    
    
    func synchroniseData(){
        let data : Data = NSKeyedArchiver.archivedData(withRootObject: self)
        UserDefaults.standard.set(data, forKey: "UserModel")
        UserDefaults.standard.synchronize()
    }
    
    func removeData() {
        UserModel.userModel = nil
        UserDefaults.standard.removeObject(forKey: "UserModel")
        UserDefaults.standard.synchronize()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init()
        
        
        
        self.user_id = aDecoder.decodeObject(forKey: "user_id") as? String
        self.deviceToken = aDecoder.decodeObject(forKey: "deviceToken") as? String
        self.name = aDecoder.decodeObject(forKey: "name") as? String
        self.email = aDecoder.decodeObject(forKey: "email") as? String
        self.password = aDecoder.decodeObject(forKey: "password") as? String
        self.country = aDecoder.decodeObject(forKey: "country") as? String
        self.city = aDecoder.decodeObject(forKey: "city") as? String
        self.street = aDecoder.decodeObject(forKey: "street") as? String
        self.building_no = aDecoder.decodeObject(forKey: "building_no") as? String
        self.province = aDecoder.decodeObject(forKey: "province") as? String
        self.profile_image = aDecoder.decodeObject(forKey: "profile_image") as? String
        self.zip_code = aDecoder.decodeObject(forKey: "zip_code") as? String
        self.latitude = aDecoder.decodeObject(forKey: "latitude") as? String
        self.longitude = aDecoder.decodeObject(forKey: "longitude") as? String
        self.website = aDecoder.decodeObject(forKey: "website") as? String
        self.status = aDecoder.decodeObject(forKey: "status") as? String
        self.push_notification = aDecoder.decodeObject(forKey: "push_notification") as? String
        self.email_notification = aDecoder.decodeObject(forKey: "email_notification") as? String
        self.auth_token = aDecoder.decodeObject(forKey: "auth_token") as? String
        self.app_language = aDecoder.decodeObject(forKey: "app_language") as? String
        self.app_version = aDecoder.decodeObject(forKey: "app_version") as? String
        self.store_id = aDecoder.decodeObject(forKey: "store_id") as? String
        
        self.avg_meal_min = aDecoder.decodeObject(forKey: "avg_meal_min") as? String
        self.avg_meal_hour = aDecoder.decodeObject(forKey: "avg_meal_hour") as? String
        self.seating_capacity = aDecoder.decodeObject(forKey: "seating_capacity") as? String
        
    }
    
    func encode(with aCoder: NSCoder) {

        aCoder.encode(self.user_id, forKey: "user_id")
        aCoder.encode(self.deviceToken, forKey: "deviceToken")
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.email, forKey: "email")
        aCoder.encode(self.password, forKey: "password")
        aCoder.encode(self.country, forKey: "country")
        aCoder.encode(self.city, forKey: "city")
        aCoder.encode(self.street, forKey: "street")
        aCoder.encode(self.building_no, forKey: "building_no")
        aCoder.encode(self.province, forKey: "province")
        aCoder.encode(self.profile_image, forKey: "profile_image")
        aCoder.encode(self.zip_code, forKey: "zip_code")
        aCoder.encode(self.latitude, forKey: "latitude")
        aCoder.encode(self.longitude, forKey: "longitude")
        aCoder.encode(self.website, forKey: "website")
        aCoder.encode(self.status, forKey: "status")
        aCoder.encode(self.push_notification, forKey: "push_notification")
        aCoder.encode(self.email_notification, forKey: "email_notification")
        aCoder.encode(self.auth_token, forKey: "auth_token")
        aCoder.encode(self.app_language, forKey: "app_language")
        aCoder.encode(self.app_version, forKey: "app_version")
        aCoder.encode(self.store_id, forKey: "store_id")
        
        aCoder.encode(self.avg_meal_min, forKey: "avg_meal_min")
        aCoder.encode(self.avg_meal_hour, forKey: "avg_meal_hour")
        aCoder.encode(self.seating_capacity, forKey: "seating_capacity")
        
    }
}
