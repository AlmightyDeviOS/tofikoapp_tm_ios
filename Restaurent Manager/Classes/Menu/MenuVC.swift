//
//  MenuVC.swift
//  Restaurent Manager
//
//  Created by APPLE on 18/09/19.
//  Copyright © 2019 com.Coder2. All rights reserved.
//

import UIKit
import Kingfisher

class MenuCell : UITableViewCell{
    @IBOutlet weak var ivPic: CustomImageView!
    @IBOutlet weak var lblName: UILabel!
}

class MenuVC: Main {
    
    //MARK:- Outlets
    @IBOutlet weak var tblMenu: UITableView!
    @IBOutlet weak var lblHeader: UILabel!
    
    //MARK:- Global Variables
    var arrMenu = [[String:AnyObject]]()
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblMenu.tableFooterView = UIView()
        
        lblHeader.text = Language.MENU
        callMenuAPI()
        
    }
    
    //MARK:- Button Actions
    @IBAction func btnMenu_Action(_ sender: Any) {
        toggleSideMenuView()
        
    }
    
    //MARK:- Web Service Calling
    func callMenuAPI() {
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }
        
        let serviceURL = Constant.WEBURL + Constant.API.MENU_CATEGORY
        let params = "?res_id=\(UserModel.sharedInstance().user_id!)&auth_token=\(UserModel.sharedInstance().auth_token!)&lang_id=\(UserModel.sharedInstance().app_language!)"
        
        APIManager.shared.requestGETURL(serviceURL + params, success: { (response) in
            if let jsonObject = response.result.value as? [String:AnyObject] {
                if let status = jsonObject["status"] as? String{
                    if status == "0"{
                        print("Failed")
                        self.showError(jsonObject["message"] as! String)
                        
                    }else{
                        if let menu = (jsonObject["responsedata"] as? [[String:AnyObject]]) , menu.count > 0{
                            self.arrMenu = menu
                            self.tblMenu.reloadData()
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
        if segue.identifier == "toList" {
            let destVC = segue.destination as! ItemListVC
            destVC.categoryID = (arrMenu[sender as! Int])["id"] as! String
            destVC.total_count = (arrMenu[sender as! Int])["total_items"] as! String
        }
    }
}

extension MenuVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrMenu.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath) as! MenuCell
        
        if (arrMenu[indexPath.row])["image"] as! String == "" {
            cell.ivPic.image = UIImage(named: "noImage")
        }else {
            cell.ivPic.kf.setImage(with: URL(string: (arrMenu[indexPath.row])["image"] as! String), placeholder: UIImage(named: "noImage"), options: [.transition(.fade(1))], progressBlock: nil, completionHandler: nil)
        }
        cell.lblName.text = (arrMenu[indexPath.row])["name"] as? String
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "toList", sender: indexPath.row)
    }
}
