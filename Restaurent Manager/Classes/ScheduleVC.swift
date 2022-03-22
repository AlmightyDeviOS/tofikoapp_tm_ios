//
//  ScheduleVC.swift
//  Restaurent Manager
//
//  Created by APPLE on 20/09/19.
//  Copyright © 2019 com.Coder2. All rights reserved.
//

import UIKit
import FSCalendar

class ScheduleCell : UITableViewCell{
    @IBOutlet weak var lblDay: UILabel!
    @IBOutlet weak var btnMinMax: UIButton!
    @IBOutlet weak var btnStart1: CustomButton!
    @IBOutlet weak var btnStart2: CustomButton!
    @IBOutlet weak var btnEnd1: CustomButton!
    @IBOutlet weak var btnEnd2: CustomButton!
    @IBOutlet weak var consVwTimeHeight: NSLayoutConstraint!
    @IBOutlet weak var btnOnOff: UIButton!
    
    @IBOutlet weak var lblOpen1: UILabel!
    @IBOutlet weak var lblClose1: UILabel!
    
    @IBOutlet weak var lblOpen2: UILabel!
    @IBOutlet weak var lblOpenClose2Sep: UILabel!
    @IBOutlet weak var lblClose2: UILabel!
    
    @IBOutlet weak var lblOpenTimeTitle1: UILabel!
    @IBOutlet weak var lblCloseTimeTitle1: UILabel!
    @IBOutlet weak var lblOpenTimeTitle2: UILabel!
    @IBOutlet weak var lblCloseTimeTitle2: UILabel!
}

class ScheduleVC: Main {
    
    //MARK:- Outlets
    @IBOutlet weak var imgBlur: UIImageView!
    @IBOutlet weak var cnsHeightVwTag: NSLayoutConstraint!
    @IBOutlet weak var tblSchedule: UITableView!
    @IBOutlet weak var vwHolidayTags: TagListView!
    
    @IBOutlet var vwCalendar: CustomUIView!
    @IBOutlet weak var calendarView: FSCalendar!
    @IBOutlet weak var lblMonthName: UILabel!
    @IBOutlet weak var lblYear: UILabel!
    
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var lblHolidayRes: UILabel!
    
    @IBOutlet weak var btnCancel: CustomButton!
    @IBOutlet weak var btnSubmit: CustomButton!
    
    //MARK:- Global Variables
    var selectedIndex = -1
    var arrHolidayDates = [Date]()
    
    var arrOpenCloseTime = [[String:String]]()
    var isWithoutBreak = false
    
    var arrHolidayList = [String]()
    var arrSelectedHoliday = [String]()
    
    //MARK:- View Life Cycle Method
    override func viewDidLoad() {
        super.viewDidLoad()

        lblHeader.text = Language.SCHEDULE
        lblHolidayRes.text = Language.HOLIDAY
        
        btnSubmit.setTitle(Language.SUBMIT, for: .normal)
        btnCancel.setTitle(Language.CANCEL, for: .normal)
        
//        DispatchQueue.main.async {
//            self.vwHolidayTags.setupTagCollection(self)
//            self.vwHolidayTags.delegate = self
//            self.vwHolidayTags.textFont = UIFont(name: "Raleway-Medium", size: 14.0)!
//        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imgTapped))
        imgBlur.isUserInteractionEnabled = true
        imgBlur.addGestureRecognizer(tapGesture)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        callOpenCloseTimeAPI()
    }
    
    func didRemoveTag(_ indexPath: IndexPath) {
        print("RemoveIndexPath==\(indexPath)")
        arrHolidayList.remove(at: indexPath.row)
        callAddHolidaysAPI()
    }
    
    func didTaponTag(_ indexPath: IndexPath) {
        print("Tag tapped:")
    }
    
