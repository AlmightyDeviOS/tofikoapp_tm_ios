//
//  SupportVC.swift
//  Restaurent Manager
//
//  Created by APPLE on 22/09/19.
//  Copyright © 2019 com.Coder2. All rights reserved.
//

import UIKit

class SupportVC: Main {

    //MARK:- Outlets
    @IBOutlet weak var txtOptions: CustomTextField!
    @IBOutlet weak var tvMessage: KMTextView!
    
    @IBOutlet weak var btnSend: CustomButton!
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var lblEnterQuery: UILabel!
    //MARK:- Global Variables
    var arrQuestions = [[String:String]]()
    var strQuestionid = ""
    
    //MARK:- View life cycle method
    override func viewDidLoad() {
        super.viewDidLoad()
        txtOptions.placeholder = Language.SELECT
        lblEnterQuery.text = Language.SEND_QUERY_TEAM
        btnSend.setTitle(Language.SEND, for: .normal)
        lblHeader.text = Language.SUPPORT
        tvMessage.placeholder = Language.WRITE_QUERY_HERE
        txtOptions.text = Language.SELECT
        callSupportQuestionsAPI()
    }
    
    //MARK:- Button Actions
    @IBAction func btnBack_Action(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSend_Action(_ sender: CustomButton) {
        
        if strQuestionid != "" && tvMessage.text != ""{
            callsendSupportQuestionsAPI()
        }

    }
    
    //MARK:- Textfield Delegates
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == txtOptions {
            let arrOptions = self.arrQuestions.map{$0["question"]}
            ActionSheetStringPicker.show(withTitle: Language.SELECT, rows: arrOptions as [Any], initialSelection: 0, doneBlock: {
                picker, indexes, values in
                if values != nil{
                    if let strValue = values as? String {
                        self.strQuestionid = (self.arrQuestions[indexes])["id"] as! String
                        self.txtOptions.text = strValue
                        self.txtOptions.resignFirstResponder()
                    }
                }
                return
            }, cancel: { ActionStringCancelBlock in
                return
            }, origin: txtOptions)
            
            return false
        }
        return false
    }
    
    //MARK:- Webservices
    func callSupportQuestionsAPI() {
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }
        
        let serviceURL = Constant.WEBURL + Constant.API.SUPPORT_QUESTION_LIST
        let params = "?res_id=\(UserModel.sharedInstance().user_id!)&auth_token=\(UserModel.sharedInstance().auth_token!)&lang_id=\(UserModel.sharedInstance().app_language!)"
        
        APIManager.shared.requestGETURL(serviceURL + params, success: { (response) in
            if let jsonObject = response.result.value as? [String:AnyObject] {
                if let status = jsonObject["status"] as? String{
                    if status == "0"{
                        print("Failed")
                        //CommonFunctions.shared.showToast(self.view, jsonObject["message"] as! String)
                    }else{
                        print(jsonObject)
                        if let responseData = jsonObject["responsedata"] as? [[String:String]] {
                            //CommonFunctions.shared.showToast(self.view, jsonObject["message"] as! String)
                            self.arrQuestions = responseData
                        } else {
                            //CommonFunctions.shared.showToast(self.view, "Something went wrong")
                        }
                    }
                }
            }
            
        }) { (error) in
            print(error)
        }
    }
    
    func callsendSupportQuestionsAPI() {
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }
        
        let serviceURL = Constant.WEBURL + Constant.API.SEND_SUPPORT
        let params = "?res_id=\(UserModel.sharedInstance().user_id!)&auth_token=\(UserModel.sharedInstance().auth_token!)&question_id=\(strQuestionid)&message=\(tvMessage.text!)&lang_id=\(UserModel.sharedInstance().app_language!)"
        
       
        APIManager.shared.requestGETURL(serviceURL + params, success: { (response) in
            if let jsonObject = response.result.value as? [String:AnyObject] {
                if let status = jsonObject["status"] as? String{
                    if status == "0"{
                        print("Failed")
                        //CommonFunctions.shared.showToast(self.view, jsonObject["message"] as! String)
                    }else{
                        print("Success")
                        //CommonFunctions.shared.showToast(self.view, jsonObject["message"] as! String)
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
            
        }) { (error) in
            print(error)
        }
    }
}

