//
//  SideMenuVC.swift

import UIKit
import Kingfisher

//UITableViewCell for side menu items
class SideMenuOption : UITableViewCell {
    @IBOutlet weak var lblTitleCell: UILabel!
    @IBOutlet weak var ivCell: UIImageView!
}

//Class for side menu.
class SideMenuVC : UIViewController {
    
    //MARK:- Outlets
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var ivUserImage: UIImageView!
    @IBOutlet weak var tblVeiwSideMenu: UITableView!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    
    //MARK:- Global Variables
    var arrOptions = [String]()
    var arrImg = ["dashboard", "categories", "order_history", "barcode" ,"schedule", "review", "setting", "logout"]
    
    //MARK:- View LifeCycle Method
    override func viewDidLoad(){
        super.viewDidLoad()
        
        arrOptions = [Language.DASHBOARD.capitalizingFirstLetter(), Language.MENU.capitalizingFirstLetter(), Language.ORDER_HISTORY.capitalizingFirstLetter(), Language.SCAN_BARCODE.capitalizingFirstLetter(), Language.SCHEDULE.capitalizingFirstLetter(), Language.REVIEW.capitalizingFirstLetter(), Language.SETTING.capitalizingFirstLetter(), Language.LOGOUT.capitalizingFirstLetter()]
        NotificationCenter.default.addObserver(self, selector: #selector(self.Language_Localization), name: Notification.Name("Language_Localization"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setLayout()
    }
    
    @objc func Language_Localization() {
        arrOptions = [Language.DASHBOARD.capitalizingFirstLetter(), Language.MENU.capitalizingFirstLetter(), Language.ORDER_HISTORY.capitalizingFirstLetter(), Language.SCAN_BARCODE.capitalizingFirstLetter(), Language.SCHEDULE.capitalizingFirstLetter(), Language.REVIEW.capitalizingFirstLetter(), Language.SETTING.capitalizingFirstLetter(), Language.LOGOUT.capitalizingFirstLetter()]
        tblVeiwSideMenu.reloadData()
        
        setLayout()
    }
   
    //MAKR:- Other Methods
    //Used to redirect to main page. Once user presses logout.
    func ChangeMainRoot() {
        let homeSB = UIStoryboard(name: "Main", bundle: nil)
        let desiredViewController = homeSB.instantiateViewController(withIdentifier: "MainNavigation") as! UINavigationController
        let appdel = UIApplication.shared.delegate as! AppDelegate
        let snapshot:UIView = (appdel.window?.snapshotView(afterScreenUpdates: true))!
        desiredViewController.view.addSubview(snapshot)
        appdel.window?.rootViewController = desiredViewController;
        
        UIView.animate(withDuration: 0.3, animations: {() in
            snapshot.layer.opacity = 0;
            snapshot.layer.transform = CATransform3DMakeScale(1.5, 1.5, 1.5);
        }, completion: {
            (value: Bool) in
            snapshot.removeFromSuperview();
        });
    }
    
    //Use to set the layout common things when first time screen loaded.
    func setLayout(){
        self.tblVeiwSideMenu.delegate = self
        self.tblVeiwSideMenu.dataSource = self
        self.tblVeiwSideMenu.tableFooterView = UIView()
        
        if UserModel.sharedInstance().name != nil && UserModel.sharedInstance().name != "" {
            lblName.text = UserModel.sharedInstance().name!
        }
        
        if UserModel.sharedInstance().email != nil && UserModel.sharedInstance().email != "" {
            lblEmail.text = UserModel.sharedInstance().email!
        }
        
        var address = ""
        /*if UserModel.sharedInstance().building_no != nil && UserModel.sharedInstance().building_no != "" {
            address = UserModel.sharedInstance().building_no!
        }*/
        
        if UserModel.sharedInstance().street != nil && UserModel.sharedInstance().street != "" {
            if address != "" {
                address = "\(address), \(UserModel.sharedInstance().street!)"
            }else {
                address = UserModel.sharedInstance().street!
            }
        }
        
        if UserModel.sharedInstance().city != nil && UserModel.sharedInstance().city != "" {
            if address != "" {
                address = "\(address), \(UserModel.sharedInstance().city!)"
            }else {
                address = UserModel.sharedInstance().city!
            }
        }
        
        if UserModel.sharedInstance().province != nil && UserModel.sharedInstance().province != "" {
            if address != "" {
                address = "\(address), \(UserModel.sharedInstance().province!)"
            }else {
                address = UserModel.sharedInstance().province!
            }
        }
        
        if UserModel.sharedInstance().country != nil && UserModel.sharedInstance().country != "" {
            if address != "" {
                address = "\(address), \(UserModel.sharedInstance().country!)"
            }else {
                address = UserModel.sharedInstance().country!
            }
        }
        
        lblAddress.text = address.html2String
        
        if UserModel.sharedInstance().profile_image != nil && UserModel.sharedInstance().profile_image != "" {
            let img = UserModel.sharedInstance().profile_image?.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)
            ivUserImage.kf.setImage(with: URL(string: img!), placeholder: UIImage(named: ""), options: [.transition(.fade(1))], progressBlock: nil, completionHandler: nil)
        }
        
    }
    
