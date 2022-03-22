//
//  NotificationVC.swift
//  Mangal House
//
//  Created by APPLE on 06/09/19.
//  Copyright © 2019 Mahajan-iOS. All rights reserved.
//

import UIKit

class NotificationVC: Main {
    
    //MARK:- Outlets
    @IBOutlet weak var tblNotifications: UITableView!
    
    @IBOutlet weak var lblHeader: UILabel!
    //MARK:- Global Variables
    let arrCategoty = [Language.ORDER_NOTIFICATION]
    let arrOption = [Language.PUSH_NOTIFICATION , Language.EMAIL_NOTIFICATION]
    
    //MARK:- View life cycle method
    override func viewDidLoad() {
        super.viewDidLoad()
        lblHeader.text = Language.PUSH_NOTIFICATION
        tblNotifications.tableFooterView = UIView()
    }
    
    //MARK:- Button Actions
     @IBAction func btnBack_Action(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
     }
    
    @objc func btnSwitch_Action(_ sender:UISwitch) {
        let tag = sender.accessibilityLabel!
        let arr = tag.components(separatedBy: "_")
        if arr[0] == "0" {
            if arr[1] == "0" {
                if sender.isOn {
                    callNotificationStatusService("push_notification", 1)
                }else {
                    callNotificationStatusService("push_notification", 0)
                }
            }else {
                if sender.isOn {
                    callNotificationStatusService("email_notification", 1)
                }else {
                    callNotificationStatusService("email_notification", 0)
                }
            }
        }
    }
    
    //MARK:- Webservice
    func callNotificationStatusService(_ notiType:String, _ notiStatus:Int) {
        
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }
        
        let serviceURL = Constant.WEBURL + Constant.API.NOTIFICATION_STATUS
        let params = "?res_id=\(UserModel.sharedInstance().user_id!)&auth_token=\(UserModel.sharedInstance().auth_token!)&type=\(notiType)&status=\(notiStatus)&store_id=\(UserModel.sharedInstance().store_id!)&lang_id=\(UserModel.sharedInstance().app_language!)"
        
        APIManager.shared.requestGETURL(serviceURL + params, success: { (response) in
            if let jsonObject = response.result.value as? [String:AnyObject] {
                if let status = jsonObject["status"] as? String{
                    if status == "0"{
                        print("Failed")
                        //CommonFunctions.shared.showToast(self.view, jsonObject["message"] as! String)
                    }else{
                        //type(order_push, order_email, news_push, news_email),
                        if notiType == "push_notification" {
                            UserModel.sharedInstance().push_notification = "\(notiStatus)"
                        }else {
                            UserModel.sharedInstance().email_notification = "\(notiStatus)"
                        }
                        UserModel.sharedInstance().synchroniseData()
                        self.tblNotifications.reloadData()
                        //CommonFunctions.shared.showToast(self.view, jsonObject["message"] as! String)
                    }
                }
            }
            
        }) { (error) in
            print(error)
        }
    }
}

//Notification manage from below code
extension NotificationVC : UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrCategoty.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrOption.count
    }
    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return arrCategoty[section]
//    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))
        
        let label = UILabel()
        label.frame = CGRect.init(x: 15, y: 5, width: headerView.frame.width-10, height: headerView.frame.height-10)
        label.text = arrCategoty[section]
        label.font = UIFont(name: "Raleway-Bold", size: 16.0)
        label.textColor = AppColors.light_Brown
        
        headerView.addSubview(label)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = arrOption[indexPath.row].capitalizingFirstLetter()
        let switchView = UISwitch()
        switchView.onTintColor = UIColor(named: "theme_color")
        switchView.accessibilityLabel = "\(indexPath.section)_\(indexPath.row)"
        switchView.addTarget(self, action: #selector(btnSwitch_Action), for: .touchUpInside)
        
        cell.accessoryView = switchView
        cell.textLabel?.textColor = UIColor(red: 75/255, green: 78/255, blue: 78/255, alpha: 1.0)
        cell.selectionStyle = .none
        cell.textLabel?.font = UIFont(name: "Raleway-Regular", size: 15.0)
        
        if indexPath.row == 0 {
            if UserModel.sharedInstance().push_notification != nil && UserModel.sharedInstance().push_notification == "1" {
                switchView.isOn = true
            }else {
                switchView.isOn = false
            }
        }else {
            if UserModel.sharedInstance().email_notification != nil && UserModel.sharedInstance().email_notification == "1" {
                switchView.isOn = true
            }else {
                switchView.isOn = false
            }
        }
        
        return cell
    }
}