    //MARK:- Other Methods
    func setHolidayTags() {
        self.vwHolidayTags.removeAllTags()
        if arrHolidayList.count == 0 {
            cnsHeightVwTag.constant = 0.0
        }else {
            //            DispatchQueue.main.async {
            var height = CGFloat(0.0)
            if self.arrHolidayList.count % 2 == 0 {
                height = CGFloat(self.arrHolidayList.count / 2) * 50.0
            }else {
                height = (CGFloat(self.arrHolidayList.count / 2) * 50.0) + 50.0
            }
            self.cnsHeightVwTag.constant = height
            
            vwHolidayTags.textFont = UIFont(name: "Raleway-Medium", size: 14.0)!
            vwHolidayTags.delegate = self
//            vwHolidayTags.addTag("TagListView")
//            vwHolidayTags.addTag("TEAChart")
//            vwHolidayTags.addTag("To Be Removed")
//            vwHolidayTags.addTag("To Be Removed")
//            vwHolidayTags.addTag("Quark Shell")
//            vwHolidayTags.removeTag("To Be Removed")
//            vwHolidayTags.addTag("On tap will be removed").onTap = { [weak self] tagView in
//                self?.vwHolidayTags.removeTagView(tagView)
//            }
            
            for (_, i) in self.arrHolidayList.enumerated() {
                if i != "" {
                    let df = DateFormatter()
                    df.dateFormat = "yyyy-MM-dd"
//                    df.dateFormat = "dd-MM-yyyy"
                    let date = df.date(from: i)

                    self.arrHolidayDates.append(date!)

//                    df.dateFormat = "dd-MMM-yyyy"
                    let strDate = df.string(from: date!)
                    self.vwHolidayTags.addTag(strDate)
                }
            }
//            self.vwHolidayTags.setupTagCollection(self)
            self.view.layoutIfNeeded()
            //            }
        }
        
    }
    
    //MARK:- Button Actions
    @IBAction func btnMenu_Action(_ sender: Any) {
        toggleSideMenuView()
    }
    
    @IBAction func btnClearHoliday(_ sender: UIButton) {
    }
    
    @IBAction func btnCalendar_Action(_ sender: UIButton) {
        calendarView.placeholderType = .none
        calendarView.firstWeekday = 2
        calendarView.calendarHeaderView.isHidden = true
        
        calendarView.locale = Locale(identifier: "en-US")
        
        lblMonthName.text = getMonthName(calendarView.currentPage).localizedUppercase
        lblYear.text = getYear(calendarView.currentPage)
        
        calendarView.appearance.eventOffset = CGPoint(x: 0, y: -10)
        calendarView.appearance.caseOptions = .weekdayUsesUpperCase
        calendarView.appearance.titleFont = UIFont(name: "Raleway-Medium", size: 12.0)
        calendarView.appearance.weekdayFont = UIFont(name: "Raleway-Medium", size: 12.0)
        
        calendarView.allowsMultipleSelection = true
        
        showPopup(vwCalendar)
    }
    
    @IBAction func btnLeftCalendar_Action(_ sender: UIButton) {
        calendarView.setCurrentPage(getPreviousMonth(date: calendarView.currentPage), animated: true)
        lblMonthName.text = getMonthName(calendarView.currentPage).localizedUppercase
        lblYear.text = getYear(calendarView.currentPage)
    }
    
    @IBAction func btnRightCalendar_Action(_ sender: UIButton) {
        calendarView.setCurrentPage(getNextMonth(date: calendarView.currentPage), animated: true)
        lblMonthName.text = getMonthName(calendarView.currentPage).localizedUppercase
        lblYear.text = getYear(calendarView.currentPage)
    }
    
    @objc func imgTapped(_ sender:UITapGestureRecognizer) {
        imgBlur.isHidden = true
        vwCalendar.isHidden = true
    }
    
    @IBAction func btnSubmit_Action(_ sender: CustomButton) {
        callAddHolidaysAPI()
    }
    
    @IBAction func btnCancel_Action(_ sender: CustomButton) {
        hidePopup(vwCalendar)
    }
    