    //MARK:- WebService Calling
    func callLogOut() {
        
        //Checking for internet connection. If internet is not available then system will display toast message.
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }
        
        //Creating API request to fetch the data.
        let serviceURL = Constant.WEBURL + Constant.API.LOG_OUT
        let params = "?res_id=\(UserModel.sharedInstance().user_id!)&auth_token=\(UserModel.sharedInstance().auth_token!)&store_id=\(UserModel.sharedInstance().store_id!)&device_token=\(UserModel.sharedInstance().deviceToken!)&lang_id=\(UserModel.sharedInstance().app_language!)"
        
        //Starting process to fetch the data.
        APIManager.shared.requestGETURL(serviceURL + params, success: { (response) in
            
            //Parsing method started to parse the data.
            if let jsonObject = response.result.value as? [String:AnyObject] {
                
                //Getting status of API. If status is 0 then fetching data otherwise it will show message of failure with reason.
                if let status = jsonObject["status"] as? String {
                    //CommonFunctions.shared.showToast(self.view, jsonObject["message"] as! String)
                    if status == "0" {
                        print("Logout Failed")
                        let email = UserModel.sharedInstance().email!
                        let pass = UserModel.sharedInstance().password
                        let lang = UserModel.sharedInstance().app_language
                        let token = UserModel.sharedInstance().deviceToken
                        UserModel.sharedInstance().removeData()
                        UserModel.sharedInstance().synchroniseData()
                        UserModel.sharedInstance().email = email
                        UserModel.sharedInstance().password = pass
                        UserModel.sharedInstance().app_language = lang
                        UserModel.sharedInstance().deviceToken = token
                        UserModel.sharedInstance().synchroniseData()
                        self.ChangeMainRoot()
                    }else {
                        print("Logout success")
                        let email = UserModel.sharedInstance().email!
                        let pass = UserModel.sharedInstance().password
                        let lang = UserModel.sharedInstance().app_language
                        let token = UserModel.sharedInstance().deviceToken
                        UserModel.sharedInstance().removeData()
                        UserModel.sharedInstance().synchroniseData()
                        UserModel.sharedInstance().email = email
                        UserModel.sharedInstance().password = pass
                        UserModel.sharedInstance().app_language = lang
                        UserModel.sharedInstance().deviceToken = token
                        UserModel.sharedInstance().synchroniseData()
                        self.ChangeMainRoot()
                    }
                }
            }
            
        }) { (error) in
            print(error)
        }
    }
}

extension SideMenuVC : UITableViewDelegate,UITableViewDataSource{
    
    //Datasource method. Used to provide number of items for side menu options.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return arrOptions.count
    }
    
    //Datasource method. Used to provide each cell items text and images for side menu options.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuOption", for: indexPath ) as! SideMenuOption
        cell.lblTitleCell.text = arrOptions[indexPath.row]
        cell.ivCell.image = UIImage(named: arrImg[indexPath.row])
        //self.tblMenuHeight.constant = tableView.contentSize.height
        return cell
    }
    
    //Delegate Method. Automatically executed when user select any item from side menu options.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let next1 = self.storyboard?.instantiateViewController(withIdentifier: "DashboardBookingVC") as? DashboardBookingVC
            sideMenuController()?.setContentViewController(next1!)
            break
        case 1:
            let next1 = self.storyboard?.instantiateViewController(withIdentifier: "MenuVC") as? MenuVC
            sideMenuController()?.setContentViewController(next1!)
            return
        case 2:
            let next1 = self.storyboard?.instantiateViewController(withIdentifier: "OrderHistoryVC") as? OrderHistoryVC
            sideMenuController()?.setContentViewController(next1!)
            return
        case 3:
            let next1 = self.storyboard?.instantiateViewController(withIdentifier: "ScanBarcodeVC") as? ScanBarcodeVC
            sideMenuController()?.setContentViewController(next1!)
            return
        case 4:
            let next1 = self.storyboard?.instantiateViewController(withIdentifier: "ScheduleVC") as? ScheduleVC
            sideMenuController()?.setContentViewController(next1!)
            return
        case 5:
            let next1 = self.storyboard?.instantiateViewController(withIdentifier: "ReviewVC") as? ReviewVC
            sideMenuController()?.setContentViewController(next1!)
            break
        case 6:
            let next1 = self.storyboard?.instantiateViewController(withIdentifier: "SettingsVC") as? SettingsVC
            sideMenuController()?.setContentViewController(next1!)
            break
        case 7:
            //Redirecting to main page. Local model data will be flushed.
            self.callLogOut()
            break
       
        default:
            break
        }
    }
}
