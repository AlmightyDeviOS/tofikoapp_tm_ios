//
//  ItemDetailVC.swift
//  Restaurent Manager
//
//  Created by APPLE on 21/09/19.
//  Copyright © 2019 com.Coder2. All rights reserved.
//

import UIKit

class ItemDetailVC: Main {

    //MARK:- Outlets
    @IBOutlet var ivProduct: UIImageView!
 
    @IBOutlet var lblCatName: UILabel!
    @IBOutlet var lblProductName: UILabel!
    @IBOutlet var lblPrice: UILabel!

    @IBOutlet var tvDescription: UITextView!
    @IBOutlet var lblCusineType: UILabel!

    @IBOutlet weak var btnItemOnOff: UIButton!
    
    @IBOutlet weak var btnCust: CustomButton!
    @IBOutlet weak var lblHeader: UILabel!
    
    //MARK:- Global Variables
    var imagePicker = UIImagePickerController()
    var itemID = ""
    var dictItemDetail = [String:String]()
    
    //MARK:- View Life Cycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        lblHeader.text = Language.ITEM_DETAIL
        btnCust.setTitle(Language.SHOW_CUST, for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        callItemDetailAPI()
    }
    
    //MARK:- Other Methods
    func serServiceData() {
        lblProductName.text = dictItemDetail["name"]!
        lblCusineType.text = dictItemDetail["category"]!
        lblPrice.text = "€ \(dictItemDetail["price"]!)"
        
        let ingredient = Language.INGREDIENTS
        let Allergens = Language.ALLERGENS
        
        if dictItemDetail["ingredients"]! != "" && dictItemDetail["ingredients"]! != "<br>"{
            var description = "<font color='#646767' face='Raleway'><h2><b>\(ingredient) : </b></h2> \(dictItemDetail["ingredients"]!)"
            
            if dictItemDetail["allergens"]! != "" && dictItemDetail["allergens"]! != "<br>" {
                description = "\(description)<br><br><h2><b>\(Allergens) : </b></h2> \(dictItemDetail["allergens"]!)"
            }
            
            description = "\(description)</font>"
            tvDescription.attributedText = description.html2AttributedString!
        }else {
            tvDescription.text = ""
        }
        
        if dictItemDetail["image"]! != "" {
            ivProduct.kf.setImage(with: URL(string: dictItemDetail["image"]!.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlFragmentAllowed)!), placeholder: UIImage(named: "restaurant_placeholder"),     options: [.transition(.fade(1))], progressBlock: nil, completionHandler: nil)
        }
        
