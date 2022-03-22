//
//  AddPointVC.swift
//  Restaurent Manager
//
//  Created by My Mac on 29/09/1941 Saka.
//  Copyright © 1941 com.Coder2. All rights reserved.
//

import UIKit
import Kingfisher

class AddPointVC: Main {

    //MARK:- Variables
    var barCodeData = ""
    var user_id = ""
    
    @IBOutlet weak var ivProfilePic: CustomImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblNo: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    
    @IBOutlet weak var tfAddPoint: CustomTextField!
    
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var lblEnterMangalBelow: UILabel!
    @IBOutlet weak var btnSubmit: CustomButton!
    @IBOutlet weak var lblCustInfo: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if barCodeData != ""{
            callGetCustomerDetail()
        }
        
        lblCustInfo.text = Language.CUST_INFO
        lblHeader.text = Language.ADD_POINT
        lblEnterMangalBelow.text = Language.ENTER_MANGALS
        btnSubmit.setTitle(Language.SUBMIT, for: .normal)
        
    }

    //MARK:- Button Actions
    @IBAction func btnBack_Action(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSubmit_Action(_ sender: Any) {
        self.view.endEditing(true)
        if !tfAddPoint.text!.isEmpty{
            callAddPoint()
        }else{
            self.showAlertView("Please enter mangals")
        }
    }
    //MARK:- Other Functions
   
    
    //MARK:- Web Service Calling
    func callGetCustomerDetail() {
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }
        
        let serviceURL = Constant.WEBURL + Constant.API.GET_CUSTOMER_DETAIL
        let params = "?res_id=\(UserModel.sharedInstance().user_id!)&auth_token=\(UserModel.sharedInstance().auth_token!)&qr=\(barCodeData)&lang_id=\(UserModel.sharedInstance().app_language!)"
        //let params = "?res_id=\(UserModel.sharedInstance().user_id!)&auth_token=\(UserModel.sharedInstance().auth_token!)&qr=815e6212def15fe76ed27cec7a393d59"
        
        APIManager.shared.requestGETURL(serviceURL + params, success: { (response) in
            if let jsonObject = response.result.value as? [String:AnyObject] {
                if let status = jsonObject["status"] as? String{
                    if status == "0"{
                        print("Failed")
                        //CommonFunctions.shared.showToast(self.view, jsonObject["message"] as! String)
                    }else{
                        //CommonFunctions.shared.showToast(self.view, jsonObject["message"] as! String)
                        if let responseData = jsonObject["responsedata"] as? [String:String] {
                            self.lblName.text = responseData["name"]!
                            self.lblNo.text = responseData["mobile_no"]!
                            self.lblEmail.text = responseData["email"]!
                            self.user_id = responseData["id"]!
                            self.ivProfilePic.kf.setImage(with: URL(string: responseData["image"]!.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlFragmentAllowed)!)!, placeholder: UIImage(named: "boy"),options: [.transition(.fade(1))], progressBlock: nil, completionHandler: nil)
                        }
                    }
                }
            }
        }) { (error) in
            print(error)
        }
    }
    
    func callAddPoint() {
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }
        
        let serviceURL = Constant.WEBURL + Constant.API.ADD_POINTS
        let params = "?res_id=\(UserModel.sharedInstance().user_id!)&auth_token=\(UserModel.sharedInstance().auth_token!)&points=\(tfAddPoint.text!)&user_id=\(user_id)&lang_id=\(UserModel.sharedInstance().app_language!)"
        
        APIManager.shared.requestGETURL(serviceURL + params, success: { (response) in
            if let jsonObject = response.result.value as? [String:AnyObject] {
                if let status = jsonObject["status"] as? String{
                    if status == "0"{
                        print("Failed")
                        //CommonFunctions.shared.showToast(self.view, jsonObject["message"] as! String)
                        (UIApplication.shared.delegate as! AppDelegate).ChangeRoot()
                    }else{
                        self.showSuccess(jsonObject["message"] as! String)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            self.navigationController?.popToRootViewController(animated: true)
                        }
                        
                        //CommonFunctions.shared.showToast(self.view, jsonObject["message"] as! String)
                    }
                }
            }
        }) { (error) in
            print(error)
        }
    }
}
