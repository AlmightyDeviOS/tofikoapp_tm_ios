//
//  EditProfileVC.swift
//  Restaurent Manager
//
//  Created by APPLE on 22/09/19.
//  Copyright © 2019 com.Coder2. All rights reserved.
//

import UIKit
import Kingfisher
import GooglePlaces

class EditProfileVC: Main {
    
    //MARK:- Outlets
    @IBOutlet weak var txtRestaurantName: CustomTextField!
    @IBOutlet weak var txtStreetName: CustomTextField!
    @IBOutlet weak var txtBuildingNo: CustomTextField!
    @IBOutlet weak var txtZipcode: CustomTextField!
    @IBOutlet weak var txtProvince: CustomTextField!
    @IBOutlet weak var txtCountry: CustomTextField!
    @IBOutlet weak var txtWebsiteURL: CustomTextField!
    @IBOutlet weak var txtEmail: CustomTextField!
    
    @IBOutlet weak var btnChangePass: CustomButton!
    @IBOutlet weak var lblHeader: UILabel!
    
    //MARK:- Global Variables
    var latitude = Double()
    var longitude = Double()
    var geocoder = CLGeocoder()
    var dictAddress = [String:AnyObject]()
    
    //MARK:- View life cycle method
    override func viewDidLoad() {
        super.viewDidLoad()
        setLayout()
    }
    
    //MARK:- Other Methods
    func setLayout() {
        lblHeader.text = Language.PROFILE
        btnChangePass.setTitle(Language.CHANGE_PASS, for: .normal)
        txtStreetName.text = Language.STREET
        txtZipcode.text = Language.ZIPCODE
        txtCountry.text = Language.COUNTRY
        txtEmail.text = Language.EMAIL_ADDRESS
        
        if UserModel.sharedInstance().name != nil && UserModel.sharedInstance().name != "" {
            txtRestaurantName.text = UserModel.sharedInstance().name!
        }
        
        if UserModel.sharedInstance().street != nil && UserModel.sharedInstance().street != "" {
            txtStreetName.text = UserModel.sharedInstance().street!
        }
        
        if UserModel.sharedInstance().building_no != nil && UserModel.sharedInstance().building_no != "" {
            txtBuildingNo.text = UserModel.sharedInstance().building_no!
        }
        
        if UserModel.sharedInstance().zip_code != nil && UserModel.sharedInstance().zip_code != "" {
            txtZipcode.text = UserModel.sharedInstance().zip_code!
        }
        
        if UserModel.sharedInstance().province != nil && UserModel.sharedInstance().province != "" {
            txtProvince.text = UserModel.sharedInstance().province!
        }
        
        if UserModel.sharedInstance().country != nil && UserModel.sharedInstance().country != "" {
            txtCountry.text = UserModel.sharedInstance().country!
        }
        
        if UserModel.sharedInstance().website != nil && UserModel.sharedInstance().website != "" {
            txtWebsiteURL.text = UserModel.sharedInstance().website!
        }
        
        if UserModel.sharedInstance().email != nil && UserModel.sharedInstance().email != "" {
            txtEmail.text = UserModel.sharedInstance().email!
        }
    }
    
