//
//  OrderHistoryVC.swift
//  Restaurent Manager
//
//  Created by APPLE on 22/09/19.
//  Copyright © 2019 com.Coder2. All rights reserved.
//

import UIKit

class HistoryOrderCell : UITableViewCell{
    
    @IBOutlet weak var lblOrderId: UILabel!
    @IBOutlet weak var lblOrderDate: UILabel!
    @IBOutlet weak var lblCustName: UILabel!
    @IBOutlet weak var lblCustNo: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblCancelOrderNote: UILabel!
    @IBOutlet weak var lblOrderStatus: CustomLabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var consLblAddressTop: NSLayoutConstraint!
}

class OrderHistoryVC: Main {
    
    //MARK:- Outlets
    @IBOutlet weak var tblOrder: UITableView!
 
    @IBOutlet weak var lblHeader: UILabel!
    
    @IBOutlet weak var lblCompletedTitle: UILabel!
    @IBOutlet weak var lblCompleteTotalOrder: UILabel!
    @IBOutlet weak var lblCompletedAmntTitle: UILabel!
    @IBOutlet weak var lblCompleteTotalOrderAmt: UILabel!
    
    @IBOutlet weak var lblDeclinedTitle: UILabel!
    @IBOutlet weak var lblDeclineTotalOrder: UILabel!
    @IBOutlet weak var lblDeclinedAmntTitle: UILabel!
    @IBOutlet weak var lblDeclineTotalOrderAmt: UILabel!
    
    @IBOutlet weak var consTblHeight: NSLayoutConstraint!
    @IBOutlet weak var tfFilter: CustomTextField!
    
    //MARK:- Global Variables
    var isSelected = 0
    var type = "all"
    var arrDictData = [[String:AnyObject]]()
    
    //Pagination Variables
    var pageNumber = 0
    var isNewDataLoading = true
    var totalCount = 10
    
    var arrFilters = [String]()
    var arrFilterKey = ["all", "today", "yesterday", "last_week", "cur_month"]

    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        lblHeader.text = Language.PAST_ORDERS
        self.tblOrder.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        arrFilters = [Language.ALL, Language.TODAY, Language.YESTERDAY, Language.LAST_WEEK, Language.CURRENT_MONTH]
        lblCompletedTitle.text = Language.COMPLETED
        lblCompletedAmntTitle.text = Language.COMPLETED_AMOUNT
        lblDeclinedTitle.text = Language.DECLINE
        lblDeclinedAmntTitle.text = Language.DECLINED_AMOUNT
        
        tfFilter.text = Language.ALL
        arrDictData.removeAll()
        callOrderHistoryAPI()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        //tblOrder.layer.removeAllAnimations()
        consTblHeight.constant = tblOrder.contentSize.height
        //self.updateViewConstraints()
        self.view.layoutIfNeeded()
    }
    
    //MARK:- Button Actions
    @IBAction func btnMenu_Action(_ sender: Any) {
        toggleSideMenuView()
    }
    @IBAction func btnFilter_Action(_ sender: UIButton) {
        ActionSheetStringPicker.show(withTitle: Language.SELECT, rows: self.arrFilters, initialSelection: 0, doneBlock: {
            picker, indexes, values in
            if values != nil {
                self.tfFilter.text = self.arrFilters[indexes]
                self.type = self.arrFilterKey[indexes]
                
                self.pageNumber = 0
                self.isNewDataLoading = true
                self.arrDictData.removeAll()
                self.callOrderHistoryAPI()
            }
            return
        }, cancel: { ActionStringCancelBlock in
            return
        }, origin: sender)
    }
    
    //MARK:- Web Service Calling
    func callOrderHistoryAPI() {
        
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }

        let serviceURL = Constant.WEBURL + Constant.API.ORDER_HISTORY
        let params = "?res_id=\(UserModel.sharedInstance().user_id!)&auth_token=\(UserModel.sharedInstance().auth_token!)&type=\(type)&start=\(pageNumber)&lang_id=\(UserModel.sharedInstance().app_language!)"
        
        APIManager.shared.requestGETURL(serviceURL + params, success: { (response) in
            if let jsonObject = response.result.value as? [String:AnyObject] {
                
                self.lblCompleteTotalOrder.text = jsonObject["completed_total_orders"] as? String
                self.lblCompleteTotalOrderAmt.text = "€\(jsonObject["completed_total_price"] as! String)"
                self.lblDeclineTotalOrder.text = jsonObject["declined_total_orders"] as? String
                
                if let declined_total_price = jsonObject["declined_total_price"] as? String {
                    self.lblDeclineTotalOrderAmt.text = "€\(declined_total_price)"
                    
                }else{
                    self.lblDeclineTotalOrderAmt.text = "€0.0"
                }
                
                if let status = jsonObject["status"] as? String{
                    if status == "0"{
                        self.tblOrder.tableFooterView = UIView()
                        print("Failed")
                        self.tblOrder.reloadData()
                                         
                        //CommonFunctions.shared.showToast(self.view, jsonObject["message"] as! String)
                    }else{
                        print(jsonObject)
                        if let responseData = jsonObject["responsedata"] as? [String:AnyObject] {
                            if let data = responseData["orders"] as? [[String:AnyObject]] {
                                
                                if data.count == 0{
                                    self.isNewDataLoading = true
                                }else{
                                    for i in 0..<data.count{
                                        self.arrDictData.append(data[i])
                                    }
                                    
                                    self.isNewDataLoading = false
                                }
                                //CommonFunctions.shared.showToast(self.view, jsonObject["message"] as! String)
                            }
                                                      
                        } else {
                            //CommonFunctions.shared.showToast(self.view, "Something went wrong")
                        }
                        self.tblOrder.tableFooterView = UIView()
                        self.tblOrder.reloadData()
                    }
                }
            }
        }) { (error) in
            print(error)
        }
    }

    //MARK:- Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetail" {
            let destVC = segue.destination as! OrderDetailVC
            destVC.orderId = sender as! String
        }
    }
}
extension OrderHistoryVC : UITableViewDataSource, UITableViewDelegate{
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                
        return arrDictData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryOrderCell", for: indexPath) as! HistoryOrderCell
        
