//
//  ForgotVC.swift
//  Restaurent Manager
//
//  Created by APPLE on 18/09/19.
//  Copyright © 2019 com.Coder2. All rights reserved.
//

import UIKit

class ForgotVC: Main {
    
    //MARK:- Outlets
    @IBOutlet weak var txtEmailAddress: CustomTextField!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var btnSubmit: CustomButton!
    
    //MARK:- Global Variables
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtEmailAddress.placeholder = Language.EMAIL_ADDRESS
        lblMessage.text = Language.SEND_PASS
        btnSubmit.setTitle(Language.SUBMIT, for: .normal)
    }
    
    //MARK:- Other Functions
    func checkValidation()->Bool{
        if txtEmailAddress.text == ""{
            txtEmailAddress.becomeFirstResponder()
            self.showError(Language.PROVIDE_EMAIL)
            return false
        }else if !(txtEmailAddress.text?.isEmail)! {
            txtEmailAddress.becomeFirstResponder()
            self.showError(Language.VAILD_EMAIL)
            return false
        }else{
            return true
        }
    }
    
    //MARK:- Button Actions
    @IBAction func btnBack_Action(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnForgotPassword_Action(_ sender: CustomButton) {
        if checkValidation() {
            callForgotPasswordAPI()
        }
    }
    
    //MARK:- WebServices
    func callForgotPasswordAPI() {
        self.view.endEditing(true)
        
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }
        
        let serviceURL = Constant.WEBURL + Constant.API.FORGOT_PASSWORD
        let params = "?email=\(txtEmailAddress.text!)&lang_id=\(UserModel.sharedInstance().app_language!)"
        
        APIManager.shared.requestGETURL(serviceURL + params, success: { (response) in
            if let jsonObject = response.result.value as? [String:AnyObject] {
                if let status = jsonObject["status"] as? String{
                    if status == "0"{
                        print("Failed")
                        self.showError(jsonObject["message"] as! String)
                    }else{
                        print(jsonObject)
                        self.showSuccess(jsonObject["message"] as! String)
                    }
                }
            }
            
        }) { (error) in
            print(error)
        }
    }
}