    //MARK:- Other Functions
    //This method is used to show popup
    func showPopup(_ vwToShow:UIView){
        DispatchQueue.main.async {
            self.imgBlur.isHidden = false
            vwToShow.isHidden = false
            self.view.addSubview(vwToShow)
            vwToShow.frame.size.width = self.view.frame.size.width - 40.0
            vwToShow.center = self.view.center
            self.view.layoutIfNeeded()
        }
    }
    
    //This method is used to hide popup
    func hidePopup(_ vwToHide:UIView){
        imgBlur.isHidden = true
        vwToHide.isHidden = true
    }
    
    //Use for calendar
    func getNextMonth(date:Date)->Date {
        return Calendar.current.date(byAdding: .month, value: 1, to:date)!
    }
    
    func getPreviousMonth(date:Date)->Date {
        return Calendar.current.date(byAdding: .month, value: -1, to:date)!
    }
    
    func getMonthName(_ date:Date) -> String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "en-US")
        return df.monthSymbols![(Calendar.current.component(.month, from: date)) - 1]
    }
    
    func getYear(_ date:Date) -> String {
        return  "\(Calendar.current.component(.year, from: date))"
    }
    
    @objc func btnMinMax_Action(_ sender: UIButton) {
        if sender.currentImage == UIImage(named: "up"){
            selectedIndex = -1
        }else{
            selectedIndex = sender.tag
        }
        
        tblSchedule.reloadData()
    }
    
    @objc func btnOnOff_Action(_ sender: UIButton) {
        let dict = arrOpenCloseTime[sender.tag]
        
        var status = ""
        if dict["isopen"]! == "1" {
            status = "0"
        }else {
            status = "1"
        }
        
        self.callSetOpenCloseTimeAPI(dict["day"]!, dict["open_time"]!, dict["close_time"]!, dict["open_time1"]!, dict["close_time1"]!, status)
    }
    
    @objc func btnStart1_Action(_ sender: UIButton){
        let dict = arrOpenCloseTime[sender.tag]
        
        let datePicker = ActionSheetDatePicker(title: "Opening Time", datePickerMode: UIDatePickerMode.time, selectedDate: NSDate() as Date, doneBlock: {
            picker, value, index in
            let dateFormattor = DateFormatter()
            dateFormattor.timeStyle = DateFormatter.Style.short
            dateFormattor.dateFormat = "HH:mm"
            let now = dateFormattor.string(from: value!)
            sender.setTitle(now, for: .normal)
            self.callSetOpenCloseTimeAPI(dict["day"]!, now, dict["close_time"]!, dict["open_time1"]!, dict["close_time1"]!, dict["isopen"]!)
            return
        }, cancel: { ActionStringCancelBlock in return }, origin: (sender as AnyObject).superview!?.superview)
        datePicker?.show()
    }
    
    @objc func btnStart2_Action(_ sender: UIButton){
        let dict = arrOpenCloseTime[sender.tag]
        
        let datePicker = ActionSheetDatePicker(title: "Opening Time", datePickerMode: UIDatePickerMode.time, selectedDate: NSDate() as Date, doneBlock: {
            picker, value, index in
            let dateFormattor = DateFormatter()
            dateFormattor.timeStyle = DateFormatter.Style.short
            dateFormattor.dateFormat = "HH:mm"
            let now = dateFormattor.string(from: value!)
            sender.setTitle(now, for: .normal)
            self.callSetOpenCloseTimeAPI(dict["day"]!, dict["open_time"]!, dict["close_time"]!, now, dict["close_time1"]!, dict["isopen"]!)
            return
        }, cancel: { ActionStringCancelBlock in return }, origin: (sender as AnyObject).superview!?.superview)
        datePicker?.show()
    }
    
    @objc func btnEnd1_Action(_ sender: UIButton){
        let dict = arrOpenCloseTime[sender.tag]
        
        let datePicker = ActionSheetDatePicker(title: "Closing Time", datePickerMode: UIDatePickerMode.time, selectedDate: NSDate() as Date, doneBlock: {
            picker, value, index in
            let dateFormattor = DateFormatter()
            dateFormattor.timeStyle = DateFormatter.Style.short
            dateFormattor.dateFormat = "HH:mm"
            let now = dateFormattor.string(from: value!)
            sender.setTitle(now, for: .normal)
            self.callSetOpenCloseTimeAPI(dict["day"]!, dict["open_time"]!, now, dict["open_time1"]!, dict["close_time1"]!, dict["isopen"]!)
            return
        }, cancel: { ActionStringCancelBlock in return }, origin: (sender as AnyObject).superview!?.superview)
        datePicker?.show()
    }
    
    @objc func btnEnd2_Action(_ sender: UIButton){
        let dict = arrOpenCloseTime[sender.tag]
        
        let datePicker = ActionSheetDatePicker(title: "Closing Time", datePickerMode: UIDatePickerMode.time, selectedDate: NSDate() as Date, doneBlock: {
            picker, value, index in
            let dateFormattor = DateFormatter()
            dateFormattor.timeStyle = DateFormatter.Style.short
            dateFormattor.dateFormat = "HH:mm"
            let now = dateFormattor.string(from: value!)
            sender.setTitle(now, for: .normal)
            self.callSetOpenCloseTimeAPI(dict["day"]!, dict["open_time"]!, dict["close_time"]!, dict["open_time1"]!, now, dict["isopen"]!)
            return
        }, cancel: { ActionStringCancelBlock in return }, origin: (sender as AnyObject).superview!?.superview)
        datePicker?.show()
    }
    
    //MARK:- Web Services
    func callOpenCloseTimeAPI() {
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }
        
        let serviceURL = Constant.WEBURL + Constant.API.OPEN_CLOSE_TIME
        let params = "?res_id=\(UserModel.sharedInstance().user_id!)&auth_token=\(UserModel.sharedInstance().auth_token!)&lang_id=\(UserModel.sharedInstance().app_language!)"
        
        APIManager.shared.requestGETURL(serviceURL + params, success: { (response) in
            if let jsonObject = response.result.value as? [String:AnyObject] {
                if let status = jsonObject["status"] as? String{
                    if status == "0"{
                        print("Failed")
                        //CommonFunctions.shared.showToast(self.view, jsonObject["message"] as! String)
                    }else{
                        //CommonFunctions.shared.showToast(self.view, jsonObject["message"] as! String)
                        print(jsonObject)
                        
                        if let responseData = jsonObject["responsedata"] as? [String:AnyObject] {
                            print(responseData)
                            
                            if responseData["without_break"] as! String == "1" {
                                self.isWithoutBreak = true
                            }else {
                                self.isWithoutBreak = false
                            }
                            
                            if let openCloseTime = responseData["open_close_time"] as? [[String:String]] {
                                self.arrOpenCloseTime = openCloseTime
                                self.tblSchedule.reloadData()
                            }
                            
                            if let holidayDates = responseData["holiday_dates"] as? [String] {
                                print(holidayDates)
                                self.arrHolidayDates.removeAll()
                                self.arrHolidayList = holidayDates
                                self.setHolidayTags()
                            }
                            
                        }
                    }
                }
            }
        }) { (error) in
            print(error)
        }
    }
        
    func callAddHolidaysAPI() {
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }
        
        var strDates = ""
        if arrSelectedHoliday.count > 0 {
            strDates = arrSelectedHoliday.joined(separator: ",")
        }
        
        if arrHolidayList.count > 0 {
            if strDates != "" {
                strDates = "\(strDates),\(arrHolidayList.joined(separator: ","))"
            }else {
                strDates = "\(arrHolidayList.joined(separator: ","))"
            }
        }
        
        let serviceURL = Constant.WEBURL + Constant.API.ADD_HOLIDAY_DATES
        let params = "?res_id=\(UserModel.sharedInstance().user_id!)&auth_token=\(UserModel.sharedInstance().auth_token!)&dates=\(strDates)&lang_id=\(UserModel.sharedInstance().app_language!)"
        
        APIManager.shared.requestGETURL(serviceURL + params, success: { (response) in
            if let jsonObject = response.result.value as? [String:AnyObject] {
                if let status = jsonObject["status"] as? String{
                    if status == "0"{
                        print("Failed")
                        //CommonFunctions.shared.showToast(self.view, jsonObject["message"] as! String)
                    }else{
                        //CommonFunctions.shared.showToast(self.view, jsonObject["message"] as! String)
                        print(jsonObject)
                        self.hidePopup(self.vwCalendar)
                        self.arrSelectedHoliday.removeAll()
                        
                        self.callOpenCloseTimeAPI()
                    
                    }
                }
            }
        }) { (error) in
            print(error)
        }
    }
    
    func callSetOpenCloseTimeAPI(_ dayName:String, _ openTime1:String, _ closeTime1:String, _ openTime2:String, _ closeTime2:String, _ isopen:String) {
   
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }
        
        let serviceURL = Constant.WEBURL + Constant.API.SET_OPEN_CLOSE_TIME
        let params = "?res_id=\(UserModel.sharedInstance().user_id!)&auth_token=\(UserModel.sharedInstance().auth_token!)&day=\(dayName)&open_time=\(openTime1)&close_time=\(closeTime1)&open_time1=\(openTime2)&close_time1=\(closeTime2)&isopen=\(isopen)&lang_id=\(UserModel.sharedInstance().app_language!)"
        
        APIManager.shared.requestGETURL(serviceURL + params, success: { (response) in
            if let jsonObject = response.result.value as? [String:AnyObject] {
                if let status = jsonObject["status"] as? String {
                    if status == "0" {
                        print("Failed")
                        //CommonFunctions.shared.showToast(self.view, jsonObject["message"] as! String)
                    }else {
                        //CommonFunctions.shared.showToast(self.view, jsonObject["message"] as! String)
                        print(jsonObject)
                        self.hidePopup(self.vwCalendar)
                        self.callOpenCloseTimeAPI()
                    }
                }
            }
        }) { (error) in
            print(error)
        }
    }
}