    //MARK:- Button Actions
    //Redirecting to back screen where user came in this screen.
    @IBAction func btnBack_Action(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnChangePassword_Action(_ sender: CustomButton) {
        self.performSegue(withIdentifier: "segueToChangePassword", sender: nil)
    }
    
    @IBAction func btnSave_Action(_ sender: Any) {
        if checkValidation() {
            self.callEditProfileAPI()
        }
    }
    
    //MARK:- Other Methods
    func checkValidation() -> Bool {
        if txtRestaurantName.text!.isEmpty {
            self.showWarning("Please enter store name")
            self.txtRestaurantName.becomeFirstResponder()
            return false
            
        }else if txtStreetName.text!.isEmpty {
            self.showWarning("Please enter street name")
            self.txtStreetName.becomeFirstResponder()
            return false
            
        }else if txtBuildingNo.text!.isEmpty {
            self.showWarning("Please enter street name 2")
            self.txtBuildingNo.becomeFirstResponder()
            return false
            
        }else if txtZipcode.text!.isEmpty {
            self.showWarning("Please enter zipcode")
            self.txtZipcode.becomeFirstResponder()
            return false
            
        }else if txtProvince.text!.isEmpty {
            self.showWarning("Please enter province name")
            self.txtProvince.becomeFirstResponder()
            return false
            
        }else if txtCountry.text!.isEmpty {
            self.showWarning("Please enter country name")
            self.txtCountry.becomeFirstResponder()
            return false
            
        }else if txtWebsiteURL.text!.isEmpty {
            self.showWarning("Please enter website URL")
            self.txtWebsiteURL.becomeFirstResponder()
            return false
            
        }else {
            return true
        }
    }
    
    //MARK:- Webservices
    func callEditProfileAPI() {
        
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }
        
        let serviceURL = Constant.WEBURL + Constant.API.EDIT_PROFILE
        let params = "?res_id=\(UserModel.sharedInstance().user_id!)&auth_token=\(UserModel.sharedInstance().auth_token!)&name=\(txtRestaurantName.text!)&street=\(txtStreetName.text!)&buliding_no=\(txtBuildingNo.text!)&zip_code=\(txtZipcode.text!)&city=\(txtProvince.text!)&country=\(txtCountry.text!)&latitude=\(latitude)&longitude=\(longitude)&lang_id=\(UserModel.sharedInstance().app_language!)"
        
        APIManager.shared.requestGETURL(serviceURL + params, success: { (response) in
            if let jsonObject = response.result.value as? [String:AnyObject] {
                if let status = jsonObject["status"] as? String{
                    if status == "0"{
                        print("Failed")
                        self.showWarning(jsonObject["message"] as! String)
                        
                    }else{
                        
                        self.showSuccess(jsonObject["message"] as! String)
                        if let responseData = jsonObject["responsedata"] as? [String:AnyObject] {
                            UserModel.sharedInstance().name = responseData["name"] as? String
                            UserModel.sharedInstance().street = responseData["street"] as? String
                            UserModel.sharedInstance().building_no = responseData["buliding_no"] as? String
                            UserModel.sharedInstance().zip_code = responseData["zip_code"] as? String
                            UserModel.sharedInstance().city = responseData["city"] as? String
                            UserModel.sharedInstance().country = responseData["country"] as? String
                            UserModel.sharedInstance().latitude = responseData["latitude"] as? String
                            UserModel.sharedInstance().longitude = responseData["longitude"] as? String
                            UserModel.sharedInstance().synchroniseData()
                            
                            NotificationCenter.default.post(name: Notification.Name("Language_Localization"), object: nil)
                            
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }
        }) { (error) in
            print(error)
        }
    }
}

extension EditProfileVC: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        txtStreetName.text = place.name
        latitude = place.coordinate.latitude
        longitude = place.coordinate.longitude
        
        let addressComponents = place.addressComponents
        
        for i in 0..<addressComponents!.count {
            let component = addressComponents![i]
            print(component)
            
            if component.types.contains("administrative_area_level_1") {
                self.txtProvince.text = component.name
            }
            
            if component.types.contains("country") {
                self.txtCountry.text = component.name
            }
            
            if component.types.contains("postal_code") {
                self.txtZipcode.text = component.name
            }
        }
        
        if txtZipcode.text!.isEmpty {
            let location = CLLocation(latitude: latitude, longitude: longitude)
            geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
                if let error = error {
                    print("Unable to Reverse Geocode Location (\(error))")
                    self.showError("Unable to find location.")
                    
                } else {
                    if let placemarks = placemarks, let placemark = placemarks.first {
                        self.txtZipcode.text = placemark.postalCode
                    } else {
                        self.showError("Address not founded")
                    }
                }
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    
    //User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    //Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}

extension EditProfileVC {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == txtStreetName{
            let placePickerController = GMSAutocompleteViewController()
            placePickerController.delegate = self
            self.present(placePickerController, animated: true, completion: nil)
            return false
        }else{
            return true
        }
    }
}
