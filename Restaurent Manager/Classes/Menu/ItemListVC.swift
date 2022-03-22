//
//  ItemListVC.swift
//  Restaurent Manager
//
//  Created by APPLE on 19/09/19.
//  Copyright © 2019 com.Coder2. All rights reserved.
//

import UIKit

class ItemListCell : UITableViewCell{
    
    @IBOutlet weak var consIvHeight: NSLayoutConstraint!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var ivPic: UIImageView!
    @IBOutlet weak var swt: UIButton!
    @IBOutlet weak var vwBack: CustomUIView!
}

class ItemListVC: Main {
    
    //MARK:- Outlets
    @IBOutlet weak var tblItem: UITableView!
    @IBOutlet weak var lblCategoryName: UILabel!
    @IBOutlet weak var lblItemCnt: UILabel!
    @IBOutlet weak var btnEnableDisableItems: UIButton!
    @IBOutlet weak var lblHeadernt: UILabel!
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var lblEna_Dis: UILabel!
    
    //MARK:- Global Variables
    var categoryID = ""
    var arrItems = [[String:String]]()
    var allItemsStatus = 0
    var total_count = ""
        
    //Pagination Variables
    var pageNumber = 0
    var isNewDataLoading = true
    var totalCount = 10
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        lblHeader.text = Language.PRODUCT_LIST
        lblEna_Dis.text = Language.ALL_ENABLE_DISABLE
        super.viewDidLoad()
        callItemListAPI()
        //self.tblItem.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.new, context: nil)
        let item = Language.PRODUCT_LIST
        if Int(total_count)! > 1{
            self.lblHeadernt.text = "\(total_count) \(item)"
        }else{
            self.lblHeadernt.text = "\(total_count) \(item)"
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
//    
//    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        tblItem.layer.removeAllAnimations()
//        tblHeight.constant = tblItem.contentSize.height
//        self.updateViewConstraints()
//        self.view.layoutIfNeeded()
//    }
//    
    //MARK:- Button Actions
    @IBAction func btnBack_Action(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnEnableDisableItems_Action(_ sender: UIButton) {
        if sender.currentImage == UIImage(named : "on"){
            callItemOnOffAPI(0, self.categoryID, "category")
        }else{
            callItemOnOffAPI(1, self.categoryID, "category")
        }
    }
    
    //MARK:- Other Functions
    
    @objc func swt_Action(_ sender : UIButton){
        print(sender.tag)
        if sender.currentImage == UIImage(named : "on"){
            callItemOnOffAPI(0, "\(sender.tag)", "item")
        }else{
            callItemOnOffAPI(1, "\(sender.tag)", "item")
        }
    }
    
    //MARK:- Webservices
    func callItemListAPI() {
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }
        
        let serviceURL = Constant.WEBURL + Constant.API.ITEM_LIST
        let params = "?res_id=\(UserModel.sharedInstance().user_id!)&auth_token=\(UserModel.sharedInstance().auth_token!)&category_id=\(categoryID)&start=\(pageNumber)&lang_id=\(UserModel.sharedInstance().app_language!)"
        
        APIManager.shared.requestGETURL(serviceURL + params, success: { (response) in
            if let jsonObject = response.result.value as? [String:AnyObject] {
                if let status = jsonObject["status"] as? String{
                    if status == "0"{
                        print("Failed")
                        self.isNewDataLoading = true
                        self.tblItem.tableFooterView = UIView()
                        //CommonFunctions.shared.showToast(self.view, jsonObject["message"] as! String)
                    }else{
                       // CommonFunctions.shared.showToast(self.view, jsonObject["message"] as! String)
                        
                        if let responseData = jsonObject["responsedata"] as? [String:AnyObject] {
                            
                            if responseData["items_status"] as! String == "1" {
                                DispatchQueue.main.async {
                                    self.allItemsStatus = 1
                                    self.btnEnableDisableItems.setImage(UIImage(named:"on"), for: .normal)
                                }
                            }else {
                                DispatchQueue.main.async {
                                    self.allItemsStatus = 0
                                    self.btnEnableDisableItems.setImage(UIImage(named:"off"), for: .normal)
                                }
                            }
                            
                            self.lblCategoryName.text = responseData["cat_name"] as? String
                            
                            if let arrTempItems = responseData["items"] as? [[String:String]] {
                                if arrTempItems.count == 0{
                                    self.isNewDataLoading = true
                                }else{
                                    for i in 0..<arrTempItems.count{
                                        self.arrItems.append(arrTempItems[i])
                                        
                                    }
                                    self.tblItem.reloadData()
                                    self.isNewDataLoading = false
                                }
                            }
                            self.tblItem.tableFooterView = UIView()
                        }
                    }
                }
            }
            
        }) { (error) in
            print(error)
        }
    }
    
    func callItemOnOffAPI(_ itemStatus:Int, _ index: String, _ type:String) {
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }
        
        //http://zaur.it/restaurantapp/webservices/manager/change_item_status.php?res_id=7&auth_token=GEkwfkd5LTMLTs40&status=1&id=7&type=item
        
        let pos = Int(index)!
        let serviceURL = Constant.WEBURL + Constant.API.CHANGE_ITEM_STATUS
        var params = ""
        if type == "category" {
            params = "?res_id=\(UserModel.sharedInstance().user_id!)&auth_token=\(UserModel.sharedInstance().auth_token!)&status=\(itemStatus)&id=\(categoryID)&type=\(type)&lang_id=\(UserModel.sharedInstance().app_language!)"
        }else {
            params = "?res_id=\(UserModel.sharedInstance().user_id!)&auth_token=\(UserModel.sharedInstance().auth_token!)&status=\(itemStatus)&id=\(arrItems[pos]["id"]!)&type=\(type)&lang_id=\(UserModel.sharedInstance().app_language!)"
        }
        
        APIManager.shared.requestGETURL(serviceURL + params, success: { (response) in
            if let jsonObject = response.result.value as? [String:AnyObject] {
                if let status = jsonObject["status"] as? String {
                    if status == "0"{
                        print("Failed")
                        //CommonFunctions.shared.showToast(self.view, jsonObject["message"] as! String)
                    }else{
                        //CommonFunctions.shared.showToast(self.view, jsonObject["message"] as! String)
                        if type == "item" {
                            let cell = self.tblItem.cellForRow(at: IndexPath(row: pos, section: 0)) as? ItemListCell
                            if self.arrItems[pos]["status"]! == "1" {
                                self.arrItems[pos]["status"] = "0"
                                cell?.swt.setImage(UIImage(named:"off"), for: .normal)
                            }else {
                                self.arrItems[pos]["status"] = "1"
                                cell?.swt.setImage(UIImage(named:"on"), for: .normal)
                            }
                        }else {
                            DispatchQueue.main.async {
                                if itemStatus == 1 {
                                    self.allItemsStatus = 1
                                    self.btnEnableDisableItems.setImage(UIImage(named:"on"), for: .normal)
                                }else {
                                    self.allItemsStatus = 0
                                    self.btnEnableDisableItems.setImage(UIImage(named:"off"), for: .normal)
                                }
                                self.pageNumber = 0
                                self.arrItems.removeAll()
                                self.callItemListAPI()
                                self.view.layoutIfNeeded()
                            }
                        }
                    }
                }
            }
            
        }) { (error) in
            print(error)
        }
    }
    
