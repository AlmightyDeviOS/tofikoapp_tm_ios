//
//  StaticPageVC.swift


import UIKit


class StaticPageVC: UIViewController {

    //MARK:- Outlets
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var tvContent: UITextView!
    
    //MARK:- Global Variables
    var strPageType = ""
    
    //MARK:- View Life Cycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        callStaticPageAPI()
        if strPageType == "terms" {
            self.lblTitle.text = Language.TERMS_CONDITIONS
        }else if strPageType == "policy" {
            self.lblTitle.text = Language.PRIVACY_POLICY
        }else if strPageType == "cookie" {
            self.lblTitle.text = Language.COOKIE_POLICY
        }
    }
    
    //MARK:- Button Action
    @IBAction func btnBack_Action(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK:- Webservices
    func callStaticPageAPI() {
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }
        
        let serviceURL = Constant.WEBURL + Constant.API.STATIC_PAGE
        let params = "?type=\(strPageType)&lang_id=\(UserModel.sharedInstance().app_language!)"
        
        APIManager.shared.requestGETURL(serviceURL + params, success: { (response) in
            if let jsonObject = response.result.value as? [String:AnyObject] {
                if let status = jsonObject["status"] as? String{
                    if status == "0"{
                        print("Failed")
                    }else{
                        print(jsonObject)
                        if let responseData = jsonObject["responsedata"] as? [String:AnyObject] {
                            self.tvContent.attributedText = (responseData["content"] as! String).html2AttributedString
                        }
                    }
                }
            }
            
        }) { (error) in
            print(error)
        }
    }
}
