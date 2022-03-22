//
//  ChangePasswordVC.swift
//  Restaurent Manager
//
//  Created by APPLE on 22/09/19.
//  Copyright © 2019 com.Coder2. All rights reserved.
//

import UIKit

class ChangePasswordVC: Main {

    //MARK:- Outlets
    @IBOutlet weak var txtOldPassword: CustomTextField!
    @IBOutlet weak var txtNewPassword: CustomTextField!
    @IBOutlet weak var txtConfirmPassword: CustomTextField!
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var btnUpdate: CustomButton!
    
    
    //MARK:- View Life Cycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        lblHeader.text = Language.CHANGE_PASS
        btnUpdate.setTitle(Language.UPDATE, for: .normal)
        
        txtOldPassword.placeholder = Language.OLD_PASS
        txtNewPassword.placeholder = Language.NEW_PASS
        txtConfirmPassword.placeholder = Language.CONFIRM_PASSWORD
    }
    
    //MARK:- Other Methods
    func checkValidation()->Bool{
        if txtOldPassword.text! == ""{
            txtOldPassword.becomeFirstResponder()
            self.showAlertView(Language.PROVIDE_OLD_PASS)
            return false
        }else if txtNewPassword.text! == ""{
            txtNewPassword.becomeFirstResponder()
            self.showAlertView(Language.PROVIDE_NEW_PASS)
            return false
        }else if txtConfirmPassword.text! == ""{
            txtConfirmPassword.becomeFirstResponder()
            self.showAlertView(Language.CONFIRM_PASSWORD)
            return false
        }else if txtNewPassword.text! != txtConfirmPassword.text!{
            txtConfirmPassword.becomeFirstResponder()
            self.showAlertView(Language.PASS_NOT_MATCH)
            return false
        }else{
            return true
        }
    }
    
    //MARK:- Button Actions
    @IBAction func btnBack_Action(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnUpdate_Action(_ sender: CustomButton) {
        if checkValidation() {
            callChangePasswordAPI()
        }
    }

    //MARK:- Webservices
    func callChangePasswordAPI() {
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }
        
        let serviceURL = Constant.WEBURL + Constant.API.CHANGE_PASSWORD
        let params = "?res_id=\(UserModel.sharedInstance().user_id!)&auth_token=\(UserModel.sharedInstance().auth_token!)&new_password=\(txtNewPassword.text!)&store_id=\(UserModel.sharedInstance().store_id!)&lang_id=\(UserModel.sharedInstance().app_language!)"
        
        APIManager.shared.requestGETURL(serviceURL + params, success: { (response) in
            if let jsonObject = response.result.value as? [String:AnyObject] {
                if let status = jsonObject["status"] as? String{
                    
                    if status == "0"{
                        print("Failed")
                        self.showError(jsonObject["message"] as! String)
                    }else{
                        print(jsonObject)
                        self.showSuccess(jsonObject["message"] as! String)
                        UserModel.sharedInstance().password = self.txtNewPassword.text!
                        UserModel.sharedInstance().synchroniseData()
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
            
        }) { (error) in
            print(error)
        }
    }
}
