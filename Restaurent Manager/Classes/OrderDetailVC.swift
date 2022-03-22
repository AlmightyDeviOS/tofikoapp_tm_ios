//
//  OrderDetailVC.swift
//  Restaurent Manager
//
//  Created by APPLE on 21/09/19.
//  Copyright © 2019 com.Coder2. All rights reserved.
//

import UIKit

class OrderDetailCell : UITableViewCell {
    @IBOutlet weak var lblItemName: UILabel!
    @IBOutlet weak var lblItemPrice: CustomLabel!
    @IBOutlet weak var lblItemQuantity: CustomLabel!
    @IBOutlet weak var lblTotalPrice: UILabel!
    
    @IBOutlet weak var cnsTopTasteTitle: NSLayoutConstraint!
    @IBOutlet weak var cnsTopTaste: NSLayoutConstraint!
    @IBOutlet weak var lblTasteTitle: UILabel!
    @IBOutlet weak var lblTasteCustomize: UILabel!
    
    @IBOutlet weak var cnsTopCookingTitle: NSLayoutConstraint!
    @IBOutlet weak var cnsTopCooking: NSLayoutConstraint!
    @IBOutlet weak var lblCookingTitle: UILabel!
    @IBOutlet weak var lblCookingCustomize: UILabel!
    
    @IBOutlet weak var cnsTopAddonsTitle: NSLayoutConstraint!
    @IBOutlet weak var cnsTopAddons: NSLayoutConstraint!
    @IBOutlet weak var lblAddOnsTitle: UILabel!
    @IBOutlet weak var lblAddCustomize: UILabel!
    @IBOutlet weak var lblAddCustPrice: CustomLabel!
    
    @IBOutlet weak var cnsTopRemoveTitle: NSLayoutConstraint!
    @IBOutlet weak var cnsTopRemove: NSLayoutConstraint!
    @IBOutlet weak var lblRemoveTitle: UILabel!
    @IBOutlet weak var lblRemoveCustomize: UILabel!
}

class OrderDetailVC: Main {
    
    //MARK:- Outlets
    @IBOutlet weak var tblItemList: UITableView!
    @IBOutlet weak var consTblItemList: NSLayoutConstraint!
    
    @IBOutlet weak var lblOrderDate: UILabel!
    @IBOutlet weak var lblOrderId: UILabel!
    @IBOutlet weak var lblCustName: UILabel!
    @IBOutlet weak var lblDeliveryType: UILabel!
    @IBOutlet weak var lblOrderType: UILabel!
    @IBOutlet weak var lblPaymentType: UILabel!
    
    @IBOutlet weak var lblDeliveryTime: UILabel!
    @IBOutlet weak var lblCustNo: UILabel!
    @IBOutlet weak var lblAdd: UILabel!
    
    @IBOutlet weak var lblItemTitle: UILabel!
    
    @IBOutlet weak var lblNotes: UILabel!
    @IBOutlet weak var cnsTopNoteTitle: NSLayoutConstraint!
    
    @IBOutlet weak var lblSubTotalTitle: UILabel!
    @IBOutlet weak var lblSubTotal: UILabel!
        
    @IBOutlet weak var lblDeliveryChargeTitle: UILabel!
    @IBOutlet weak var lblDeliveryCharge: UILabel!
    
    @IBOutlet weak var lblFinalTotalTitle: UILabel!
    @IBOutlet weak var lblTotalAmount: UILabel!
    
    @IBOutlet weak var lblInvoiceDetailTitle: UILabel!
    @IBOutlet weak var lblInvoiceDetail: UILabel!
    @IBOutlet weak var cnsTopInvoiceTitle: NSLayoutConstraint!
    
    @IBOutlet weak var lblLastOrder: UILabel!
    @IBOutlet weak var lblHeader: UILabel!
    
    @IBOutlet weak var btnAccept: UIButton!
    @IBOutlet weak var btnDecline: UIButton!
    @IBOutlet weak var btnDeliver: UIButton!
    @IBOutlet weak var btnComplete: CustomButton!
    @IBOutlet weak var consBtnsHeight: NSLayoutConstraint!
    