        if dictItemDetail["status"]! == "1" {
            btnItemOnOff.setImage(UIImage(named:"on"), for: .normal)
        }else {
            btnItemOnOff.setImage(UIImage(named:"off"), for: .normal)
        }
    }
    
    //MARK:- Button Actions
    @IBAction func btnBack_Action(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSwitch_Action(_ sender: UIButton) {
        if sender.currentImage == UIImage(named : "on"){
            sender.setImage(UIImage(named: "off"), for: .normal)
        }else{
            sender.setImage(UIImage(named: "on"), for: .normal)
        }
    }
    
    @IBAction func btnItemOnOff_Action(_ sender: UIButton) {
        if sender.currentImage == UIImage(named : "on"){
            callItemOnOffAPI(0)
        }else{
            callItemOnOffAPI(1)
        }
    }
    
    @IBAction func btnShowCustomization_Action(_ sender: CustomButton) {
        self.performSegue(withIdentifier: "segueToCustomization", sender: nil)
    }
    
    @IBAction func btnEditImage_Action(_ sender: Any) {
        let actionSheet = UIAlertController(title: Language.CHOOSE_OPTION, message: nil, preferredStyle: .actionSheet)
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        let action1 = UIAlertAction(title: Language.GALLERY, style: .default) { (action) in
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }
        let action2 = UIAlertAction(title: Language.CAMERA, style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePicker.sourceType = .camera
            } else {
                imagePicker.sourceType = .photoLibrary
            }
            self.present(imagePicker, animated: true, completion: nil)
        }
        let action3 = UIAlertAction(title: Language.CANCEL, style: .cancel, handler: nil)
        actionSheet.addAction(action1)
        actionSheet.addAction(action2)
        actionSheet.addAction(action3)
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    //MARK:- Webservices
    func callItemDetailAPI() {
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }
        
        let serviceURL = Constant.WEBURL + Constant.API.ITEM_DETAIL
        let params = "?res_id=\(UserModel.sharedInstance().user_id!)&auth_token=\(UserModel.sharedInstance().auth_token!)&item_id=\(itemID)"
        
        APIManager.shared.requestGETURL(serviceURL + params, success: { (response) in
            if let jsonObject = response.result.value as? [String:AnyObject] {
                if let status = jsonObject["status"] as? String{
                    if status == "0"{
                        print("Failed")
                        //CommonFunctions.shared.showToast(self.view, jsonObject["message"] as! String)
                    }else{
                        //CommonFunctions.shared.showToast(self.view, jsonObject["message"] as! String)
                        print(jsonObject)
                        
                        if let responseData = jsonObject["responsedata"] as? [String:String] {
                            print(responseData)
                            self.dictItemDetail = responseData
                            self.serServiceData()
                        }
                    }
                }
            }
            
        }) { (error) in
            print(error)
        }
    }
    
    func callItemOnOffAPI(_ itemStatus:Int) {
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }
        
        let serviceURL = Constant.WEBURL + Constant.API.CHANGE_ITEM_STATUS
        let params = "?res_id=\(UserModel.sharedInstance().user_id!)&auth_token=\(UserModel.sharedInstance().auth_token!)&status=\(itemStatus)&id=\(itemID)&type=item&lang_id=\(UserModel.sharedInstance().app_language!)"
        
        APIManager.shared.requestGETURL(serviceURL + params, success: { (response) in
            if let jsonObject = response.result.value as? [String:AnyObject] {
                if let status = jsonObject["status"] as? String {
                    if status == "0"{
                        print("Failed")
                        //CommonFunctions.shared.showToast(self.view, jsonObject["message"] as! String)
                    }else{
                        //CommonFunctions.shared.showToast(self.view, jsonObject["message"] as! String)
                        self.callItemDetailAPI()
                    }
                }
            }
            
        }) { (error) in
            print(error)
        }
    }
    
    func callItemImageChangeAPI() {
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }
        
        let img = self.ivProduct.image!
        let imageData = UIImageJPEGRepresentation(img, 1.0)
        let image = imageData!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        
        let serviceURL = Constant.WEBURL + Constant.API.CHANGE_ITEM_IMAGE
        let params = ["res_id": UserModel.sharedInstance().user_id!,
                      "auth_token": UserModel.sharedInstance().auth_token!,
                      "image": image,
                      "item_id": self.itemID,
                      "lang_id":UserModel.sharedInstance().app_language!
                     ]
        
        APIManager.shared.requestPostURL(serviceURL, param: params, success: { (response) in
            
            //Parsing method started to parse the data.
            if let jsonObject = response.result.value as? [String:AnyObject] {
                
                //Getting status of user login credentials. If status is 0 then fetching data otherwise it will show message of failure with reason.
                if let strStatus = jsonObject["status"] as? String {
                    if strStatus == "1" {
                        self.callItemDetailAPI()
                    }else {
                        self.showWarning(jsonObject["message"] as! String)
                    }
                }else {
                    self.showWarning(Language.WENT_WRONG)
                }
            }else {
                self.showWarning(Language.WENT_WRONG)
            }
            
        }) { (error) in
            print(error)
        }
    }
    
    //MARK:- Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToCustomization" {
            let destVC = segue.destination as! CustomizationListVC
            destVC.itemID = self.itemID
        }
    }
}

extension ItemDetailVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.allowsEditing = true
        self.dismiss(animated: true) {
            if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
                self.ivProduct.image = editedImage
                self.callItemImageChangeAPI()
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.isNavigationBarHidden = false
        self.dismiss(animated: true, completion: nil)
    }
}