extension ScheduleVC : UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrOpenCloseTime.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleCell", for: indexPath) as! ScheduleCell
        
        let dictData = arrOpenCloseTime[indexPath.row]
        
        if indexPath.row == selectedIndex {
            if isWithoutBreak {
                cell.consVwTimeHeight.constant = 70
            }else {
                cell.consVwTimeHeight.constant = 140
            }
            cell.btnMinMax.setImage(UIImage(named: "up"), for: .normal)
        }else {
            cell.consVwTimeHeight.constant = 00
            cell.btnMinMax.setImage(UIImage(named: "down"), for: .normal)
        }
        
        if dictData["isopen"]! == "1" {
            cell.btnOnOff.setImage(UIImage(named: "on"), for: .normal)
        }else {
            cell.btnOnOff.setImage(UIImage(named: "off"), for: .normal)
        }
        
        cell.btnOnOff.tag = indexPath.row
        cell.btnOnOff.addTarget(self, action: #selector(btnOnOff_Action(_:)), for: .touchDown)
        
        cell.btnMinMax.tag = indexPath.row
        cell.btnMinMax.addTarget(self, action: #selector(btnMinMax_Action(_:)), for: .touchDown)
        
        cell.btnStart1.tag = indexPath.row
        cell.btnStart1.addTarget(self, action: #selector(btnStart1_Action(_:)), for: .touchDown)
        
        cell.btnStart2.tag = indexPath.row
        cell.btnStart2.addTarget(self, action: #selector(btnStart2_Action(_:)), for: .touchDown)
        
        cell.btnEnd1.tag = indexPath.row
        cell.btnEnd1.addTarget(self, action: #selector(btnEnd1_Action(_:)), for: .touchDown)
        
        cell.btnEnd2.tag = indexPath.row
        cell.btnEnd2.addTarget(self, action: #selector(btnEnd2_Action(_:)), for: .touchDown)
        
        
        
        //cell.lblDay.text = dictData["day"]!.capitalized
        cell.lblOpen1.text = dictData["open_time"]!
        cell.lblClose1.text = dictData["close_time"]!
        
        cell.btnStart1.setTitle(dictData["open_time"]!, for: .normal)
        cell.btnEnd1.setTitle(dictData["close_time"]!, for: .normal)
        
        if !isWithoutBreak {
            cell.lblOpen2.text = dictData["open_time1"]!
            cell.lblClose2.text = dictData["close_time1"]!
            
            cell.btnStart2.setTitle(dictData["open_time1"]!, for: .normal)
            cell.btnEnd2.setTitle(dictData["close_time1"]!, for: .normal)
            
            cell.lblOpen2.isHidden = false
            cell.lblClose2.isHidden = false
            
            cell.btnStart2.isHidden = false
            cell.btnEnd2.isHidden = false
            
            cell.lblOpenClose2Sep.isHidden = false
            
        }else {
            cell.lblOpen2.isHidden = true
            cell.lblClose2.isHidden = true
            
            cell.btnStart2.isHidden = true
            cell.btnEnd2.isHidden = true
            
            cell.lblOpenClose2Sep.isHidden = true
        }
        
        
        if dictData["day"]!.capitalized == "Sunday"{
            cell.lblDay.text = Language.SUNDAY
        }else if dictData["day"]!.capitalized == "Monday"{
            cell.lblDay.text = Language.MONDAY
        }else if dictData["day"]!.capitalized == "Tuesday"{
            cell.lblDay.text = Language.TUESDAY
        }else if dictData["day"]!.capitalized == "Wednesday"{
            cell.lblDay.text = Language.WEDNESDAY
        }else if dictData["day"]!.capitalized == "Thursday"{
            cell.lblDay.text = Language.THURSDAY
        }else if dictData["day"]!.capitalized == "Friday"{
            cell.lblDay.text = Language.FRIDAY
        }else if dictData["day"]!.capitalized == "Saturday"{
            cell.lblDay.text = Language.SATURDAY
        }
        
        cell.lblOpenTimeTitle1.text = Language.OPENING_TIME
        cell.lblCloseTimeTitle1.text = Language.CLOSING_TIME
        cell.lblOpenTimeTitle2.text = Language.OPENING_TIME
        cell.lblCloseTimeTitle2.text = Language.CLOSING_TIME
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! ScheduleCell
        
        if cell.btnMinMax.currentImage == UIImage(named: "up"){
            selectedIndex = -1
        }else{
            selectedIndex = indexPath.row
        }
        
        tblSchedule.reloadData()
    }
}

extension ScheduleVC : FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let strDate = df.string(from: date)
        if !arrSelectedHoliday.contains(strDate) && !arrHolidayList.contains(strDate){
            arrSelectedHoliday.append(strDate)
        }
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        for date2 in arrHolidayDates{
            let dateObject1 = date2
            var a1 :Int = datecomp(date: dateObject1, date1: date)
            if a1 == 1 {
                self.calendarView.appearance.eventDefaultColor = UIColor(red: 218/255, green: 168/255, blue: 100/255, alpha: 1.0)
                return 1
            }
            else {
                a1 = datecomp(date: dateObject1, date1: date)
            }
        }
        return 0
    }
    
    func datecomp(date:Date,date1:Date) -> Int {
        switch date.compare(date1) {
            case .orderedAscending     :
                return 0
            case .orderedDescending    :
                return 0
            case .orderedSame          :
                return 1
        }
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleSelectionColorFor date: Date) -> UIColor? {
        return .black
    }
    
}

extension ScheduleVC : TagListViewDelegate {
    func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) {
        
        self.showAlertView("Are you sure you want to remove the date from your holiday list?", defaultTitle: "Yes", cancelTitle: "No") { (finish) in
            if finish {
                sender.removeTagView(tagView)
                self.arrHolidayList.removeAll()
                for i in 0..<sender.tagViews.count {
                    self.arrHolidayList.append(sender.tagViews[i].titleLabel!.text!)
                }
                self.callAddHolidaysAPI()
            }
        }
    }
}
