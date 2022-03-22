//
//  BookedTableDetailPopVC.swift
//  Restaurent Manager
//
//  Created by Mahajan on 28/08/21.
//  Copyright © 2021 com.Coder2. All rights reserved.
//

import UIKit

protocol DetailDelegate : NSObjectProtocol {
    func setBookingStatus(status: String, id: String)
}

class BookedTableDetailPopVC: Main {

    static func instantiate() -> BookedTableDetailPopVC? {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BookedTableDetailPopVC") as? BookedTableDetailPopVC
    }
    
    @IBOutlet weak var ivProfile: CustomImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblMobile: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblCancelReason: UILabel!
    @IBOutlet weak var lblSpecialRequest: UILabel!
    
    @IBOutlet weak var btnArriveAccept: CustomButton!
    @IBOutlet weak var btnLeftDecline: CustomButton!
    
    
    @IBOutlet weak var btnReply: CustomButton!
    @IBOutlet weak var vwReply: UIView!
    @IBOutlet weak var tfReply: CustomTextField!
    @IBOutlet weak var btnSubmit: CustomButton!
    
    @IBOutlet weak var lblCancelReasonTitle: UILabel!
    @IBOutlet weak var lblSpecialReqReply: UILabel!
    @IBOutlet weak var lblSpecialReqTitle: UILabel!
    @IBOutlet weak var lblAvgMeal: UILabel!
    @IBOutlet weak var lblNoPersonCome: UILabel!
    @IBOutlet weak var lblNoSeatsAvailable: UILabel!
    
    @IBOutlet weak var lblAvgMeal_Title: UILabel!
    @IBOutlet weak var lblNoPersonCome_Title: UILabel!
    @IBOutlet weak var lblNoSeatsAvailable_Title: UILabel!
    
    weak var detailDelegate: DetailDelegate?
    
    var dictData = [String:AnyObject]()
    var meal_hour = ""
    var meal_minute = ""
    var booking_id = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.lblNoPersonCome_Title.text = Language.NO_OF_PERSON_COME
        self.lblNoSeatsAvailable_Title.text = Language.NO_OF_SEAT_AVAILABLE
        self.lblAvgMeal_Title.text = Language.AVG_MEAL_TIME
        self.btnReply.setTitle(Language.REPLY, for: .normal)
        self.btnSubmit.setTitle(Language.SUBMIT, for: .normal)
        self.tfReply.placeholder = Language.ENTER_UR_REPLY
        
        self.lblName.text = dictData["customer_name"] as? String
        self.lblEmail.text = dictData["customer_email"] as? String
        self.lblMobile.text = dictData["customer_no"] as? String
        
       
        
        self.lblNoPersonCome.text = dictData["guests"] as? String
        self.lblNoSeatsAvailable.text = dictData["available_capacity"] as? String
        self.lblAvgMeal.text = dictData["guests"] as? String
        
        if meal_hour != "" && meal_minute != ""{
            self.lblAvgMeal.text = "\(meal_hour) hour \(meal_minute) minutes"
        }else{
            self.lblAvgMeal.text = "-"
        }
        
        if let reason = dictData["reason"] as? String, reason != ""{
            self.lblCancelReasonTitle.text = "\(Language.CANCELLATION_NOTE):"
            self.lblCancelReasonTitle.isHidden = false
            self.lblCancelReason.text = reason
        }else{
            self.lblCancelReasonTitle.isHidden = true
            self.lblCancelReason.text = ""
        }
        
        if let notes = dictData["notes"] as? String, notes != ""{
            
            self.lblSpecialReqTitle.text = "\(Language.SPECIAL_REQ):"
            self.lblSpecialRequest.text = notes
            
            self.btnReply.isHidden = false
            self.lblSpecialReqTitle.isHidden = false
        }else{
            self.btnReply.isHidden = true
            self.lblSpecialReqTitle.isHidden = true
            self.vwReply.isHidden = true
            self.btnSubmit.isHidden = true
            
            self.lblSpecialRequest.text = ""
        }
        
        if let notes_manager = dictData["notes_manager"] as? String, notes_manager != ""{
            self.lblSpecialReqReply.text = "~\(notes_manager)"
            self.lblSpecialReqReply.isHidden = false
            self.btnReply.isHidden = true
        }else{
            self.lblSpecialReqReply.isHidden = true
        }
        
        booking_id = dictData["id"] as? String ?? ""
        
