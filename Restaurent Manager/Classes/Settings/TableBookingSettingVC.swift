//
//  TableBookingSettingVC.swift
//  Restaurent Manager
//
//  Created by Almighty Infotech on 18/11/21.
//  Copyright © 2021 com.Coder2. All rights reserved.
//

import UIKit

class TableBookingSettingVC: Main {

    @IBOutlet weak var tfHour: CustomTextField!
    @IBOutlet weak var tfMinute: CustomTextField!
    @IBOutlet weak var tfSeating: CustomTextField!
    
    @IBOutlet weak var lblAvgMealHourTitle: UILabel!
    @IBOutlet weak var lblAvgMealMinuteTitle: UILabel!
    @IBOutlet weak var lblTotSeatingCapTitle: UILabel!
    @IBOutlet weak var lblHeader: UILabel!
    
    @IBOutlet weak var btnSave: CustomButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        btnSave.setTitle(Language.SUBMIT, for: .normal)
        
        tfHour.placeholder = Language.ENTER_HR
        tfMinute.placeholder = Language.ENTER_MIN
        tfSeating.placeholder = Language.ENER_SEAT_CAPACITY
        
        lblHeader.text = Language.TBL_BOOKING_SETTING
        
        lblAvgMealHourTitle.text = Language.AVG_MEAL_TIME_HR
        lblAvgMealMinuteTitle.text = Language.AVG_MEAL_TIME_MIN
        lblTotSeatingCapTitle.text = Language.TOT_SEAT_CAPACITY
        
        tfHour.text = UserModel.sharedInstance().avg_meal_hour ?? ""
        tfMinute.text = UserModel.sharedInstance().avg_meal_min ?? ""
        tfSeating.text = UserModel.sharedInstance().seating_capacity ?? ""
        
    }
    
    @IBAction func btnBack_Action(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSave_Action(_ sender: UIButton) {
        if tfHour.text!.isEmpty{
            self.showError(Language.ENTER_HR)
            self.tfHour.becomeFirstResponder()
        }else if tfMinute.text!.isEmpty{
            self.showError(Language.ENTER_MIN)
            self.tfMinute.becomeFirstResponder()
        }else if tfSeating.text!.isEmpty{
            self.showError(Language.ENER_SEAT_CAPACITY)
            self.tfSeating.becomeFirstResponder()
        }else{
            self.view.endEditing(true)
            callSetSettings()
        }
    }
    
    func callSetSettings() {
        
        //Checking for internet connection. If internet is not available then system will display toast message.
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }
        
        //Creating API request to fetch the data.
        let serviceURL = Constant.WEBURL + Constant.API.TBL_BOOKING_SETTING
        let params = "?res_id=\(UserModel.sharedInstance().user_id!)&auth_token=\(UserModel.sharedInstance().auth_token!)&hour=\(tfHour.text ?? "")&min=\(tfMinute.text ?? "")&capacity=\(tfSeating.text ?? "")"
        
        //Starting process to fetch the data.
        APIManager.shared.requestGETURL(serviceURL + params, success: { (response) in
            
            //Parsing method started to parse the data.
            if let jsonObject = response.result.value as? [String:AnyObject] {
                
                //Getting status of API. If status is 0 then fetching data otherwise it will show message of failure with reason.
                if let status = jsonObject["status"] as? String{
                    if status == "0"{
                        print("Failed")
                        //CommonFunctions.shared.showToast(self.view, jsonObject["message"] as! String)
                    }else{
                        //CommonFunctions.shared.showToast(self.view, jsonObject["message"] as! String)
                        print(jsonObject)
                        
                        
                        UserModel.sharedInstance().avg_meal_min = self.tfMinute.text ?? ""
                        
                        UserModel.sharedInstance().avg_meal_hour = self.tfHour.text ?? ""
                        UserModel.sharedInstance().seating_capacity = self.tfSeating.text ?? ""
                        
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
