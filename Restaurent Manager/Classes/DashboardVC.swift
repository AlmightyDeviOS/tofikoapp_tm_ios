//
//  DashboardVC.swift
//  Restaurent Manager
//
//  Created by APPLE on 21/09/19.
//  Copyright © 2019 com.Coder2. All rights reserved.
//

import UIKit

class DashboardOrderCell : UITableViewCell{
    @IBOutlet weak var lblDeliveryType: UILabel!
    @IBOutlet weak var lblOrderId: UILabel!
    @IBOutlet weak var lblCustName: UILabel!
    @IBOutlet weak var lblCustNo: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var btnEditTime: CustomButton!
}

class DashboardVC: Main {
    
    //MARK:- Outlets
    @IBOutlet weak var btnRestaurantOnOff: UIButton!
    
    @IBOutlet weak var tblOrder: UITableView!
    @IBOutlet weak var btnUpcoming: UIButton!
    @IBOutlet weak var btnInPrepare: UIButton!
    @IBOutlet weak var btnDelivery: CustomButton!
    
    @IBOutlet weak var lblUpcomingBottom: UILabel!
    @IBOutlet weak var lblPrepareBottom: UILabel!
    @IBOutlet weak var lblDeliveryBottom: UILabel!
    
    @IBOutlet weak var lblNoOrders: UILabel!
    @IBOutlet weak var lblHeader: UILabel!
    
    //MARK:- Global Variables
    
    var isSelected = 0
    var arrTime = ["00:15 Min" , "00:30 Min" , "00:45 Min" , "1:00 Hour" ]
    var lastTappedIndex = -1
    var arrOrders = [[String:String]]()
    
    var timer = Timer()
    
    var orderType = "upcoming"
    
    //MARK:- View Life Cycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLayout()
        NotificationCenter.default.addObserver(self, selector: #selector(self.Language_Localization), name: Notification.Name("Language_Localization"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        (UIApplication.shared.delegate as! AppDelegate).call_GeneralAppSetting()
        (UIApplication.shared.delegate as! AppDelegate).call_Get_Language()
        //callCurrentOrderListAPI()
        setStatusBarColor(AppColors.light_Brown)
        
        if UserModel.sharedInstance().app_version != nil && UserModel.sharedInstance().app_version != "" {
            let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
            if Double(UserModel.sharedInstance().app_version!)! > Double(appVersion)!{
                launchAppUpdatePopup()
            }
        }
        
        
        if isSelected == 0{
            upcoming()
        }else if isSelected == 1{
            in_prepare()
        }else if isSelected == 2{
            delivery()
        }
    }
    
    @objc func Language_Localization() {
        
        tblOrder.reloadData()
        
        //lblHeader.text = Language.DASHBOARD.capitalizingFirstLetter()
        lblNoOrders.text = Language.ORDER_NOT_FOUND
        
        btnInPrepare.setTitle(Language.IN_PREPARE, for: .normal)
        btnDelivery.setTitle(Language.DELIVER, for: .normal)
        btnUpcoming.setTitle(Language.UPCOMING, for: .normal)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if timer != nil{
            if timer.isValid{
                timer.invalidate()
            }
        }
    }
    
