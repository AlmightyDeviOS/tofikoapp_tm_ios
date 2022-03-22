//
//  LoginVC.swift
//  Restaurent Manager
//
//  Created by APPLE on 18/09/19.
//  Copyright © 2019 com.Coder2. All rights reserved.
//

import UIKit

class LoginVC: Main {

    //MARK:- Outlets
    @IBOutlet weak var tfEmailAddress: CustomTextField!
    @IBOutlet weak var tfPassword: CustomTextField!
    @IBOutlet weak var btnLogin: CustomButton!
    @IBOutlet weak var btnForgotPass: UIButton!
    
    @IBOutlet weak var btnBottom: UIButton!
    

    //MARK:- Global Variables
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tfEmailAddress.placeholder = Language.EMAIL_ADDRESS
        tfPassword.placeholder = Language.PASSWORD
        btnLogin.setTitle(Language.LOGIN, for: .normal)
        
        btnForgotPass.setAttributedTitle(NSMutableAttributedString(string: Language.FORGOT_PASSWORD, attributes: [.font: UIFont(name: "Raleway-Regular", size: 15.0) as Any, .foregroundColor: UIColor.white, .underlineStyle: NSUnderlineStyle.styleSingle.rawValue]), for: .normal)
        
        self.btnBottom.setTitle(Language.REGISTER_FLOW, for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if UserModel.sharedInstance().app_version != nil && UserModel.sharedInstance().app_version != "" {
            let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
            if Double(UserModel.sharedInstance().app_version!)! > Double(appVersion)!{
                launchAppUpdatePopup()
            }
        }
    }
    
    //MARK:- Button Actions
    @IBAction func btnLogin_Action(_ sender: Any) {
        if checkValidation() {
            callLoginAPI()
        }
    }
    
    @IBAction func btnForgot_Action(_ sender: Any) {
        self.performSegue(withIdentifier: "toForgot", sender: nil)
    }
    
    @IBAction func btnRegister_Action(_ sender: Any) {
        self.performSegue(withIdentifier: "toRegister", sender: nil)
    }
    
    //MARK:- Other Functions
    func checkValidation()->Bool{
        if tfEmailAddress.text == ""{
            tfEmailAddress.becomeFirstResponder()
            self.showError(Language.VAILD_EMAIL)
            return false
        }else if tfPassword.text == ""{
            tfPassword.becomeFirstResponder()
            self.showError(Language.PROVIDE_PASS)
            return false
        }else if !(tfEmailAddress.text?.isEmail)! {
            tfEmailAddress.becomeFirstResponder()
            self.showError(Language.PROVIDE_EMAIL)
            return false
        }else{
            return true
        }
    }
    
    //MARK:- Webservices
    func callLoginAPI() {
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }
        
        let serviceURL = Constant.WEBURL + Constant.API.LOGIN
        var params = ""
        
        if let token = UserModel.sharedInstance().deviceToken{
            params = "?email=\(tfEmailAddress.text!)&password=\(tfPassword.text!)&device_token=\(token)&lang_id=\(UserModel.sharedInstance().app_language!)"
        }else{
            params = "?email=\(tfEmailAddress.text!)&password=\(tfPassword.text!)&device_token=&lang_id=\(UserModel.sharedInstance().app_language!)"
        }
        
        APIManager.shared.requestGETURL(serviceURL + params, success: { (response) in
            if let jsonObject = response.result.value as? [String:AnyObject] {
                if let status = jsonObject["status"] as? String{
                    if status == "0"{
                        print("Failed")
                        self.showWarning(jsonObject["message"] as! String)
                        //CommonFunctions.shared.showToast(self.view, jsonObject["message"] as! String)
                    }else{
                        print(jsonObject)
                        if let responseData = jsonObject["responsedata"] as? [String:String] {
                            UserModel.sharedInstance().user_id = responseData["res_id"]
                            UserModel.sharedInstance().name = responseData["name"]
                            UserModel.sharedInstance().email = responseData["email"]
                            UserModel.sharedInstance().password = responseData["password"]
                            UserModel.sharedInstance().country = responseData["country"]
                            UserModel.sharedInstance().city = responseData["city"]
                            UserModel.sharedInstance().street = responseData["street"]
                            UserModel.sharedInstance().building_no = responseData["building_no"]
                            UserModel.sharedInstance().province = responseData["province"]
                            UserModel.sharedInstance().profile_image = responseData["image"]
                            UserModel.sharedInstance().zip_code = responseData["zip_code"]
                            UserModel.sharedInstance().latitude = responseData["latitude"]
                            UserModel.sharedInstance().longitude = responseData["longitude"]
                            UserModel.sharedInstance().website = responseData["website"]
                            UserModel.sharedInstance().status = responseData["res_status"]
                            UserModel.sharedInstance().app_language = responseData["app_language"]
                            UserModel.sharedInstance().push_notification = responseData["push_notification"]
                            UserModel.sharedInstance().store_id = responseData["manager_id"]
                            UserModel.sharedInstance().email_notification = responseData["email_notification"]
                            UserModel.sharedInstance().auth_token = responseData["token"]
                            
                            UserModel.sharedInstance().synchroniseData()
                            (UIApplication.shared.delegate as! AppDelegate).ChangeRoot()
                        } else {
                            self.showWarning(Language.WENT_WRONG)
                        }
                    }
                }
            }
            
        }) { (error) in
            print(error)
        }
    }

}