    //MARK:- Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToItemDetail" {
            let destVC = segue.destination as! ItemDetailVC
            destVC.itemID = sender as! String
        }
    }
}

extension ItemListVC : UITableViewDataSource,UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if arrItems.count > 0{
            return arrItems.count
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemListCell", for: indexPath) as! ItemListCell
       
        let dict = arrItems[indexPath.row]
        
        if dict["image_enable"] == "1" {
            if dict["image"] != ""{
                cell.consIvHeight.constant = 200
                cell.ivPic.kf.setImage(with: URL(string: dict["image"]!.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlFragmentAllowed)!), placeholder: UIImage(named: ""), options: [.transition(.fade(1))], progressBlock: nil, completionHandler: nil)
            }else{
                cell.consIvHeight.constant = 0
            }
        }else{
            cell.consIvHeight.constant = 0
        }
        
        self.view.layoutIfNeeded()
         
        cell.lblName.text = dict["name"]!
        cell.lblPrice.text = "€ \(dict["price"]!)"
        let ingredients = dict["ingredients"]!
        
        if ingredients != "" && ingredients != "<br>" {
            cell.lblDescription.text = "\(Language.INGREDIENTS) : \(ingredients.html2String)"
        }else {
            cell.lblDescription.text = ""
        }
        
        if dict["status"]! == "1" {
            cell.swt.setImage(UIImage(named:"on"), for: .normal)
        }else {
            cell.swt.setImage(UIImage(named:"off"), for: .normal)
        }
        
        cell.swt.tag = indexPath.row
        cell.swt.isUserInteractionEnabled = true
        cell.swt.addTarget(self, action: #selector(swt_Action(_:)), for: .touchDown)
        
        DispatchQueue.main.async {
            let shadowPath = UIBezierPath(rect: cell.vwBack.bounds)
            cell.vwBack.layer.masksToBounds = false
            cell.vwBack.layer.shadowColor = UIColor.lightGray.cgColor
            cell.vwBack.layer.shadowOffset = CGSize(width: -1, height: 2.0)
            cell.vwBack.layer.shadowOpacity = 0.8
            cell.vwBack.layer.shadowPath = shadowPath.cgPath
            cell.vwBack.layer.cornerRadius = 8.0
        }
       // self.tblItem.reloadData()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "segueToItemDetail", sender: arrItems[indexPath.row]["id"])
    }
}
extension ItemListVC: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height) {
            if !isNewDataLoading{
                pageNumber += totalCount
                print("pagenumber : \(pageNumber)")
                isNewDataLoading = true
                self.callItemListAPI()
                
                let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
                spinner.startAnimating()
                spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: self.tblItem.bounds.width, height: CGFloat(44))
                
                self.tblItem.tableFooterView = spinner
                self.tblItem.tableFooterView?.isHidden = false
            }
        }else{
            print("Scroll Error")
        }
        //}
    }
}
