//
//  BookedTableListVC.swift
//  Restaurent Manager
//
//  Created by Mahajan on 28/08/21.
//  Copyright © 2021 com.Coder2. All rights reserved.
//

import UIKit
import EzPopup

class BookedTableListCell : UITableViewCell{
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblguest: UILabel!
    @IBOutlet weak var lblStatus: CustomLabel!
    @IBOutlet weak var lblSpecialReq: UILabel!
}

class BookedTableListVC: Main {

    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var tblBooking: UITableView!
    @IBOutlet weak var consTblBookingHeight: NSLayoutConstraint!
    
    @IBOutlet weak var btnServiceType: UIButton!
    @IBOutlet weak var btnServiceTime: UIButton!
    
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblNameTbl: UILabel!
    @IBOutlet weak var lblStatusTbl: UILabel!
    @IBOutlet weak var btnBookingStatus: UIButton!
    @IBOutlet weak var lblNoData: UILabel!
    
    
    var arrDictData = [[String:AnyObject]]()
    var selectedDate = ""
    var selectedServiceType = "all"
    var selectedServiceTime = "all"
    
    var current_date = Date()
    var timer = Timer()
    var isNotification = false
    var bookingType = ""
    var meal_hour = ""
    var meal_minute = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.btnBookingStatus.setTitle(Language.ALL, for: .normal)
        
        let df = DateFormatter()
        if selectedDate == ""{
            df.dateFormat = "yyyy-MM-dd"
            df.locale = Locale(identifier: "en_US_POSIX")
            df.timeZone = TimeZone.current
            selectedDate = df.string(from: Date())
            
            df.dateFormat = "E dd MMM"
            df.locale = Locale(identifier: "en_US_POSIX")
            df.timeZone = TimeZone.current
            lblDate.text = df.string(from: Date())
        }else{
            
            let date = selectedDate

            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dtDate = dateFormatter.date(from:date)!
            
            df.dateFormat = "E dd MMM"
            df.locale = Locale(identifier: "en_US_POSIX")
            df.timeZone = TimeZone.current
            lblDate.text = df.string(from: dtDate)
    
        }
        
        callReservationHistory()
        
        self.lblHeader.text = Language.TABLE_BOOKING
        self.lblNoData.text = Language.TABLE_NOT_FOUND
        
        self.lblStatusTbl.text = Language.STATUS
        self.lblNameTbl.text = Language.NAME
        
        self.btnServiceType.setTitle(Language.ALL_SERVICE, for: .normal)
        
