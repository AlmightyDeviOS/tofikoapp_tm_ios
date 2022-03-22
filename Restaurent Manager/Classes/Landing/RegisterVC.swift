//
//  RegisterVC.swift
//  Restaurent Manager
//
//  Created by Mahajan on 25/04/21.
//  Copyright © 2021 com.Coder2. All rights reserved.
//

import UIKit
import ADCountryPicker

class RegisterVC: Main {
    
    //MARK:- Outlets
    @IBOutlet weak var tfFirstName: CustomTextField!
    @IBOutlet weak var tfLastName: CustomTextField!
    @IBOutlet weak var tfEmail: CustomTextField!
    @IBOutlet weak var tfPassword: CustomTextField!
    @IBOutlet weak var tfMobile: CustomTextField!
    @IBOutlet weak var tfCountry: CustomTextField!
    @IBOutlet weak var tfCompany: CustomTextField!
    @IBOutlet weak var tfStore: CustomTextField!
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnBottom: UIButton!
    
    @IBOutlet weak var btnRegister: CustomButton!
    //MARK:- Global Variables
    var countryCode = "+39"
    var code = "IT"
    let picker = ADCountryPicker()
    
    var arrDictCompany = [[String:AnyObject]]()
    var arrDictStore = [[String:AnyObject]]()
    
    var arrCompany = [String]()
    var arrStore = [String]()
    
    var selectedCompanyId = ""
    var selectedStoreId = ""
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tfFirstName.placeholder = Language.FNAME
        tfLastName.placeholder = Language.LNAME
        tfEmail.placeholder = Language.EMAIL_ADDRESS
        tfPassword.placeholder = Language.PASSWORD
        tfMobile.placeholder = Language.PHONE_NO
        tfCompany.placeholder = Language.COMPANY
        tfStore.placeholder = Language.STORE
        
        code = Locale.current.regionCode!
        let resourceBundle = Bundle(for: ADCountryPicker.classForCoder())
        let path = resourceBundle.path(forResource: "CallingCodes", ofType: "plist")
        let arrCodes = NSArray(contentsOfFile: path!) as! [[String: String]]
        self.countryCode = (arrCodes.filter{$0["code"] == code}[0]["dial_code"])!
        self.tfCountry.text = self.countryCode
     
        callGetCompany()
        
        self.btnBottom.setTitle(Language.LOGIN_FLOW, for: .normal)
        
        self.btnRegister.setTitle(Language.REGISTER, for: .normal)
        
