//
//  DashboardBookingVC.swift
//  Restaurent Manager
//
//  Created by Mahajan on 10/09/21.
//  Copyright © 2021 com.Coder2. All rights reserved.
//

import UIKit

class DashboardBookingVC: Main {

    @IBOutlet weak var lblBookingNew: UILabel!
    @IBOutlet weak var lblBookingAccepted: UILabel!
    @IBOutlet weak var lblBookingArrived: UILabel!
    @IBOutlet weak var lblBookingCompleted: UILabel!
    @IBOutlet weak var lblBookingRejected: UILabel!
    
    @IBOutlet weak var lblOrderComplete: UILabel!
    @IBOutlet weak var lblOrderCompletedAmt: UILabel!
    @IBOutlet weak var lblOrderDeclined: UILabel!
    @IBOutlet weak var lblOrderDeclinedAmt: UILabel!
    @IBOutlet weak var lblOrderUpcoming: UILabel!
    @IBOutlet weak var lblOrderOngoing: UILabel!
    
    @IBOutlet weak var lblTblBookingTitle: UILabel!
    @IBOutlet weak var lblNewTile: UILabel!
    @IBOutlet weak var lblAcceptedTitle: UILabel!
    @IBOutlet weak var lblArrivedTitle: UILabel!
    @IBOutlet weak var lblCompletedTitle: UILabel!
    @IBOutlet weak var lblRejectedTitle: UILabel!
    @IBOutlet weak var lblOrdersTitle: UILabel!
    @IBOutlet weak var lblUpcomingTitle: UILabel!
    @IBOutlet weak var lblOngoingTitle: UILabel!
    @IBOutlet weak var lblCompleteTitle: UILabel!
    @IBOutlet weak var lblCompletedAmtTitle: UILabel!
    @IBOutlet weak var lblDeclineTitle: UILabel!
    @IBOutlet weak var lblDeclinedAmtTitle: UILabel!
    @IBOutlet weak var lblDashboard: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.lblDashboard.text = Language.DASHBOARD
        self.lblTblBookingTitle.text = Language.TODAY_TABLE_BOOKING
        self.lblNewTile.text = Language.NEW
        self.lblAcceptedTitle.text = Language.ACCEPTED
        self.lblArrivedTitle.text = Language.ARRIVED
        self.lblCompletedTitle.text = Language.COMPLETED
        self.lblRejectedTitle.text = Language.REJECT
        self.lblOrdersTitle.text = Language.ORDERS
        self.lblUpcomingTitle.text = Language.UPCOMING
        self.lblOngoingTitle.text = Language.ONGOING
        self.lblCompleteTitle.text = Language.COMPLETED
        self.lblCompletedAmtTitle.text = Language.COMPLETED_AMOUNT
        self.lblDeclineTitle.text = Language.DECLINED
        self.lblDeclinedAmtTitle.text = Language.DECLINED_AMOUNT
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setStatusBarColor(AppColors.light_Brown)
        callDashboardBooking()
    }
    
    @IBAction func btnSideMenu_Action(_ sender: UIButton) {
        toggleSideMenuView()
    }
    
    @IBAction func btnTableBooking_Action(_ sender: UIButton) {
        self.performSegue(withIdentifier: "toBookings", sender: "")
    }
    
    @IBAction func btnOrderBooking_Action(_ sender: UIButton) {
        self.performSegue(withIdentifier: "toOrders", sender: "0")
    }
    
    @IBAction func btnTB_New_Action(_ sender: UIButton) {
        self.performSegue(withIdentifier: "toBookings", sender: "pending")
    }
    
    @IBAction func btnTB_Accepted_Action(_ sender: UIButton) {
        self.performSegue(withIdentifier: "toBookings", sender: "approved")
    }
    
    @IBAction func btnTB_Arrived_Action(_ sender: UIButton) {
        self.performSegue(withIdentifier: "toBookings", sender: "arrived")
    }
    
    @IBAction func btnTB_Completed_Action(_ sender: UIButton) {
        self.performSegue(withIdentifier: "toBookings", sender: "left")
    }
    
    @IBAction func btnTB_Rejected_Action(_ sender: UIButton) {
        self.performSegue(withIdentifier: "toBookings", sender: "rejected")
    }
    
    @IBAction func btnOrderUpcoming_Action(_ sender: UIButton) {
        self.performSegue(withIdentifier: "toOrders", sender: "0")
    }
    
    @IBAction func btnOrderOngoing_Action(_ sender: UIButton) {
        self.performSegue(withIdentifier: "toOrders", sender: "1")
    }
    
    @IBAction func btnOrderCompleted_Action(_ sender: UIButton) {
        self.performSegue(withIdentifier: "toOrders", sender: "2")
    }
    
    @IBAction func btnOrderDeclined_Action(_ sender: UIButton) {
        self.performSegue(withIdentifier: "toOrders", sender: "2")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toOrders"{
            if let dest = segue.destination as? DashboardVC{
                dest.isSelected = Int(sender as! String) ?? 0
            }
            
        }else if segue.identifier == "toBookings" {
            let destVC = segue.destination as! BookedTableListVC
            destVC.bookingType = sender as! String
        }
    }
    
    func callDashboardBooking() {
        
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }

        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        df.locale = Locale(identifier: "en_US_POSIX")
        df.timeZone = TimeZone.current
        let selectedDate = df.string(from: Date())
        
        let serviceURL = Constant.WEBURL + Constant.API.DASHBOARD
        let params = "?res_id=\(UserModel.sharedInstance().user_id!)&auth_token=\(UserModel.sharedInstance().auth_token!)&date=\(selectedDate)&lang_id=\(UserModel.sharedInstance().app_language!)"
        
        APIManager.shared.requestGETURL(serviceURL + params, success: { (response) in
            if let jsonObject = response.result.value as? [String:AnyObject] {
                
                if let status = jsonObject["status"] as? String{
                    if status == "1"{
                        if let data = jsonObject["responsedata"] as? [String:AnyObject], !data.isEmpty{
                            if let bookings = data["bookings"] as? [String:AnyObject], !bookings.isEmpty{
                                self.lblBookingNew.text = bookings["pending"] as? String
                                self.lblBookingAccepted.text = bookings["approved"] as? String
                                self.lblBookingArrived.text = bookings["arrived"] as? String
                                self.lblBookingCompleted.text = bookings["left"] as? String
                                self.lblBookingRejected.text = bookings["rejected"] as? String
                            }
                            
                            if let orders = data["orders"] as? [String:AnyObject], !orders.isEmpty{
                                self.lblOrderUpcoming.text = orders["upcoming"] as? String
                                self.lblOrderOngoing.text = orders["ongoing"] as? String
                                self.lblOrderComplete.text = orders["completed"] as? String
                                self.lblOrderCompletedAmt.text = "€\(orders["completd_amount"] as! String)"
                                self.lblOrderDeclined.text = orders["declined"] as? String
                                self.lblOrderDeclinedAmt.text = "€\(orders["declined_amount"] as! String)"
                            }
                        }
                    }
                }
            }
        }) { (error) in
            print(error)
        }
    }
    
}
