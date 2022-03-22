//
//  CustomizationListVC.swift
//  Restaurent Manager
//
//  Created by APPLE on 22/09/19.
//  Copyright © 2019 com.Coder2. All rights reserved.
//

import UIKit

class CustomizationCell : UITableViewCell{
    
    @IBOutlet weak var vwBack: CustomUIView!
    @IBOutlet weak var lblCustomizationName: UILabel!
    
    @IBOutlet weak var lblPrice: UILabel!
}

class CustomizationListVC: Main {
    
    //MARK:- Outlets
    @IBOutlet weak var tblCustomizationList: UITableView!
    
    @IBOutlet weak var btnFree: CustomButton!
    @IBOutlet weak var btnPaid: CustomButton!
    
    @IBOutlet weak var consBtnHeight: NSLayoutConstraint!
    @IBOutlet weak var lblFree: UILabel!
    @IBOutlet weak var lblPaid: UILabel!
    @IBOutlet weak var lblNoDataFnd: UILabel!
    @IBOutlet weak var lblHeader: UILabel!
    
    //MARK:- Global Variables
    var itemID = ""
    var isSelected = 0
    var arrFreeCustomization = [[String:String]]()
    var arrPaidCustomization = [[String:String]]()
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnFree.setTitle(Language.FREE, for: .normal)
        btnPaid.setTitle(Language.PAID, for: .normal)
        
        lblHeader.text = Language.CUSTOMIZATION
        lblNoDataFnd.text = Language.ORDER_NOT_FOUND
    }
    
    override func viewWillAppear(_ animated: Bool) {
        callCustomizationListAPI()
    }
    
    //MARK:- Button Actions
    @IBAction func btnBack_Action(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnFree_Action(_ sender: CustomButton) {
        lblFree.isHidden = false
        lblPaid.isHidden = true
        isSelected = 0
        tblCustomizationList.reloadData()
    }
    
    @IBAction func btnPaid_Action(_ sender: CustomButton) {
        lblFree.isHidden = true
        lblPaid.isHidden = false
        isSelected = 1
        tblCustomizationList.reloadData()
    }
    
    //MARK:- Webservices
    func callCustomizationListAPI() {
        
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }
        
        let serviceURL = Constant.WEBURL + Constant.API.CUSTOMIZATION_LIST
        let params = "?res_id=\(UserModel.sharedInstance().user_id!)&auth_token=\(UserModel.sharedInstance().auth_token!)&item_id=\(itemID)"
        
        APIManager.shared.requestGETURL(serviceURL + params, success: { (response) in
            if let jsonObject = response.result.value as? [String:AnyObject] {
                if let status = jsonObject["status"] as? String{
                    if status == "0"{
                        print("Failed")
                        
                        self.consBtnHeight.constant = 0
                        self.tblCustomizationList.isHidden = true
                        self.lblNoDataFnd.isHidden = false
                        self.lblNoDataFnd.text = jsonObject["message"] as? String
                        
                        //CommonFunctions.shared.showToast(self.view, jsonObject["message"] as! String)
                        
                    }else{
                        self.consBtnHeight.constant = 40
                        self.tblCustomizationList.isHidden = false
                        self.lblNoDataFnd.isHidden = true
                        
                        //CommonFunctions.shared.showToast(self.view, jsonObject["message"] as! String)
                        print(jsonObject)
                        
                        if let responseData = jsonObject["responsedata"] as? [String:AnyObject] {
                            print(responseData)
                            if let paidCustomization = responseData["paid_cust"] as? [[String:String]] {
                                self.arrPaidCustomization = paidCustomization
                            }
                            
                            if let freeCustomization = responseData["free_cust"] as? [[String:String]] {
                                self.arrFreeCustomization = freeCustomization
                            }
                            
                            self.tblCustomizationList.reloadData()
                        }
                    }
                }
            }
            
        }) { (error) in
            print(error)
        }
    }
}

extension CustomizationListVC : UITableViewDataSource,UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSelected == 0 {
            return arrFreeCustomization.count
        }else {
            return arrPaidCustomization.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomizationCell", for: indexPath) as! CustomizationCell
        
        if isSelected == 0{
            cell.lblPrice.text = ""
            
            cell.lblCustomizationName.text = arrFreeCustomization[indexPath.row]["name"]!.html2String
            
        }else{
            
            if let price = arrPaidCustomization[indexPath.row]["price"] as? String{
                cell.lblPrice.text = "€ \(price)"
            }else{
                cell.lblPrice.text = ""
            }
            
            cell.lblCustomizationName.text = arrPaidCustomization[indexPath.row]["name"]!.html2String
        }
        
        DispatchQueue.main.async {
            let shadowPath = UIBezierPath(rect: cell.vwBack.bounds)
            cell.vwBack.layer.masksToBounds = false
            cell.vwBack.layer.shadowColor = UIColor.lightGray.cgColor
            cell.vwBack.layer.shadowOffset = CGSize(width: -1, height: 2.0)
            cell.vwBack.layer.shadowOpacity = 0.8
            cell.vwBack.layer.shadowPath = shadowPath.cgPath
            cell.vwBack.layer.cornerRadius = 8.0
        }
        
        
        
        return cell
    }
}
