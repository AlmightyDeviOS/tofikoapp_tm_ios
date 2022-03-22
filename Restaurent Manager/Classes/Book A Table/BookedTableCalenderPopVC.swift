//
//  BookedTableCalenderPopVC.swift
//  Restaurent Manager
//
//  Created by Mahajan on 01/09/21.
//  Copyright © 2021 com.Coder2. All rights reserved.
//

import UIKit
import FSCalendar

protocol SelectedDateData : NSObjectProtocol{
    func selectDate(_ date: Date)
}

class BookedTableCalenderPopVC: Main {

    static func instantiate() -> BookedTableCalenderPopVC? {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BookedTableCalenderPopVC") as? BookedTableCalenderPopVC
    }
    
    @IBOutlet weak var vwCalendar: FSCalendar!
    weak var dateDelegate: SelectedDateData?
    
    var holidays = [Date](), bookings = [Date]()
    private lazy var today: Date = {
        return Date()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        vwCalendar.placeholderType = .none
        vwCalendar.firstWeekday = 1
        vwCalendar.calendarHeaderView.isHidden = false
        vwCalendar.locale = Locale(identifier: "en-US")
        
        vwCalendar.appearance.eventOffset = CGPoint(x: 0, y: -10)
        vwCalendar.appearance.titleFont = UIFont(name: "Raleway-Bold", size: 14.0)
        vwCalendar.appearance.weekdayFont = UIFont(name: "Raleway-SemiBold", size: 14.0)
        
        callGetDateBookingHoliday()
        
    }
    
    func callGetDateBookingHoliday() {
        
        self.view.endEditing(true)
        
        //Checking for internet connection. If internet is not available then system will display toast message.
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }
      
        //Creating API request to fetch the data.
        let serviceURL = Constant.WEBURL + Constant.API.GET_CALENDER_DATE
        let params = "?store_id=\(UserModel.sharedInstance().store_id!)&res_id=\(UserModel.sharedInstance().user_id!)&auth_token=\(UserModel.sharedInstance().auth_token!)&lang_id=\(UserModel.sharedInstance().app_language!)"
        
        print(params)
        
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
                        
                        if let responseData = jsonObject["responsedata"] as? [String:AnyObject], !responseData.isEmpty{
                            
                            if let arrBookings = responseData["bookings"] as? [String], arrBookings.count > 0{
                                let dates = arrBookings
                                for i in 0..<dates.count {
                                    let df = DateFormatter()
                                    df.dateFormat = "yyyy-MM-dd"
                                    self.bookings.append(df.date(from: dates[i])!)
                                }
                            }
                            
                            if let arrHolidays = responseData["holidays"] as? [String], arrHolidays.count > 0{
                                let dates = arrHolidays
                                for i in 0..<dates.count {
                                    let df = DateFormatter()
                                    df.dateFormat = "yyyy-MM-dd"
                                    self.holidays.append(df.date(from: dates[i])!)
                                }
                            }
                            
                            self.vwCalendar.reloadData()
                        }
                    }
                }
            }
        }) { (error) in
            print(error)
        }
    }
    
}
extension BookedTableCalenderPopVC : FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        self.dateDelegate?.selectDate(date)
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        return 1
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        if holidays.contains(date) {
            return [.red]
        }else if bookings.contains(date) {
            return [UIColor(named: "theme_color")!]
        }else {
            return [UIColor.white]
        }
    }
        
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleSelectionColorFor date: Date) -> UIColor? {
        return .white
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        return UIColor.lightGray
    }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        if holidays.contains(date) {
            return false
        }else if bookings.contains(date) {
            return true
        }else {
            return false
        }
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
//      lblMonthYear.text = "\(getMonthName(calendar.currentPage)) \(getYear(calendar.currentPage))"
    }
}