    //MARK:- Other Methods
    func setLayout() {
        if UserModel.sharedInstance().status != nil && UserModel.sharedInstance().status == "1" {
            btnRestaurantOnOff.setImage(UIImage(named: "on"), for: .normal)
        }else {
            btnRestaurantOnOff.setImage(UIImage(named: "off"), for: .normal)
        }
        
        timer = Timer.scheduledTimer(timeInterval: 5, target: self,   selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
    }
    
    //MARK:- Button Actions
    @IBAction func btnMenu_Action(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnUpcoming_Action(_ sender: Any) {
        upcoming()
    }
    
    @IBAction func btnPrepare_Action(_ sender: Any) {
        in_prepare()
    }
    
    @IBAction func btnDelivery_Action(_ sender: Any) {
        delivery()
    }
    
    func upcoming(){
        lblUpcomingBottom.isHidden = false
        lblPrepareBottom.isHidden = true
        lblDeliveryBottom.isHidden = true
        btnRestaurantOnOff.isHidden = false
        isSelected = 0
        arrOrders.removeAll()
        orderType = "upcoming"
        callCurrentOrderListAPI()
    }
    
    func in_prepare(){
        lblUpcomingBottom.isHidden = true
        lblPrepareBottom.isHidden = false
        lblDeliveryBottom.isHidden = true
        btnRestaurantOnOff.isHidden = false
        isSelected = 1
        arrOrders.removeAll()
        orderType = "in_prepare"
        callCurrentOrderListAPI()
    }
    
    func delivery(){
        lblUpcomingBottom.isHidden = true
        lblPrepareBottom.isHidden = true
        lblDeliveryBottom.isHidden = false
        btnRestaurantOnOff.isHidden = false
        isSelected = 2
        arrOrders.removeAll()
        orderType = "delivery"
        callCurrentOrderListAPI()
    }
    
    @IBAction func btnOpenClose_Action(_ sender: UIButton) {
        self.showAlertView(Language.CONFIRMATION_ORDER_DISABLE, defaultTitle: Language.YES_LABEL, cancelTitle: Language.NO_LABEL) { (finish) in
            if finish{
                if sender.currentImage == UIImage(named : "on"){
                    sender.setImage(UIImage(named: "off"), for: .normal)
                    self.callRestaurantStatusAPI("0")
                }else{
                    sender.setImage(UIImage(named: "on"), for: .normal)
                    self.callRestaurantStatusAPI("1")
                }
            }
        }
    }
    
    @objc func updateTimer() {
        callCurrentOrderListAPI()
    }
    
    //MARK:- Webservices
    func callRestaurantStatusAPI(_ resStatus:String) {
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }
        
        let serviceURL = Constant.WEBURL + Constant.API.SET_RESTAURENT_OFF_ON
        let params = "?res_id=\(UserModel.sharedInstance().user_id!)&auth_token=\(UserModel.sharedInstance().auth_token!)&status=\(resStatus)&lang_id=\(UserModel.sharedInstance().app_language!)"
        
        APIManager.shared.requestGETURL(serviceURL + params, success: { (response) in
            if let jsonObject = response.result.value as? [String:AnyObject] {
                if let status = jsonObject["status"] as? String{
                    if status == "0"{
                        print("Failed")
                        //self.showError(jsonObject["message"] as! String)
                    }else{
                        //self.showSuccess(jsonObject["message"] as! String)
                        UserModel.sharedInstance().status = resStatus
                        UserModel.sharedInstance().synchroniseData()
                    }
                }
            }
        }) { (error) in
            print(error)
        }
    }

    func callCurrentOrderListAPI() {


        self.checkNoInternetConnection()
        
        let serviceURL = Constant.WEBURL + Constant.API.CURRENT_ORDER_LIST
        let params = "?res_id=\(UserModel.sharedInstance().user_id!)&auth_token=\(UserModel.sharedInstance().auth_token!)&type=\(orderType)&lang_id=\(UserModel.sharedInstance().app_language!)"
        
        APIManager.shared.requestGETURL_WithOutLoader(serviceURL + params, success: { (response) in
            if let jsonObject = response.result.value as? [String:AnyObject] {
                if let status = jsonObject["status"] as? String{
                    if status == "0"{
                        print("Failed")
                        self.arrOrders.removeAll()
                        self.lblNoOrders.isHidden = false
                        //CommonFunctions.shared.showToast(self.view, jsonObject["message"] as! String)
                        self.tblOrder.reloadData()
                    }else{
                        print(jsonObject)
                        if let responseData = jsonObject["responsedata"] as? [[String:String]] {
                            
                            self.arrOrders = responseData
                            self.lblNoOrders.isHidden = true
                        } else {
                            self.lblNoOrders.isHidden = true
                            //CommonFunctions.shared.showToast(self.view, "Someting went wrong")
                        }
                        self.tblOrder.reloadData()
                    }
                }
            }
            
        }) { (error) in
            print(error)
        }
    }
    
    func callEditTime(time : String, orderId : String) {
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }

        let params = "?res_id=\(UserModel.sharedInstance().user_id!)&auth_token=\(UserModel.sharedInstance().auth_token!)&order_time=\(time)&order_id=\(orderId)&lang_id=\(UserModel.sharedInstance().app_language!)"
        
        let serviceURL = Constant.WEBURL + Constant.API.EDIT_ORDER_TIME

        APIManager.shared.requestGETURL(serviceURL + params, success: { (response) in
            if let jsonObject = response.result.value as? [String:AnyObject] {
                if let status = jsonObject["status"] as? String{
                    if status == "0"{
                        print("Failed")
                        self.callCurrentOrderListAPI()
                    }else{
                        self.callCurrentOrderListAPI()
                    }
                }
            }
            
        }) { (error) in
            print(error)
        }
    }
    