    @IBOutlet weak var ivBlur: UIImageView!
    @IBOutlet var vwCancelOrder: CustomUIView!
    @IBOutlet weak var txtCancelReason: CustomTextField!
    @IBOutlet weak var cnsHeightTvCancel: NSLayoutConstraint!
    @IBOutlet weak var tvCancel: KMTextView!
    @IBOutlet weak var lblReasonCancel: UILabel!
    @IBOutlet weak var btnSubmit: CustomButton!
    @IBOutlet weak var lblPoints: UILabel!
    
        
    //MARK:- Global Variables
    var arrItems = [[String:AnyObject]]()
    var orderId = ""
    var mobile_no = ""
    var decline_reason = ""
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        lblHeader.text = Language.ORDER_DETAIL
        
        txtCancelReason.placeholder = Language.SELECT
        lblReasonCancel.text = Language.SELECT_REASON_TO_CANCEL
        btnSubmit.setTitle(Language.SUBMIT, for: .normal)
        
        lblSubTotalTitle.text = "\(Language.ITEM_TOTAL) :"
        lblDeliveryChargeTitle.text = "\(Language.DELIVERY) :"
        lblFinalTotalTitle.text = "\(Language.TOTAL_PAYABLE_AMT) :"
        lblItemTitle.text = "\(Language.ITEMS)"
        
        btnAccept.setTitle(Language.ACCEPT, for: .normal)
        btnDecline.setTitle(Language.DECLINE, for: .normal)
        btnDeliver.setTitle(Language.DELIVER, for: .normal)
        btnComplete.setTitle(Language.COMPLETE, for: .normal)
        
