//
//  SettingsVC.swift


import UIKit

class LanguageCell : UITableViewCell{
    
    @IBOutlet weak var lblLangage: UILabel!
    @IBOutlet weak var ivMark: UIImageView!
}

//User can manage Push notification and make changes in own profile.
class SettingsVC: UIViewController {

    //MARK:- Outlets
    @IBOutlet var tblSettingHeightCons: NSLayoutConstraint!
    @IBOutlet var tblSetting: UITableView!

    @IBOutlet weak var tblLanguage: UITableView!
    @IBOutlet var vwLanguage: UIView!
    @IBOutlet weak var blurView: UIImageView!
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var lblSelectLang: UILabel!
    @IBOutlet weak var btnContinue: UIButton!
    @IBOutlet weak var lblVersion: UILabel!
    
    //MARK:- Global Variables
    var arrOption = [Language.PROFILE, Language.PUSH_NOTIFICATION, Language.TBL_BOOKING_SETTING, "Language", Language.SUPPORT ,Language.TERMS_CONDITIONS, Language.PRIVACY_POLICY, Language.COOKIE_POLICY]
    var currentIndexPath = IndexPath()
    
    var currentLanguageIndexPath = ""
    var arrDictLanguage = [[String:AnyObject]]()
    
    //MARK:- View Life Cycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        setLayout()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK:- Other Methods
    func setLayout(){
        
        self.vwLanguage.center = self.view.center
        self.view.addSubview(self.vwLanguage)
        self.blurView.isHidden = true
        self.vwLanguage.isHidden = true
        
        lblHeader.text = Language.SETTING
        lblSelectLang.text = Language.SELECT_LANGUAGE
        btnContinue.setTitle(Language.SUBMIT, for: .normal)
        
        let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        lblVersion.text = "\(Language.VERSION)\n\(appVersion)"
        
        callGetLanguageListAPI()
        
        tblSettingHeightCons.constant = tblSettingHeightCons.constant * CGFloat(arrOption.count)
        tblSetting.tableFooterView = UIView()
        tblLanguage.tableFooterView = UIView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.Language_Localization), name: Notification.Name("Language_Localization"), object: nil)
    }
    
    //MARK:- Selector Method
    @objc func Language_Localization() {
        lblHeader.text = Language.SETTING
        lblSelectLang.text = Language.SELECT_LANGUAGE
        btnContinue.setTitle(Language.SUBMIT, for: .normal)
        arrOption = [Language.PROFILE, Language.PUSH_NOTIFICATION, "Language", Language.SUPPORT ,Language.TERMS_CONDITIONS, Language.PRIVACY_POLICY, Language.COOKIE_POLICY]
        tblSetting.reloadData()
    }
    
    //MARK:- Button Action
    @IBAction func btnMenu_Action(_ sender: Any) {
        toggleSideMenuView()
    }
    
    @IBAction func btnCancelPopup_Action(_ sender: Any) {
        UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.blurView.isHidden = true
            self.vwLanguage.isHidden = true
        })
    }
    
    @IBAction func btnContinuePopup_Action(_ sender: Any) {
        let id = currentLanguageIndexPath
        callSetLanguageAPI(id)
        UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.blurView.isHidden = true
            self.vwLanguage.isHidden = true
        })
    }
    
    //MARK:- Navigation Bar Delegates Method
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueStatic" {
            let vc = segue.destination as! StaticPageVC
            if currentIndexPath.row == 4{
                vc.strPageType = "terms"
            }else if currentIndexPath.row == 5{
                vc.strPageType = "policy"
            }else if currentIndexPath.row == 6{
                vc.strPageType = "cookie"
            }
        }
    }
    
    //MARK:- WebServices
    func callGetLanguageListAPI() {
        
        //Checking for internet connection. If internet is not available then system will display toast message.
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }
        
        //Creating API request to fetch the data.
        let serviceURL = Constant.WEBURL + Constant.API.LANGUAGE_LIST
        let params = "?res_id=\(UserModel.sharedInstance().user_id!)&auth_token=\(UserModel.sharedInstance().auth_token!)&store_id=\(UserModel.sharedInstance().store_id!)&lang_id=\(UserModel.sharedInstance().app_language!)"
        
        //Starting process to fetch the data.
        APIManager.shared.requestGETURL(serviceURL + params, success: { (response) in
            
            //Parsing method started to parse the data.
            if let jsonObject = response.result.value as? [String:AnyObject] {
                
                //Getting status of API. If status is 0 then fetching data otherwise it will show message of failure with reason.
                if let status = jsonObject["status"] as? String{
                    if status == "0"{
                        print("Failed")
                       // CommonFunctions.shared.showToast(self.view, jsonObject["message"] as! String)
                    }else{
                        //CommonFunctions.shared.showToast(self.view, jsonObject["message"] as! String)
                        print(jsonObject)
                        if let responseData = jsonObject["responsedata"] as? [[String:AnyObject]] {
                            self.arrDictLanguage = responseData
                            self.tblLanguage.reloadData()
                            
                            if UserModel.sharedInstance().app_language != nil{
                                self.currentLanguageIndexPath = (self.arrDictLanguage.filter{$0["id"] as! String == UserModel.sharedInstance().app_language!}[0])["id"] as! String
                            }
                            
                        }
                    }
                }
            }
            
        }) { (error) in
            print(error)
        }
    }
    
    func callSetLanguageAPI(_ id : String) {
        
        //Checking for internet connection. If internet is not available then system will display toast message.
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }
        
        //Creating API request to fetch the data.
        let serviceURL = Constant.WEBURL + Constant.API.SET_LANGUAGE
        let params = "?res_id=\(UserModel.sharedInstance().user_id!)&auth_token=\(UserModel.sharedInstance().auth_token!)&lang_id=\(id)&store_id=\(UserModel.sharedInstance().store_id!)"
        
        //Starting process to fetch the data.
        APIManager.shared.requestGETURL(serviceURL + params, success: { (response) in
            
            //Parsing method started to parse the data.
            if let jsonObject = response.result.value as? [String:AnyObject] {
                
                //Getting status of API. If status is 0 then fetching data otherwise it will show message of failure with reason.
                if let status = jsonObject["status"] as? String{
                    if status == "0"{
                        print("Failed")
                        //CommonFunctions.shared.showToast(self.view, jsonObject["message"] as! String)
                    }else{
                        //CommonFunctions.shared.showToast(self.view, jsonObject["message"] as! String)
                        print(jsonObject)
                        UserModel.sharedInstance().app_language = id
                        UserModel.sharedInstance().synchroniseData()
                        (UIApplication.shared.delegate as! AppDelegate).call_Get_Language()
                    }
                }
            }
        }) { (error) in
            print(error)
        }
    }
}