    //MARK:- Navigation Methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetail" {
            let vc = segue.destination as! OrderDetailVC
            vc.orderId = sender as! String
        }
    }
    
}

extension DashboardVC : UITableViewDataSource,UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrOrders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DashboardOrderCell", for: indexPath) as! DashboardOrderCell
        
        if isSelected == 0{
            cell.btnEditTime.isHidden = false
        }else {
            cell.btnEditTime.isHidden = true
        }
    
        if arrOrders.count > 0{
            
            let parsedOrderDate = self.convertToServer(string: (self.arrOrders[indexPath.row])["order_date"]!, format: "yyyy-MM-dd HH:mm:ss")
            let convertedStartTime = self.convertStringFrom(date: parsedOrderDate, format: "dd MMM yyyy, hh:mm a")
            cell.lblOrderId.text = "\(Language.ORDER_TIME) : \(convertedStartTime)"
            
            
            cell.lblCustName.text = "\(Language.NAME) : \(arrOrders[indexPath.row]["cust_name"]!)"
            cell.lblCustNo.text = "\(Language.PHONE_NO).: \(arrOrders[indexPath.row]["cust_no"]!)"
            if arrOrders[indexPath.row]["address"]! != "" {
                cell.lblAddress.text = "\(Language.ADDRESS): \(arrOrders[indexPath.row]["address"]!)"
            }else {
                cell.lblAddress.text = ""
            }
            
            cell.lblPrice.text = "\(Language.PRICE) : € \(arrOrders[indexPath.row]["price"]!)"
            
            if arrOrders[indexPath.row]["delivery_type"]! == "Later" {
                cell.lblDeliveryType.text = "\(Language.DELIVERY_TYPE) : \(arrOrders[indexPath.row]["order_drop_type"]!) (\(Language.LATER) : \(arrOrders[indexPath.row]["delivery_time"]!))"
            }else {
                if let deliveryTime = (arrOrders[indexPath.row])["delivery_time"], deliveryTime == ""{
                    cell.lblDeliveryType.text = "\(Language.DELIVERY_TYPE) : \(arrOrders[indexPath.row]["order_drop_type"]!) (\(Language.NOW))"
                }else{
                    cell.lblDeliveryType.text = "\(Language.DELIVERY_TYPE) : \(arrOrders[indexPath.row]["order_drop_type"]!) (\(Language.NOW) : \((arrOrders[indexPath.row])["delivery_time"]!))"
                }
            }
        }
        
        cell.btnEditTime.tag = indexPath.row
        cell.btnEditTime.addTarget(self, action: #selector(btnEditTime_Action(_:)), for: .touchDown)
        
        return cell
    }
    
    @objc func btnEditTime_Action(_ sender : UIButton){
        var arrTimes = [String]()
        var time = ""
        if arrOrders[sender.tag]["delivery_type"]! == Language.LATER {
            time = (self.arrOrders[sender.tag])["delivery_time"]!
        }else{
            
            let date = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            
            if let del_time = (self.arrOrders[sender.tag])["delivery_time"], del_time != "" {
                time = (self.arrOrders[sender.tag])["delivery_time"]!
            }else {
                time = dateFormatter.string(from: date)
            }
        }
            
        let timeFormat = DateFormatter()
        timeFormat.dateFormat = "HH:mm"

        var fromDate = timeFormat.date(from: time)
        fromDate = fromDate?.addingTimeInterval(2400)

        var dateByAddingThirtyMinute = fromDate
        for _ in 0..<12 {
            var formattedDateString: String?
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            if let dateByAddingThirtyMinute = dateByAddingThirtyMinute {
                formattedDateString = dateFormatter.string(from: dateByAddingThirtyMinute)
            }
            arrTimes.append(formattedDateString!)

            dateByAddingThirtyMinute = fromDate?.addingTimeInterval(300)
            fromDate = dateByAddingThirtyMinute
        }

        ActionSheetStringPicker.show(withTitle: Language.SELECT_TIME, rows : arrTimes , initialSelection: 0, doneBlock: {
            picker, value, index in
            if index != nil{
                self.callEditTime(time: "\(index!)", orderId: (self.arrOrders[sender.tag])["order_id"]!)
            }
            return
        }, cancel: { ActionStringCancelBlock in
            return

        }, origin: self.view)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "toDetail", sender: (arrOrders[indexPath.row])["order_id"]!)
    }
    
}