        tblItemList.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.new, context: nil)
        callOrderDetailAPI()
    }
    
    //MARK:- Other Functions
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        consTblItemList.constant = tblItemList.contentSize.height
        self.view.layoutIfNeeded()
    }
    
    func setButtons(_ type: String) {
        if type == "pending" {
            btnAccept.isHidden = false
            btnDecline.isHidden = false
            btnDeliver.isHidden = true
            btnComplete.isHidden = true
            
        }else if type == "in_prepare" {
            btnAccept.isHidden = true
            btnDecline.isHidden = false
            btnDeliver.isHidden = false
            btnComplete.isHidden = true
            
        }else if type == "delivery" {
            btnAccept.isHidden = true
            btnDecline.isHidden = true
            btnDeliver.isHidden = true
            btnComplete.isHidden = false
            
        }else {
            btnAccept.isHidden = true
            btnDecline.isHidden = true
            btnDeliver.isHidden = true
            btnComplete.isHidden = true
        }
        
    }
    
    //MARK:- Button Actions
    @IBAction func btnBack_Action(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnCloseCancelOrder_Action(_ sender: UIButton) {
        self.ivBlur.isHidden = true
        self.vwCancelOrder.isHidden = true
    }
    
    @IBAction func btnSubmitCancelOrder_Action(_ sender: UIButton) {
        if decline_reason != ""{
            callOrderStatusAPI("decline")
        }
        self.vwCancelOrder.isHidden = true
        self.ivBlur.isHidden = true
    }
    
    @IBAction func btnOrderStatus_Action(_ sender: UIButton) {
        
        if sender.tag == 11 { //accept btn
            callOrderStatusAPI("in_prepare")
                        
        }else if sender.tag == 12 {
            //decline
            self.vwCancelOrder.frame.size.width = self.view.frame.size.width - 30.0
            self.vwCancelOrder.center = self.view.center
            self.view.addSubview(self.vwCancelOrder)
            self.ivBlur.isHidden = false
            self.vwCancelOrder.isHidden = false
            
        }else if sender.tag == 13 {
            //deliver
            callOrderStatusAPI("delivery")
            
        }else if sender.tag == 14 {
            //complete
            callOrderStatusAPI("completed")
        }
    }
    
    
    @IBAction func btnCall_Action(_ sender: Any) {
        
        if mobile_no != ""{
            
            if let url = URL(string: "tel://\(mobile_no)"), UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler:nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            } else {
                // add error message here
            }
        }
        
    }
    
    //MARK:- UITextFieldDelegate Method
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == txtCancelReason {
            let arrOptions = [Language.PRODUCT_NOT_AVAILABLE, Language.EXTRA_CLOSURE, Language.TECH_PROBLEM, Language.OTHER]
            ActionSheetStringPicker.show(withTitle: "", rows: arrOptions as [Any], initialSelection: 0, doneBlock: {
                picker, indexes, values in
                if values != nil{
                    if let strValue = values as? String {
                        self.decline_reason = strValue
                        self.txtCancelReason.text = strValue
                        if strValue == Language.OTHER {
                            self.tvCancel.isHidden = false
                            self.cnsHeightTvCancel.constant = 60.0
                        }else {
                            self.tvCancel.isHidden = true
                            self.cnsHeightTvCancel.constant = 0.0
                        }
                     }
                }
                return
            }, cancel: { ActionStringCancelBlock in
                return
            }, origin: txtCancelReason)
            
            return false
        }
        return false
    }
        
    //MARK:- Web Service Calling
    func callOrderDetailAPI() {
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }
        
        let serviceURL = Constant.WEBURL + Constant.API.ORDER_DETAIL
        let params = "?res_id=\(UserModel.sharedInstance().user_id!)&auth_token=\(UserModel.sharedInstance().auth_token!)&order_id=\(orderId)&lang_id=\(UserModel.sharedInstance().app_language!)"
        
        APIManager.shared.requestGETURL(serviceURL + params, success: { (response) in
            if let jsonObject = response.result.value as? [String:AnyObject] {
                if let status = jsonObject["status"] as? String{
                    if status == "0"{
                        print("Failed")
                        //CommonFunctions.shared.showToast(self.view, jsonObject["message"] as! String)
                    }else{
                        //CommonFunctions.shared.showToast(self.view, jsonObject["message"] as! String)
                        
                        let data = (jsonObject["responsedata"] as! [String:AnyObject])
                        
                        self.lblOrderId.text = "\(Language.ORDER_NUMBER) : #\(data["order_number"] as! String)"
                        self.lblCustName.text = "\(Language.CUSTOMER_NAME) : \(data["customer_name"] as! String)"
                        self.lblCustNo.text = "\(Language.CUSTOMER_NUMBER) : \(data["customer_no"] as! String)"
                        self.mobile_no = "\(data["customer_ccode"] as! String)\(data["customer_no"] as! String)"
                        
                        if let fid_point = data["fidelity_points"] as? String , fid_point != ""{
                            self.lblPoints.text = "\(Language.CUSTOMER_RECEIVE_THIS_POINTS1) \(fid_point) \(Language.CUSTOMER_RECEIVE_THIS_POINTS2)"
                        }else{
                            self.lblPoints.text = ""
                        }
                        
                        if let address = data["address"] as? String, address != "" {
                            self.lblAdd.text = "\(Language.ADDRESS) : \(address)"
                        }else {
                            self.lblAdd.text = ""
                        }
                
                        if let paymentType = data["payment_type"] as? String, paymentType != "" {
                                                        
                            if paymentType == "cod" {
                                self.lblPaymentType.text = "\(Language.PAYMENT_TYPE) : \(Language.CASH_ON_DELIVERY)"
                                
                            }else if paymentType == "stripe" {
                                self.lblPaymentType.text = "\(Language.PAYMENT_TYPE) : Stripe"
                                
                            }else if paymentType == "paypal" {
                                self.lblPaymentType.text = "\(Language.PAYMENT_TYPE) : Paypal"
                                
                            }else if paymentType == "satispay" {
                                self.lblPaymentType.text = "\(Language.PAYMENT_TYPE) : SatisPay"
                                
                            }else if paymentType == "bancomat" {
                                self.lblPaymentType.text = "\(Language.PAYMENT_TYPE) : Bancomat"
                                
                            }else {
                                self.lblPaymentType.text = "\(Language.PAYMENT_TYPE) : \(paymentType)"
                            }
                        }
                        
                        if data["delivery_type"] as! String == Language.LATER {
                            self.lblDeliveryType.text = "\(Language.DELIVERY_TYPE) : \(Language.LATER)"
                        }else {
                            self.lblDeliveryType.text = "\(Language.DELIVERY_TYPE) : \(Language.NOW)"
                        }
                        
                        if data["delivery_type"] as! String == "Later" {
                            self.lblDeliveryType.text = "\(Language.DELIVERY_TYPE) : \(data["order_type"] as! String) (\(Language.LATER) : \(data["delivery_time"] as! String))"
                        }else {
                            if let deliveryTime = data["delivery_time"] as? String, deliveryTime == ""{
                                self.lblDeliveryType.text = "\(Language.DELIVERY_TYPE) : \(data["order_type"] as! String) (\(Language.NOW))"
                            }else{
                                self.lblDeliveryType.text = "\(Language.DELIVERY_TYPE) : \(data["order_type"] as! String) (\(Language.NOW) : \(data["delivery_time"] as! String))"
                            }
                        }
                        
//                        if data["delivery_time"] as! String == Language.LATER {
//                            self.lblDeliveryTime.text = "\(Language.DELIVERY_TIME) : \(data["delivery_time"] as! String)"
//                        }else {
                            self.lblDeliveryTime.text = ""
//                        }
                        
                        self.lblOrderType.text = "\(Language.ORDER_TYPE) : \(data["order_type"] as! String)"
                        self.setButtons(data["order_status"] as! String)
                        
                        
                        if data["past_order_cnt"] as! String == "0" {
                            self.lblLastOrder.text = Language.NEW_CUSTOMER
                        }else {
                            let parsedOrderDate = self.convertToServer(string: data["last_order_date"] as! String, format: "yyyy-MM-dd HH:mm:ss")
                            let convertedStartTime = self.convertStringFrom(date: parsedOrderDate, format: "dd MMM yyyy, hh:mm a")
                            self.lblLastOrder.text = "\(Language.LAST_ORDER_ON) : \(convertedStartTime)\n\(Language.NUMBER_OF_PAST_ORDER) : \(data["past_order_cnt"] as! String)"
                        }
                                           
                        let parsedOrderDate = self.convertToServer(string: data["order_date"] as! String, format: "yyyy-MM-dd HH:mm:ss")
                        let convertedStartTime = self.convertStringFrom(date: parsedOrderDate, format: "dd MMM yyyy, hh:mm a")
                        self.lblOrderDate.text = "\(Language.ORDER_TIME) : \(convertedStartTime)"
                        
                        if let specialNote = data["special_request"] as? String, specialNote != "" {
                            self.lblNotes.text = "\(Language.SPE_NOTE) : \(specialNote)"
                            self.lblNotes.isHidden = false
                            self.cnsTopNoteTitle.constant = 15
                        }else {
                            self.lblNotes.text = ""
                            self.lblNotes.isHidden = true
                            self.cnsTopNoteTitle.constant = 0
                        }
                        
                        if let invoice_detail = data["invoice_detail"] as? String, invoice_detail != "" {
                            self.lblInvoiceDetail.text = invoice_detail
                            self.lblInvoiceDetailTitle.text = Language.INVOICE_DETAIL
                            self.cnsTopInvoiceTitle.constant = 15
                        }else {
                            self.lblInvoiceDetail.text = ""
                            self.lblInvoiceDetailTitle.text = ""
                            self.cnsTopInvoiceTitle.constant = 0
                        }
                        
                        self.lblTotalAmount.text = "€ \(data["order_total"] as! String)"
                        self.lblDeliveryCharge.text = "€ \(data["delivery_charge"] as! String)"
                        self.lblSubTotal.text = "€ \(data["sub_total"] as! String)"
                        
                        if let cart_Item = data["cart_items"] as? [[String:AnyObject]] , cart_Item.count > 0{
                            self.arrItems = cart_Item
                            self.tblItemList.reloadData()
                        }
                        
                        
                    }
                    
                }
            }
        }) { (error) in
            print(error)
        }
    }
    
    func callOrderStatusAPI(_ status:String) {
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }

        var params = ""
        var serviceURL = ""
        
        var declineReason = ""
        if decline_reason == Language.OTHER {
            declineReason = tvCancel.text!
        }else {
            declineReason = decline_reason
        }
        
        if status == "decline"{
            params = "?res_id=\(UserModel.sharedInstance().user_id!)&auth_token=\(UserModel.sharedInstance().auth_token!)&status=\(status)&order_id=\(orderId)&decline_reason=\(declineReason)&lang_id=\(UserModel.sharedInstance().app_language!)"
        }else{
           params = "?res_id=\(UserModel.sharedInstance().user_id!)&auth_token=\(UserModel.sharedInstance().auth_token!)&status=\(status)&order_id=\(orderId)&lang_id=\(UserModel.sharedInstance().app_language!)"
        }
        
        serviceURL = Constant.WEBURL + Constant.API.CHANGE_ORDER_STATUS

        APIManager.shared.requestGETURL(serviceURL + params, success: { (response) in
            if let jsonObject = response.result.value as? [String:AnyObject] {
                if let status = jsonObject["status"] as? String{
                    if status == "0"{
                        print("Failed")
                        //CommonFunctions.shared.showToast(self.view, jsonObject["message"] as! String)
                        self.callOrderDetailAPI()
                    }else{
                        //CommonFunctions.shared.showToast(self.view, jsonObject["message"] as! String)
                        self.callOrderDetailAPI()
                    }
                }
            }
            
        }) { (error) in
            print(error)
        }
    }
}