        if (arrDictData[indexPath.row])["order_type"] as? String == "completed"{
            
            cell.lblOrderStatus.backgroundColor = UIColor(red: 38/255, green: 125/255, blue: 23/255, alpha: 1.0)
            cell.lblOrderStatus.text = Language.ACCEPTED
            
            cell.lblCancelOrderNote.isHidden = true
            cell.lblCancelOrderNote.text = ""
            
        }else{
            
            cell.lblOrderStatus.backgroundColor = UIColor(red: 185/255, green: 48/255, blue: 38/255, alpha: 1.0)
            cell.lblOrderStatus.text = Language.DECLINED
            
            cell.lblCancelOrderNote.isHidden = false
            if let cancelNote = (arrDictData[indexPath.row])["cancel_note"] as? String, cancelNote != "" {
                let not = Language.CANCEL_NOTE
                cell.lblCancelOrderNote.text = "\(not): \(cancelNote)"
            }else {
                cell.lblCancelOrderNote.text = ""
            }
        }
        

        let parsedOrderDate = self.convertToServer(string: (self.arrDictData[indexPath.row])["order_date"] as! String, format: "yyyy-MM-dd HH:mm:ss")
        let convertedStartTime = self.convertStringFrom(date: parsedOrderDate, format: "dd MMM yyyy, hh:mm a")
        cell.lblOrderDate.text = "\(Language.ORDER_TIME) : \(convertedStartTime)"
        
        cell.lblCustName.text = "\(Language.NAME): \((arrDictData[indexPath.row])["cust_name"] as! String)"
        cell.lblOrderId.text = "#\((arrDictData[indexPath.row])["order_number"] as! String)"
        cell.lblCustNo.text = "\(Language.PHONE_NO): \((arrDictData[indexPath.row])["cust_no"] as! String)"
        cell.lblPrice.text = "€ \((arrDictData[indexPath.row])["price"] as! String)"
        
        if let add = (arrDictData[indexPath.row])["address"] as? String, add != ""{
            cell.lblAddress.text = "\(Language.ADDRESS): \(add)"
            cell.consLblAddressTop.constant = 8.0
        }else{
            cell.lblAddress.text = ""
            cell.consLblAddressTop.constant = 0.0
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "toDetail", sender: arrDictData[indexPath.row]["order_id"] as! String)
    }
    
}
extension OrderHistoryVC: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height) {
            if !isNewDataLoading{
                pageNumber += totalCount
                print("pagenumber : \(pageNumber)")
                isNewDataLoading = true
                self.callOrderHistoryAPI()
                
                let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
                spinner.startAnimating()
                spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: self.tblOrder.bounds.width, height: CGFloat(44))
                
                self.tblOrder.tableFooterView = spinner
                self.tblOrder.tableFooterView?.isHidden = false
            }
        }else{
            print("Scroll Error")
        }
        //}
    }
}