        if dictData["customer_image"] as! String == "" {
            self.ivProfile.image = UIImage(named: "noImage")
        }else {
            self.ivProfile.kf.setImage(with: URL(string: dictData["customer_image"] as! String), placeholder: UIImage(named: "noImage"), options: [.transition(.fade(1))], progressBlock: nil, completionHandler: nil)
        }
        
        if let status = dictData["status"] as? String, status != ""{
            if status == "pending"{
                btnArriveAccept.isHidden = false
                btnLeftDecline.isHidden = false
                btnArriveAccept.setTitle(Language.ACCEPT, for: .normal)
                btnLeftDecline.setTitle(Language.DECLINED, for: .normal)
            }else if status == "approved"{
                btnArriveAccept.isHidden = false
                btnLeftDecline.isHidden = true
                btnArriveAccept.setTitle(Language.ARRIVED, for: .normal)
            }else if status == "arrived"{
                btnArriveAccept.isHidden = true
                btnLeftDecline.isHidden = false
                btnLeftDecline.setTitle(Language.LEFT, for: .normal)
            }else{
                btnArriveAccept.isHidden = true
                btnLeftDecline.isHidden = true
            }
        }
        
    }
    
    @IBAction func btnCall_Action(_ sender: UIButton) {
        if let mobile = dictData["customer_no"] as? String{
            if mobile != ""{
                let tempMobile = mobile.replacingOccurrences(of: " ", with: "")
                if let url = URL(string: "tel://\(tempMobile)"), UIApplication.shared.canOpenURL(url) {
                    if #available(iOS 10, *) {
                        UIApplication.shared.open(url, options: [:], completionHandler:nil)
                    } else {
                        UIApplication.shared.openURL(url)
                    }
                } else {
                    
                }
            }
        }
    }
    
    @IBAction func btnArriveAccept_Action(_ sender: UIButton) {
        if let status = dictData["status"] as? String, status != ""{
            if status == "pending"{
                self.dismiss(animated: true) {
                    self.detailDelegate?.setBookingStatus(status: "approved",id: self.dictData["id"] as! String)
                }
                
            }else if status == "approved"{
                self.dismiss(animated: true) {
                    self.detailDelegate?.setBookingStatus(status: "arrived",id: self.dictData["id"] as! String)
                }
            }
        }
    }
    
    @IBAction func btnLeftDecline_Action(_ sender: UIButton) {
        if let status = dictData["status"] as? String, status != ""{
            if status == "pending"{
                self.dismiss(animated: true) {
                    self.detailDelegate?.setBookingStatus(status: "decline",id: self.dictData["id"] as! String)
                }
            }else if status == "arrived"{
                self.dismiss(animated: true) {
                    self.detailDelegate?.setBookingStatus(status: "left",id: self.dictData["id"] as! String)
                }
            }
        }
    }
    
    @IBAction func btnCancel_Action(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnReply_Action(_ sender: Any) {
        self.vwReply.isHidden = false
        self.btnSubmit.isHidden = false
        self.btnReply.isHidden = true
    }
    
    @IBAction func btnSubmit_Actionq(_ sender: UIButton) {
        self.view.endEditing(true)
        if tfReply.text!.isEmpty{
            self.showError("Please enter reply")
            self.tfReply.becomeFirstResponder()
        }else{
            callReplyComment()
        }
    }
    
    //MARK:- Web Service
    
    func callReplyComment() {
        
        self.view.endEditing(true)
        
        //Checking for internet connection. If internet is not available then system will display toast message.
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }
        
        //Creating API request to fetch the data.
        let serviceURL = Constant.WEBURL + Constant.API.BOOKING_REPLY
        let params = "?res_id=\(UserModel.sharedInstance().user_id!)&auth_token=\(UserModel.sharedInstance().auth_token!)&lang_id=\(UserModel.sharedInstance().app_language!)&booking_id=\(booking_id)&reply=\(tfReply.text ?? "")"
        
        //Starting process to fetch the data and store default login data.
        APIManager.shared.requestGETURL(serviceURL + params, success: { (response) in
            
            //Parsing method started to parse the data.
            if let jsonObject = response.result.value as? [String:AnyObject] {
                CommonFunctions().hideLoader()
                if let status = jsonObject["status"] as? String{
                    if status == "0"{
                        print("Failed")
                        self.showWarning(jsonObject["message"] as! String)
                    }else{
                        print(jsonObject)
                        self.lblSpecialReqReply.text = "!\(self.tfReply.text ?? "")"
                        self.lblSpecialReqReply.isHidden = false
                        self.vwReply.isHidden = true
                        self.btnSubmit.isHidden = true
                    }
                }
            }
        }) { (error) in
            print(error)
        }
    }
}
