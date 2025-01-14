//
//  extension.swift

import Foundation
import UIKit
import CoreLocation
import SwiftMessages
extension UIView {
    func addBottomBorderWithColor(color: UIColor, width: CGFloat) {
        DispatchQueue.main.async {
            let border = CALayer()
            border.backgroundColor = color.cgColor
            border.frame = CGRect(x:0, y:self.frame.size.height - width, width: self.frame.size.width, height: width)
            self.layer.addSublayer(border)
        }
    }
}


extension UITextField: UITextFieldDelegate {
    
    func BorderTextFields() {
        DispatchQueue.main.async {
            self.delegate = self
            self.layer.borderWidth = 0.7
            self.layer.borderColor = UIColor.lightGray.cgColor
        }
    }
    
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.delegate = self
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedStringKey.foregroundColor: newValue!])
        }
    }
    
    func roundTextField() {
        DispatchQueue.main.async {
            self.layer.cornerRadius = self.frame.height / 2
            self.layer.masksToBounds = true
        }
    }
    
    func setLeftView(image: UIImage?, Padding: Bool) {
        var ivLeft: UIImageView!
        if Padding {
            ivLeft = UIImageView(frame: CGRect(x: 0, y: 0, width: 10, height: self.frame.size.height))
        } else {
            ivLeft = UIImageView(frame: CGRect(x: 0, y: 0, width: self.frame.size.height, height: self.frame.size.height))
            if image != nil {
                ivLeft.image = image
                ivLeft.contentMode = .center
            }
        }
        self.leftView = ivLeft
        self.leftViewMode = .always
    }
    
    func setRightView(image: UIImage?, Padding: Bool) {
        var ivRight: UIImageView!
        if Padding {
            ivRight = UIImageView(frame: CGRect(x: self.frame.size.width - 10, y: 0, width: 10, height: self.frame.size.height))
        } else {
            ivRight = UIImageView(frame: CGRect(x: self.frame.size.width - self.frame.size.height, y: 0, width: self.frame.size.height, height: self.frame.size.height))
            if image != nil {
                ivRight.image = image
                ivRight.contentMode = .center
            }
        }
        self.rightView = ivRight
        self.rightViewMode = .always
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension UIViewController {
    func showAlertView(_ message:String!) {
        
        let alertController = UIAlertController(title: "Mangal House", message: message, preferredStyle: .alert)
        let btnOKAction = UIAlertAction(title: "OK", style: .default) { (action) -> Void in
        }
        alertController.addAction(btnOKAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showAlertView(_ message: String!, completionHandler: @escaping (_ value: Bool) -> Void){
        let alertController = UIAlertController(title: "Mangal House", message: message, preferredStyle: .alert)
        let btnOKAction = UIAlertAction(title: "OK", style: .default) { (action) -> Void in
            completionHandler(true)
        }
        alertController.addAction(btnOKAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showAlertView(_ message:String!, defaultTitle:String?, cancelTitle:String?, completionHandler: @escaping (_ value: Bool) -> Void) {
        let alertController = UIAlertController(title: "Mangal House", message: message, preferredStyle: .alert)
        let btnOKAction = UIAlertAction(title: defaultTitle, style: .default) { (action) -> Void in
            completionHandler(true)
        }
        let btnCancelAction = UIAlertAction(title: cancelTitle, style: .default) { (action) -> Void in
            completionHandler(false)
        }
        alertController.addAction(btnOKAction)
        alertController.addAction(btnCancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func setPlaceHolderText(_ str: String?) -> NSAttributedString? {
        let attString = NSMutableAttributedString(string: str ?? "")
        let range = (str?.count)!-1
        attString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.lightGray, range: NSRange(location: 0, length:range))
        attString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.red, range: NSRange(location: range, length: 1))
        return attString
    }
    
    func convertToServer(date: Date, format: String) -> String {
        let df = DateFormatter()
        df.dateFormat = format
        df.timeZone = TimeZone(identifier: "America/Chicago")
        return df.string(from: date)
    }
    
    func convertToServer(string: String, format: String) -> Date {
        let df = DateFormatter()
        df.dateFormat = format
        df.timeZone = TimeZone(identifier: "America/Chicago")
        return df.date(from: string)!
    }
    
    func convertDateFrom(string: String, format: String) -> Date {
        let df = DateFormatter()
        df.dateFormat = format
        //        df.timeZone = TimeZone(identifier: getCurrentTimeZone())
        return df.date(from: string)!
    }
    
    func convertStringFrom(date: Date, format: String) -> String {
        let df = DateFormatter()
        df.dateFormat = format
        df.timeZone = TimeZone(identifier: getCurrentTimeZone())
        return df.string(from: date)
    }
    
    
    func getCurrentTimeZone() -> String {
        return TimeZone.current.identifier
    }
    
    func convertDateFormate(date : Date,format:String) -> String{
        // Day
        let calendar = Calendar.current
        let anchorComponents = calendar.dateComponents([.day, .month, .year], from: date)
        
        // Formate
        let dateFormate = DateFormatter()
        dateFormate.dateFormat = format
        let newDate = dateFormate.string(from: date)
        
        var day  = "\(anchorComponents.day!)"
        switch (day) {
        case "1" , "21" , "31":
            day.append("st")
        case "2" , "22":
            day.append("nd")
        case "3" ,"23":
            day.append("rd")
        default:
            day.append("th")
        }
        return day + " " + newDate
    }
    
    func showError(_ subTitle : String){
        let error = MessageView.viewFromNib(layout: .messageView)
        error.configureTheme(.error)
        error.configureContent(title: Language.ERROR, body: subTitle)
        error.button?.isHidden = true
        error.iconImageView?.isHidden = false
        error.titleLabel?.font = UIFont(name: "Raleway-Bold", size: 17.0)
        error.bodyLabel?.font = UIFont(name: "Raleway-Regular", size: 15.0)
        error.backgroundColor = AppColors.light_Brown
        SwiftMessages.show(view: error)
    }
    
    func showSuccess(_ subTitle : String){
        let success = MessageView.viewFromNib(layout: .messageView)
        success.configureTheme(.success)
        success.configureContent(title: Language.SUCCESS, body: subTitle)
        success.button?.isHidden = true
        success.iconImageView?.isHidden = false
        success.titleLabel?.font = UIFont(name: "Raleway-Bold", size: 17.0)
        success.bodyLabel?.font = UIFont(name: "Raleway-Regular", size: 15.0)
        success.backgroundColor = AppColors.light_Brown
        SwiftMessages.show(view: success)
        
    }
    
    func showWarning(_ subTitle : String){
        let warning = MessageView.viewFromNib(layout: .messageView)
        warning.configureTheme(.warning)
        warning.configureContent(title: Language.WARNING, body: subTitle)
        warning.button?.isHidden = true
        warning.iconImageView?.isHidden = false
        warning.titleLabel?.font = UIFont(name: "Raleway-Bold", size: 17.0)
        warning.bodyLabel?.font = UIFont(name: "Raleway-Regular", size: 15.0)
        warning.backgroundColor = AppColors.light_Brown
        SwiftMessages.show(view: warning)
        
    }
    
    func checkNoInternetConnection(){
        if !NetworkManager.shared.isConnectedToNetwork() {
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "NoInternetVC") as? NoInternetVC
            vc?.modalPresentationStyle = .fullScreen
            self.present(vc!, animated: true, completion: nil)
        }
    }
}

extension UIButton {
    func roundButton() {
        DispatchQueue.main.async {
            self.layer.cornerRadius = self.frame.height / 2
            self.layer.masksToBounds = true
        }
        
    }
    
    
    func roundedBottom( _ radius : Double){
        let maskPath1 = UIBezierPath(roundedRect: bounds,
                                     byRoundingCorners: [.bottomLeft,.bottomRight],
                                     cornerRadii: CGSize(width: radius, height: radius))
        let maskLayer1 = CAShapeLayer()
        maskLayer1.frame = bounds
        maskLayer1.path = maskPath1.cgPath
        layer.mask = maskLayer1
    }
    
    func roundedBottomLeft( _ radius : Double){
        let maskPath1 = UIBezierPath(roundedRect: bounds,
                                     byRoundingCorners: [.bottomLeft],
                                     cornerRadii: CGSize(width: radius, height: radius))
        let maskLayer1 = CAShapeLayer()
        maskLayer1.frame = bounds
        maskLayer1.path = maskPath1.cgPath
        layer.mask = maskLayer1
    }
    
    func roundedBottomRight( _ radius : Double){
        let maskPath1 = UIBezierPath(roundedRect: bounds,
                                     byRoundingCorners: [.bottomRight],
                                     cornerRadii: CGSize(width: radius, height: radius))
        let maskLayer1 = CAShapeLayer()
        maskLayer1.frame = bounds
        maskLayer1.path = maskPath1.cgPath
        layer.mask = maskLayer1
    }
}

extension Data {
    var html2AttributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: self, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            print("error:", error)
            return  nil
        }
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}

extension String {
    var isEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,20}"
        let emailTest  = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    var isValidName : Bool {
        let nameEx = "^[a-zA-Z]+$"
        let nameTest = NSPredicate(format:"SELF MATCHES %@", nameEx)
        return nameTest.evaluate(with:self)
    }
    
    var isValidFullName : Bool {
        let fullNameEx = "^[a-zA-Z][a-zA-Z\\s]+$"
        let FullNameTest = NSPredicate(format:"SELF MATCHES %@", fullNameEx)
        return FullNameTest.evaluate(with: self)
    }
    
    var isValidPhoneNumber : Bool{
        let PHONE_REGEX = "^[0-9]{10}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        return phoneTest.evaluate(with: self)
    }
    
    var isValidZipNumber : Bool{
        let ZIP_REGEX = "^[0-9]{6}$"
        let zipTest = NSPredicate(format: "SELF MATCHES %@", ZIP_REGEX)
        return zipTest.evaluate(with: self)
    }
    
    func URLEncodedString() -> String? {
        let escapedString = self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        return escapedString
    }
    static func queryStringFromParameters(parameters: Dictionary<String,String>) -> String? {
        if (parameters.count == 0)
        {
            return nil
        }
        var queryString : String? = nil
        for (key, value) in parameters {
            if let encodedKey = key.URLEncodedString() {
                if let encodedValue = value.URLEncodedString() {
                    if queryString == nil
                    {
                        queryString = "?"
                    }
                    else
                    {
                        queryString! += "&"
                    }
                    queryString! += encodedKey + "=" + encodedValue
                }
            }
        }
        return queryString
    }
    
    var html2AttributedString: NSAttributedString? {
        return Data(utf8).html2AttributedString
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
    
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + self.lowercased().dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

extension CLPlacemark {
    
    var compactAddress: String? {
        if let name = name {
            var result = name
            
            if let street = thoroughfare {
                result += ", \(street)"
            }
            
            if let SubLocality = subLocality {
                result += ", \(SubLocality)"
            }
            
            if let city = locality {
                result += ", \(city)"
            }
            
            if let state = administrativeArea {
                result += ", \(state)"
            }
            
            if let country = country {
                result += ", \(country)"
            }
            
            return result
        }
        
        return nil
    }
    
}