        tblBooking.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        
        timer = Timer.scheduledTimer(timeInterval: 5, target: self,   selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setStatusBarColor(AppColors.light_Brown)
        if isNotification{
            navigationController?.isNavigationBarHidden = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        tblBooking.removeObserver(self, forKeyPath: "contentSize")
        super.viewWillDisappear(true)
        if timer != nil{
            if timer.isValid{
                timer.invalidate()
            }
        }
        
        
    }
    
    @objc func updateTimer() {
        callReservationHistory()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        consTblBookingHeight.constant = tblBooking.contentSize.height
    }
    
    @IBAction func btnSideMenu_Action(_ sender: UIButton) {
        if isNotification{
            (UIApplication.shared.delegate as! AppDelegate).ChangeRoot()
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func btnCalender_Action(_ sender: UIButton) {
        let bookedTableCalender = BookedTableCalenderPopVC.instantiate()
        bookedTableCalender?.dateDelegate = self
        let popupVC = PopupViewController(contentController: bookedTableCalender!, popupWidth: self.view.frame.size.width - 50)
        popupVC.cornerRadius = 5
        popupVC.canTapOutsideToDismiss = true
        present(popupVC, animated: true, completion: nil)
    }
    
    @IBAction func btnLeftDate_Action(_ sender: UIButton) {
        
        //let currentDate = convertStringFrom(date: current_date, format: "dd MMM YYYY")
        current_date = current_date.addingTimeInterval(-1 * 24 * 60 * 60)
        lblDate.text = convertStringFrom(date: current_date, format: "E dd MMM")
        selectedDate = self.convertStringFrom(date: self.current_date, format: "yyyy-MM-dd")
        
        var todayDate = ""
        let df = DateFormatter()
        df.dateFormat = "E dd MMM"
        df.locale = Locale(identifier: "en_US_POSIX")
        df.timeZone = TimeZone.current
        todayDate = df.string(from: Date())
        
        if todayDate != lblDate.text{
            self.btnBookingStatus.setTitle(Language.ALL, for: .normal)
            self.selectedServiceTime = "all"
        }
        //self.bookingType = ""
        callReservationHistory()
    }
    
    @IBAction func btnRightDate_Action(_ sender: UIButton) {
        current_date = current_date.addingTimeInterval(1 * 24 * 60 * 60)
        lblDate.text = self.convertStringFrom(date: current_date, format: "E dd MMM")
        selectedDate = self.convertStringFrom(date: self.current_date, format: "yyyy-MM-dd")
        var todayDate = ""
        let df = DateFormatter()
        df.dateFormat = "E dd MMM"
        df.locale = Locale(identifier: "en_US_POSIX")
        df.timeZone = TimeZone.current
        todayDate = df.string(from: Date())
        
        if todayDate != lblDate.text{
            self.btnBookingStatus.setTitle(Language.ALL, for: .normal)
            self.selectedServiceTime = "all"
        }
        //self.bookingType = ""
        callReservationHistory()
    }
    
//    func convertDateFrom(string: String, format: String) -> Date {
//        let df = DateFormatter()
//        df.dateFormat = format
//        //        df.timeZone = TimeZone(identifier: getCurrentTimeZone())
//        return df.date(from: string)!
//    }
//
//    func convertStringFrom(date: Date, format: String) -> String {
//        let df = DateFormatter()
//        df.dateFormat = format
//        return df.string(from: date)
//    }
    
    @IBAction func btnServiceType_Action(_ sender: UIButton) {
        
        ActionSheetStringPicker.show(withTitle: Language.SELECT_SERVICE, rows: [Language.ALL_SERVICE, Language.LUNCH, Language.DINNER], initialSelection: 0, doneBlock: {
            picker, indexes, values in
            if indexes == 0{
                self.btnServiceType.setTitle(Language.ALL_SERVICE, for: .normal)
                self.btnServiceTime.setTitle("12:30 - 22:30", for: .normal)
                self.selectedServiceType = "all"
            }else if indexes == 1{
                self.btnServiceType.setTitle(Language.LUNCH, for: .normal)
                self.btnServiceTime.setTitle("12:30 - 15:00", for: .normal)
                self.selectedServiceType = "lunch"
            }else if indexes == 2{
                self.btnServiceType.setTitle(Language.DINNER, for: .normal)
                self.btnServiceTime.setTitle("18:00 - 22:30", for: .normal)
                self.selectedServiceType = "dinner"
            }
            //self.bookingType = ""
            self.callReservationHistory()
            return
        }, cancel: { ActionStringCancelBlock in
            return
        }, origin: sender)
    }
     
    @IBAction func btnBookingStatus_Action(_ sender: UIButton) {
        var currentDate = ""
        let df = DateFormatter()
        df.dateFormat = "E dd MMM"
        df.locale = Locale(identifier: "en_US_POSIX")
        df.timeZone = TimeZone.current
        currentDate = df.string(from: Date())
        
     
        //if currentDate == lblDate.text{
            ActionSheetStringPicker.show(withTitle: Language.BOOKING_TYPE,
                                         rows: [Language.ALL, Language.PENDING, Language.APPROVED, Language.ARRIVED, Language.LEFT, Language.REJECT],
                                         initialSelection: 0, doneBlock: {
                picker, indexes, values in
                self.btnBookingStatus.setTitle(values as? String, for: .normal)
                //self.selectedServiceTime = (values as! String).lowercased()
                if indexes == 0{
                    self.bookingType = "all"
                }else if indexes == 1{
                    self.bookingType = "pending"
                }else if indexes == 2{
                    self.bookingType = "approved"
                }else if indexes == 3{
                    self.bookingType = "arrived"
                }else if indexes == 4{
                    self.bookingType = "left"
                }else if indexes == 5{
                    self.bookingType = "rejected"
                }
                
                self.callReservationHistory()
                return
            }, cancel: { ActionStringCancelBlock in
                return
            }, origin: sender)
        //}
    }
    
//    func getCurrentTimeZone() -> String {
//            return TimeZone.current.identifier
//        }
    
    func callReservationHistory() {
        
        self.view.endEditing(true)
        
        //Checking for internet connection. If internet is not available then system will display toast message.
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }
        
        //Creating API request to fetch the data.
        let serviceURL = Constant.WEBURL + Constant.API.TABLE_BOOKING_REQUEST
        let params = "?res_id=\(UserModel.sharedInstance().user_id!)&auth_token=\(UserModel.sharedInstance().auth_token!)&lang_id=\(UserModel.sharedInstance().app_language!)&date=\(selectedDate)&type=\(selectedServiceType)&slot_time=\(selectedServiceTime)&timezone=\(getCurrentTimeZone())&booking_type=\(self.bookingType)"
        
        
        
        print(params)
        
        APIManager.shared.requestGETURL_WithOutLoader(serviceURL + params, success: { (response) in
            
            //Parsing method started to parse the data.
            if let jsonObject = response.result.value as? [String:AnyObject] {
                CommonFunctions().hideLoader()
                if let status = jsonObject["status"] as? String{
                    if status == "0"{
                        print("Failed")
                        self.arrDictData.removeAll()
                        self.tblBooking.isHidden = true
                        self.lblNoData.isHidden = false
                        self.showWarning(jsonObject["message"] as! String)
                        
                    }else{
                        print(jsonObject)
                        if let responseData = jsonObject["responsedata"] as? [[String:AnyObject]], responseData.count > 0 {
                            self.arrDictData = responseData
                            self.tblBooking.isHidden = false
                            self.lblNoData.isHidden = true
                            self.meal_minute = jsonObject["avg_meal_min"] as? String ?? ""
                            self.meal_hour = jsonObject["avg_meal_hour"] as? String ?? ""
                        }else{
                            self.tblBooking.isHidden = true
                            self.lblNoData.isHidden = false
                            self.arrDictData.removeAll()
                        }
                    }
                    self.tblBooking.reloadData()
                }
                
            }
        }) { (error) in
            print(error)
        }
    }
    
    func callBookingStatusChange(_ status: String, _ id: String, _ reason: String) {
        
        self.view.endEditing(true)
        
        //Checking for internet connection. If internet is not available then system will display toast message.
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }
        
        //Creating API request to fetch the data.
        let serviceURL = Constant.WEBURL + Constant.API.CHANGE_TABLE_BOOKING_REQUEST
        let params = "?store_id=\(UserModel.sharedInstance().store_id!)&res_id=\(UserModel.sharedInstance().user_id!)&auth_token=\(UserModel.sharedInstance().auth_token!)&lang_id=\(UserModel.sharedInstance().app_language!)&booking=\(id)&status=\(status)&reason=\(reason)"
        
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
                        //self.bookingType = ""
                        self.callReservationHistory()
                    }
                }
                
            }
        }) { (error) in
            print(error)
        }
    }
    
}