        self.lblTitle.text = Language.JOIN_US
        
    }
    
    //MARK:- Button Actions
    @IBAction func btnBack_Action(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnRegister_Action(_ sender: Any) {
        self.view.endEditing(true)
        if validation(){
            callRegister()
        }
        
    }
    //MARK:- Other Functions
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        tfMobile.resignFirstResponder()
        if textField == tfCompany{
            tfCompany.resignFirstResponder()
            tfCompany.tintColor = UIColor.clear
            ActionSheetStringPicker.show(withTitle: Language.SELECT_COMPANY, rows: arrCompany, initialSelection: 0, doneBlock: {
                picker, indexes, values in
                self.tfCompany.text = "\(values as! String)"
                self.selectedCompanyId = (self.arrDictCompany[indexes])["id"] as? String ?? ""
                self.callGetStore()
                return
            }, cancel: { ActionStringCancelBlock in
                return
            }, origin: tfCompany)
            return false
            
        }else if textField == tfStore{
            
            if arrStore.count > 0{
                tfStore.resignFirstResponder()
                tfStore.tintColor = UIColor.clear
                ActionSheetStringPicker.show(withTitle: Language.SELECT_STORE, rows: arrStore, initialSelection: 0, doneBlock: {
                    picker, indexes, values in
                    self.tfStore.text = "\(values as! String)"
                    self.selectedStoreId = (self.arrDictStore[indexes])["id"] as? String ?? ""
                    return
                }, cancel: { ActionStringCancelBlock in
                    return
                }, origin: tfStore)
            }
            
            return false
            
        }else if textField == tfCountry{
            let pickerNavigationController = UINavigationController(rootViewController: picker)
            picker.showCallingCodes = true
            picker.showFlags = true
            //picker.pickerTitle = Language.SELECT_COUNTRY
            picker.defaultCountryCode = code
            picker.forceDefaultCountryCode = false
            picker.alphabetScrollBarTintColor = UIColor.black
            picker.alphabetScrollBarBackgroundColor = UIColor.clear
            picker.closeButtonTintColor = UIColor.black
            picker.font = UIFont(name: "Raleway-Regular", size: 15)
            picker.flagHeight = 40
            picker.hidesNavigationBarWhenPresentingSearch = true
            picker.searchBarBackgroundColor = UIColor.white
            picker.didSelectCountryWithCallingCodeClosure = { name, code, dialCode in
                self.countryCode = dialCode
                self.tfCountry.text = dialCode
                //self.ivCountryCode.image =  self.picker.getFlag(countryCode: code)
                self.picker.dismiss(animated: true, completion: nil)
            }
            self.present(pickerNavigationController, animated: true, completion: nil)
            return false
        }else{
            return true
        }
    }
    
    func validation() -> Bool{
        self.view.endEditing(true)
        if tfFirstName.text!.isEmpty{
            self.showError(Language.PROVIDE_FNAME)
            return false
        }else if tfLastName.text!.isEmpty{
            self.showError(Language.PROVIDE_LNAME)
            return false
        }else if tfEmail.text!.isEmpty{
            self.showError(Language.PROVIDE_EMAIL)
            return false
        }else if tfPassword.text!.isEmpty{
            self.showError(Language.PROVIDE_PASS)
            return false
        }else if tfCompany.text!.isEmpty{
            self.showError(Language.ENTER_COMPANY)
            return false
        }else if tfStore.text!.isEmpty{
            self.showError(Language.ENTER_STORE)
            return false
        }else{
            return true
        }
    }
    
    //MARK:- Webservices
    func callGetCompany() {
        
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }
        
        let serviceURL = Constant.WEBURL + Constant.API.GET_COMPANY
        
        let params = "?lang_id=\(UserModel.sharedInstance().app_language!)"
        
        APIManager.shared.requestGETURL(serviceURL + params, success: { (response) in
            if let jsonObject = response.result.value as? [String:AnyObject] {
                if let status = jsonObject["status"] as? String{
                    if status == "0"{
                        print("Failed")
                    }else{
                        if let data = jsonObject["responsedata"] as? [[String:AnyObject]], data.count > 0{
                            self.arrDictCompany = data
                            self.arrCompany = self.arrDictCompany.map{$0["name"] as! String}
                        }
                    }
                }
            }
            
        }) { (error) in
            print(error)
        }
    }
    
    func callGetStore() {
        CommonFunctions().showLoader()
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }
        
        let serviceURL = Constant.WEBURL + Constant.API.GET_STORE_BY_COMPANY
        
        let params = "?lang_id=\(UserModel.sharedInstance().app_language!)&company_id=\(selectedCompanyId)"
        
        APIManager.shared.requestGETURL(serviceURL + params, success: { (response) in
            CommonFunctions().hideLoader()
            if let jsonObject = response.result.value as? [String:AnyObject] {
                if let status = jsonObject["status"] as? String{
                    if status == "0"{
                        print("Failed")
                    }else{
                        if let data = jsonObject["responsedata"] as? [[String:AnyObject]], data.count > 0{
                            self.arrDictStore = data
                            self.arrStore = self.arrDictStore.map{$0["name"] as! String}
                        }
                    }
                }
            }
            
        }) { (error) in
            print(error)
        }
    }
    
    func callRegister() {
        
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }
        
        let serviceURL = Constant.WEBURL + Constant.API.REGISTER
        
      
        let param = ["lang_id" : UserModel.sharedInstance().app_language!,
                     "fname" : tfFirstName.text!,
                     "lname" : tfLastName.text!,
                     "country_code" : tfCountry.text ?? "" ,
                     "mobile_no" : tfMobile.text ?? "",
                     "store_id" : selectedStoreId,
                     "email" : tfEmail.text!,
                     "password" : tfPassword.text!,
                     "device_token" : UserModel.sharedInstance().deviceToken!,
        ]
        
        APIManager.shared.requestPostURL(serviceURL, param: param, success: { (response) in
            if let jsonObject = response.result.value as? [String:AnyObject] {
                if let status = jsonObject["status"] as? String{
                    if status == "0"{
                        print("Failed")
                        self.showError(jsonObject["message"] as! String)
                    }else{
                        print("Success")
                        self.showSuccess(jsonObject["message"] as! String)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }
            
        }) { (error) in
            print(error)
        }
    }

}