extension OrderDetailVC : UITableViewDataSource,UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderDetailCell", for: indexPath) as! OrderDetailCell
        
        cell.lblItemName.text = (arrItems[indexPath.row])["item_name"] as? String
        cell.lblItemPrice.text = " € \((arrItems[indexPath.row])["price"] as! String)  "
        cell.lblItemQuantity.text = (arrItems[indexPath.row])["quantity"] as? String
        cell.lblTotalPrice.text = "€ \((arrItems[indexPath.row])["item_total_price"] as! String)"
        
        if let paid = (arrItems[indexPath.row])["paid_customization"] as? [[String:AnyObject]] , paid.count > 0{
            
            var paid_Cust = ""
            var paid_Cust_Price = ""
            
            for i in 0..<paid.count{
                
                let name = (paid[i])["name"] as! String
                
                if paid_Cust == "" {
                    paid_Cust = name
                }else {
                    paid_Cust = "\(paid_Cust)\n\(name)"
                }
               
                if paid_Cust_Price == "" {
                    if let price = (paid[i])["price"] as? String, price != ""{
                        let price = "€\((paid[i])["price"] as! String)"
                        paid_Cust_Price = price
                    }else{
                        paid_Cust_Price = "€0.00"
                    }
                }else {
                    if let price = (paid[i])["price"] as? String, price != ""{
                        let price = "€\((paid[i])["price"] as! String)"
                        paid_Cust_Price = "\(paid_Cust_Price)\n\(price)"
                        
                    }else{
                        paid_Cust_Price = "\(paid_Cust_Price)\n€0.00"
                    }
                }
                
            }
            cell.lblAddCustomize.text = paid_Cust
            cell.lblAddCustPrice.text = paid_Cust_Price
            
            cell.lblAddOnsTitle.text = Language.ADD_ONS
            cell.cnsTopAddonsTitle.constant = 10
            cell.cnsTopAddons.constant = 5
        }else{
            cell.lblAddCustomize.text = ""
            cell.lblAddCustPrice.text = ""
            cell.lblAddOnsTitle.text = ""
            cell.cnsTopAddonsTitle.constant = 0
            cell.cnsTopAddons.constant = 0
        }
        
        if let free = (arrItems[indexPath.row])["free_customization"] as? [[String:AnyObject]] , free.count > 0 {
            var free_Cust = ""
            for i in 0..<free.count {
                let name = (free[i])["name"] as! String
                free_Cust = "\(free_Cust)\(name)\n"
                
            }
            cell.lblRemoveCustomize.text = free_Cust
            cell.lblRemoveTitle.text = Language.REMOVE
            cell.cnsTopRemoveTitle.constant = 10
            cell.cnsTopRemove.constant = 5
        }else{
            cell.lblRemoveCustomize.text = ""
            cell.lblRemoveTitle.text = ""
            cell.cnsTopRemoveTitle.constant = 0
            cell.cnsTopRemove.constant = 0
        }
        
        if let taste = (arrItems[indexPath.row])["taste_customization"] as? String, taste != "" {
            cell.lblTasteCustomize.text = taste
            cell.lblTasteTitle.text = Language.TASTE
            cell.cnsTopTasteTitle.constant = 10
            cell.cnsTopTaste.constant = 5
        }else{
            cell.lblTasteCustomize.text = ""
            cell.lblTasteTitle.text = ""
            cell.cnsTopTasteTitle.constant = 0
            cell.cnsTopTaste.constant = 0
        }
        
        if let cooking = (arrItems[indexPath.row])["cooking_customization"] as? String, cooking != "" {
            cell.lblCookingCustomize.text = cooking
            cell.lblCookingTitle.text = Language.COOKING_LEVEL
            cell.cnsTopCookingTitle.constant = 10
            cell.cnsTopCooking.constant = 5
        }else{
            cell.lblCookingCustomize.text = ""
            cell.lblCookingTitle.text = ""
            cell.cnsTopCookingTitle.constant = 0
            cell.cnsTopCooking.constant = 0
        }
                
        return cell
        
    }
    
}