extension SettingsVC : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == tblSetting{
            return arrOption.count
        }else{
            return arrDictLanguage.count
        }

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if tableView == tblSetting{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath)
            
            cell.textLabel?.text = arrOption[indexPath.row].capitalizingFirstLetter()
            cell.accessoryType = .disclosureIndicator
            cell.textLabel?.textColor = UIColor(red: 75/255, green: 78/255, blue: 78/255, alpha: 1.0)
            cell.selectionStyle = .none
            
            cell.textLabel?.font = UIFont(name: "Raleway-Regular", size: 15.0)
            
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "LanguageCell", for: indexPath) as! LanguageCell
            
            cell.lblLangage.text = (arrDictLanguage[indexPath.row])["full_name"] as? String
            
            cell.lblLangage.font = UIFont(name: "Raleway-Regular", size: 15.0)
            
            if currentLanguageIndexPath == (arrDictLanguage[indexPath.row])["id"] as! String{
                cell.ivMark.image = UIImage(named: "checked")
            }else{
                cell.ivMark.image = UIImage(named: "unchecked")
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if tableView == tblSetting{
            currentIndexPath = indexPath
            
            if indexPath.row == 0{
                self.performSegue(withIdentifier: "segueToProfile", sender: nil)
            }else if indexPath.row == 1{
                self.performSegue(withIdentifier: "toNotification", sender: nil)
            }else if indexPath.row == 2{
                self.performSegue(withIdentifier: "toTableBooking", sender: nil)
            }else if indexPath.row == 3{
                UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {
                    self.blurView.isHidden = false
                    self.vwLanguage.isHidden = false
                })
            }else if indexPath.row == 4{
                self.performSegue(withIdentifier: "segueToSupport", sender: nil)
            }else if indexPath.row == 5{
                self.performSegue(withIdentifier: "segueStatic", sender: nil)
            }else if indexPath.row == 6{
                self.performSegue(withIdentifier: "segueStatic", sender: nil)
            }else if indexPath.row == 7 {
                self.performSegue(withIdentifier: "segueStatic", sender: nil)
            }else if indexPath.row == 8 {
                self.performSegue(withIdentifier: "segueStatic", sender: nil)
            }
        }else{
            currentLanguageIndexPath = (arrDictLanguage[indexPath.row])["id"] as! String
            self.tblLanguage.reloadData()
        }        
    }
}