extension BookedTableListVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrDictData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookedTableListCell", for: indexPath) as! BookedTableListCell
        
        let data = arrDictData[indexPath.row]
        
        cell.lblName.text = data["customer_name"] as? String
        cell.lblguest.text = data["guests"] as? String
        cell.lblSpecialReq.text = data["notes"] as? String
        
        let status = data["status"] as! String
        
        cell.lblStatus.backgroundColor = UIColor(red: 215/255, green: 241/255, blue: 241/255, alpha: 1.0)
        
        if status == "pending"{
            cell.lblStatus.text = Language.PENDING
        }else if status == "approved"{
            cell.lblStatus.text = Language.RESERVED
        }else if status == "arrived"{
            cell.lblStatus.text = Language.ARRIVED
        }else if status == "decline"{
            cell.lblStatus.text = Language.DECLINED
            cell.lblStatus.backgroundColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1.0)
        }else if status == "left"{
            cell.lblStatus.text = Language.LEFT
        }else if status == "cancel"{
            cell.lblStatus.text = Language.CANCELLED
            cell.lblStatus.backgroundColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1.0)
        }else if status == "reject"{
            cell.lblStatus.text = Language.REJECT
            cell.lblStatus.backgroundColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1.0)
        }
        
        cell.lblTime.text = data["tm"] as? String
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let bookedTableDetail = BookedTableDetailPopVC.instantiate()
        bookedTableDetail?.dictData = arrDictData[indexPath.row]
        bookedTableDetail?.meal_minute = self.meal_minute
        bookedTableDetail?.meal_hour = self.meal_hour
        bookedTableDetail?.detailDelegate = self
        let popupVC = PopupViewController(contentController: bookedTableDetail!, popupWidth: self.view.frame.size.width - 50)
        popupVC.cornerRadius = 5
        popupVC.canTapOutsideToDismiss = true
        present(popupVC, animated: true, completion: nil)
    }
    
}

extension BookedTableListVC : DetailDelegate{
    
    func setBookingStatus(status: String, id: String) {
        print(status)
        if status == "decline"{
            let appUpdatePopup = CancelTableReservationPopVC.instantiate()
            appUpdatePopup?.id = id
            appUpdatePopup?.cancelDelegate = self
            let popupVC = PopupViewController(contentController: appUpdatePopup!, popupWidth: self.view.frame.size.width - 50)
            popupVC.cornerRadius = 5
            popupVC.canTapOutsideToDismiss = true
            present(popupVC, animated: true, completion: nil)
        }else{
            self.callBookingStatusChange(status, id, "")
        }
        
    }
    
    
}
extension BookedTableListVC: CancelDelegate{
    func cancelDelegateReason(_ id: String , _ msg: String) {
        self.callBookingStatusChange("reject", id, msg)
    }
   
}

extension BookedTableListVC: SelectedDateData{
    
    func selectDate(_ date: Date) {
        self.dismiss(animated: true) {
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd"
            df.locale = Locale(identifier: "en_US_POSIX")
            df.timeZone = TimeZone.current
            self.selectedDate = df.string(from: date)
            
            df.dateFormat = "E dd MMM"
            df.locale = Locale(identifier: "en_US_POSIX")
            df.timeZone = TimeZone.current
            self.lblDate.text = df.string(from: date)
            
            let todayDate = df.string(from: Date())
            
            if todayDate != self.lblDate.text{
                self.btnBookingStatus.setTitle(Language.ALL, for: .normal)
                //self.selectedServiceTime = "all"
            }
            //self.bookingType = ""
            self.callReservationHistory()
        }
    }
    
}
