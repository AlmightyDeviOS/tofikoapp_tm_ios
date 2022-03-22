//
//  AppDelegate.swift
//  Restaurent Manager
//
//  Created by APPLE on 18/09/19.
//  Copyright © 2019 com.Coder2 All rights reserved.
//

import UIKit
import UserNotifications
import Firebase
import FirebaseInstanceID
import FirebaseMessaging
import GooglePlaces
import IQKeyboardManager

@UIApplicationMain
 class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    var window: UIWindow?
    var deviceToken: String!
    var navigationController : UINavigationController?
    var storyboard:UIStoryboard? = nil
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true
        
        FirebaseApp.configure()
        GMSPlacesClient.provideAPIKey("AIzaSyDnwVsJT81wVvk3ER1kbjebezFzBTzu4i4")
        Messaging.messaging().delegate = self
        registerRemoteNotifications(application)
        
        if #available(iOS 13.0, *) {
            
        }else {
            if let statusBar = UIApplication.shared.value(forKey: "statusBar") as? UIView {
                statusBar.backgroundColor = AppColors.light_Brown
            }
        }
        
        call_CheckAppVersion()
        call_GeneralAppSetting()
        call_Get_Language()
        
        if UserModel.sharedInstance().user_id != nil && UserModel.sharedInstance().user_id! != "" {
            
            resetPushCounter()
//            self.ChangeRoot()
        }
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    //Used to change the root of the application. Used to redirect to the main screen.
    func changeLoginRoot() {
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
    
    func ChangeRoot() {
        let homeSB = UIStoryboard(name: "Main", bundle: nil)
        let desiredViewController = homeSB.instantiateViewController(withIdentifier: "SideMenuNavigation") as! SideMenuNavigation
        let appdel = UIApplication.shared.delegate as! AppDelegate
        let snapshot:UIView = (appdel.window?.snapshotView(afterScreenUpdates: true))!
        desiredViewController.view.addSubview(snapshot);
        
        appdel.window?.rootViewController = desiredViewController;
        
        UIView.animate(withDuration: 0.3, animations: {() in
            snapshot.layer.opacity = 0;
            snapshot.layer.transform = CATransform3DMakeScale(1.5, 1.5, 1.5);
        }, completion: {
            (value: Bool) in
            snapshot.removeFromSuperview();
        });
    }
        
    //MARK:- Push Notification Methods
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instance ID: \(error)")
            } else if let result = result {
                self.deviceToken = result.token
                if self.deviceToken != "" {
                    UserModel.sharedInstance().deviceToken = self.deviceToken
                    UserModel.sharedInstance().synchroniseData()
                }
                print("Remote instance ID token: \(result.token)")
            }
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        print(userInfo)
        
        let aps = userInfo["aps"] as! [String: AnyObject]
        let message = (aps["alert"] as! [String:AnyObject])["body"] as! String

        if (application.applicationState == .active) {
            var topWindow: UIWindow? = UIWindow(frame: UIScreen.main.bounds)
            topWindow?.rootViewController = UIViewController()
            
            let alertController = UIAlertController(title: Constant.PROJECT_NAME as String, message: message, preferredStyle: .alert)
            let btnCancelAction = UIAlertAction(title: "Ok", style: .default) { (action) -> Void in
                topWindow?.isHidden = true
                topWindow = nil
            }
            alertController.addAction(btnCancelAction)
            topWindow?.makeKeyAndVisible()
            topWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
            
        }else{
            
            //order_accept, order_decline, order_delivery, order_complete, order_rating_reply
            if UserModel.sharedInstance().user_id != nil{
                
                if let type = userInfo["type"] as? String {
                    
                    if type == "order_receive" {
                        DispatchQueue.main.async {
                            self.ChangeRoot()
                        }
                    }else if type == "order_feedback"  {
                        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let viewController2 = mainStoryboard.instantiateViewController(withIdentifier: "ReviewVC") as! ReviewVC
                        viewController2.isNotification = true
                        self.navigationController = UINavigationController .init(rootViewController: viewController2)
                        self.window?.rootViewController = self.navigationController
                    }else if type == "delete_cart" {
                        DispatchQueue.main.async {
                            self.ChangeRoot()
                        }
                    }else if type == "booking_receive" {
                        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let viewController2 = mainStoryboard.instantiateViewController(withIdentifier: "BookedTableListVC") as! BookedTableListVC
                        viewController2.isNotification = true
                        viewController2.selectedDate = userInfo["booking_date"] as? String ?? ""
                        self.navigationController = UINavigationController .init(rootViewController: viewController2)
                        self.window?.rootViewController = self.navigationController
                    }else {
                        DispatchQueue.main.async {
                            self.ChangeRoot()
                        }
                    }
                }
            }
        }
    }
    
    func registerRemoteNotifications(_ application:UIApplication) {
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
    }
    
    //MARK:- Webservices
    func call_Get_Language() {
        
        //Checking for internet connection. If internet is not available then system will display toast message.
        //UserModel.sharedInstance().app_language!
        //Creating API request to fetch the data.
        let serviceURL = Constant.WEBURL + Constant.API.GET_LANGUAGE
        
        if UserModel.sharedInstance().app_language == nil {
            UserModel.sharedInstance().app_language = "2"
            UserModel.sharedInstance().synchroniseData()
        }
        let params = "?lang_id=\(UserModel.sharedInstance().app_language!)"
        
        //Starting process to fetch the data.
        APIManager.shared.requestGETURL_WithOutLoader(serviceURL + params, success: { (response) in
            
            //Parsing method started to parse the data.
            if let jsonObject = response.result.value as? [String:AnyObject] {
                
                //Getting status of API. If status is 0 then fetching data otherwise it will show message of failure with reason.
                if let status = jsonObject["status"] as? String{
                    if status == "0"{
                        print("Failed")
                    }else{
                        
                        print(jsonObject)
                        if let responseData = jsonObject["responsedata"] as? [String:AnyObject] {
                            
                            Language.EMAIL_ADDRESS = responseData["EMAIL_ADDRESS"] as! String
                            Language.PASSWORD = responseData["PASSWORD"] as! String
                            Language.LOGIN = responseData["LOGIN"] as! String
                            Language.FORGOT_PASSWORD = responseData["FORGOT_PASS"] as! String
                            Language.SEND_PASS = responseData["SEND_PASS"] as! String
                            Language.SUBMIT = responseData["SUBMIT"] as! String
                            Language.DASHBOARD = responseData["DASHBOARD"] as! String
                            Language.MENU = responseData["Menu"] as! String
                            Language.ORDER_HISTORY = responseData["ORDER_HISTORY"] as! String
                            Language.SCAN_BARCODE = responseData["SCAN_BARCODE"] as! String
                            Language.SCHEDULE = responseData["SCHEDULE"] as! String
                            Language.REVIEW = responseData["REVIEW"] as! String
                            Language.SETTING = responseData["SETTING"] as! String
                            Language.LOGOUT = responseData["LOGOUT"] as! String
                            Language.PRODUCT_LIST = responseData["PRODUCT_LIST"] as! String
                            Language.ALL_ENABLE_DISABLE = responseData["ALL_ENABLE_DISABLE"] as! String
                            Language.ITEM_DETAIL = responseData["ITEM_DETAIL"] as! String
                            Language.SHOW_CUST = responseData["SHOW_CUST"] as! String
                            Language.INGREDIENTS = responseData["INGREDIENTS"] as! String
                            Language.ALLERGENS = responseData["ALLERGENS"] as! String
                            Language.CHOOSE_OPTION = responseData["CHOOSE_OPTION"] as! String
                            Language.GALLERY = responseData["GALLERY"] as! String
                            Language.CAMERA = responseData["CAMERA"] as! String
                            Language.CANCEL = responseData["CANCEL"] as! String
                            Language.FREE = responseData["FREE"] as! String
                            Language.PAID = responseData["PAID"] as! String
                            Language.CUSTOMIZATION = responseData["CUSTOMIZATION"] as! String
                            Language.WOOPS = responseData["WOOPS"] as! String
                            Language.UPCOMING = responseData["UPCOMING"] as! String
                            Language.IN_PREPARE = responseData["IN_PREPARE"] as! String
                            Language.DELIVERY = responseData["DELIVERY"] as! String
                            Language.ACCEPT = responseData["ACCEPT"] as! String
                            Language.DECLINE = responseData["DECLINE"] as! String
                            Language.DELIVER = responseData["DELIVER"] as! String
                            Language.ORDER_NOT_FOUND = responseData["ORDER_NOT_FOUND"] as! String
                            Language.SELECT_REASON_TO_CANCEL = responseData["SELECT_REASON_TO_CANCEL"] as! String
                            Language.NAME = responseData["NAME"] as! String
                            Language.PHONE_NO = responseData["PHONE_NO"] as! String
                            Language.PRICE = responseData["PRICE"] as! String
                            Language.ADDRESS = responseData["ADDRESS"] as! String
                            Language.ADDRESS = responseData["ADDRESS"] as! String
                            Language.DELIVERY_TYPE = responseData["DELIVERY_TYPE"] as! String
                            Language.SELECT_TIME = responseData["SELECT_TIME"] as! String
                            Language.LATER = responseData["LATER"] as! String
                            Language.NOW = responseData["NOW"] as! String
                            Language.SELECT = responseData["SELECT"] as! String
                            Language.PRODUCT_NOT_AVAILABLE = responseData["PRODUCT_NOT_AVAILABLE"] as! String
                            Language.EXTRA_CLOSURE = responseData["EXTRA_CLOSURE"] as! String
                            Language.TECH_PROBLEM = responseData["TECH_PROBLEM"] as! String
                            Language.OTHER = responseData["OTHER"] as! String
                            Language.ORDER_DETAIL = responseData["ORDER_DETAIL"] as! String
                            Language.TOTAL_AMT = responseData["TOTAL_AMT"] as! String
                            Language.ORDER_NUMBER = responseData["ORDER_NUMBER"] as! String
                            Language.CUSTOMER_NAME = responseData["CUSTOMER_NAME"] as! String
                            Language.CUSTOMER_NUMBER = responseData["CUSTOMER_NUMBER"] as! String
                            Language.PAYMENT_TYPE = responseData["PAYMENT_TYPE"] as! String
                            Language.ORDER_TYPE = responseData["ORDER_TYPE"] as! String
                            Language.SPE_NOTE = responseData["SPE_NOTE"] as! String
                            Language.REMOVE = responseData["REMOVE"] as! String
                            Language.TASTE = responseData["TASTE"] as! String
                            Language.ADD_ONS = responseData["ADD_ONS"] as! String
                            Language.PAST_ORDERS = responseData["PAST_ORDERS"] as! String
                            Language.ALL = responseData["ALL"] as! String
                            Language.TODAY = responseData["TODAY"] as! String
                            Language.YESTERDAY = responseData["YESTERDAY"] as! String
                            Language.LAST_WEEK = responseData["LAST_WEEK"] as! String
                            Language.CURRENT_MONTH = responseData["CURRENT_MONTH"] as! String
                            Language.ACCEPTED = responseData["ACCEPTED"] as! String
                            Language.CANCELLED = responseData["CANCELLED"] as! String
                            Language.DECLINED = responseData["DECLINED"] as! String
                            Language.CANCEL_NOTE = responseData["CANCEL_NOTE"] as! String
                            Language.COMPLETED = responseData["COMPLETED"] as! String
                            Language.COMPLETED_AMOUNT = responseData["COMPLETED_AMOUNT"] as! String
                            Language.DECLINED_AMOUNT = responseData["DECLINED_AMOUNT"] as! String
                            Language.HOLIDAY_IN_RESTAURANT = responseData["HOLIDAY_IN_RESTAURANT"] as! String
                            Language.OPENING_TIME = responseData["OPENING_TIME"] as! String
                            Language.CLOSING_TIME = responseData["CLOSING_TIME"] as! String
                            Language.HOLIDAY = responseData["HOLIDAY"] as! String
                            Language.SUNDAY = responseData["SUNDAY"] as! String
                            Language.MONDAY = responseData["MONDAY"] as! String
                            Language.TUESDAY = responseData["TUESDAY"] as! String
                            Language.WEDNESDAY = responseData["WEDNESDAY"] as! String
                            Language.THURSDAY = responseData["THURSDAY"] as! String
                            Language.FRIDAY = responseData["FRIDAY"] as! String
                            Language.SATURDAY = responseData["SATURDAY"] as! String
                            Language.WRITE_FEEDBACK = responseData["WRITE_FEEDBACK"] as! String
                            Language.TYPE_REPLY = responseData["TYPE_REPLY"] as! String
                            Language.REPLY = responseData["REPLY"] as! String
                            Language.PROFILE = responseData["PROFILE"] as! String
                            Language.PUSH_NOTIFICATION = responseData["PUSH_NOTIFICATION"] as! String
                            Language.SUPPORT = responseData["SUPPORT"] as! String
                            Language.TERMS_CONDITIONS = responseData["TERMS_AND_CONDITIONS"] as! String
                            Language.PRIVACY_POLICY = responseData["PRIVACY_POLICY"] as! String
                            Language.COOKIE_POLICY = responseData["COOKIE_POLICY"] as! String
                            Language.VERSION = responseData["VERSION"] as! String
                            Language.LOCATION = responseData["LOCATION"] as! String
                            Language.STREET = responseData["STREET"] as! String
                            Language.STREET_LINE2 = responseData["STREET_LINE2"] as! String
                            Language.ZIPCODE = responseData["ZIPCODE"] as! String
                            Language.PROVINCE = responseData["PROVINCE"] as! String
                            Language.COUNTRY = responseData["COUNTRY"] as! String
                            Language.CHANGE_PASS = responseData["CHANGE_PASS"] as! String
                            Language.OLD_PASS = responseData["OLD_PASS"] as! String
                            Language.NEW_PASS = responseData["NEW_PASS"] as! String
                            Language.CONFIRM_PASSWORD = responseData["CONFIRM_PASS"] as! String
                            Language.UPDATE = responseData["UPDATE"] as! String
                            Language.NOTIFICATION = responseData["NOTIFICATION"] as! String
                            Language.ORDER_NOTIFICATION = responseData["ORDER_NOTIFICATION"] as! String
                            Language.EMAIL_NOTIFICATION = responseData["EMAIL_NOTIFICATION"] as! String
                            Language.SCANNER = responseData["SCANNER"] as! String
                            Language.APPROACH_QR_CODE = responseData["APPROACH_QR_CODE"] as! String
                            Language.ADD_POINT = responseData["ADD_POINT"] as! String
                            Language.CUST_INFO = responseData["CUST_INFO"] as! String
                            Language.ENTER_MANGALS = responseData["ENTER_MANGALS"] as! String
                            Language.SEND_QUERY_TEAM = responseData["SEND_QUERY_TEAM"] as! String
                            Language.SEND = responseData["SEND"] as! String
                            Language.WRITE_QUERY_HERE = responseData["WRITE_QUERY_HERE"] as! String
                            Language.ERROR = responseData["ERROR"] as! String
                            Language.WARNING = responseData["WARNING"] as! String
                            Language.SUCCESS = responseData["SUCCESS"] as! String
                            Language.CHECK_INTERNET = responseData["CHECK_INTERNET"] as! String
                            Language.WENT_WRONG = responseData["WENT_WRONG"] as! String
                            Language.VAILD_EMAIL = responseData["VAILD_EMAIL"] as! String
                            Language.PROVIDE_PASS = responseData["PROVIDE_PASS"] as! String
                            Language.PROVIDE_EMAIL = responseData["PROVIDE_EMAIL"] as! String
                            Language.PROVIDE_OLD_PASS = responseData["PROVIDE_OLD_PASS"] as! String
                            Language.PROVIDE_NEW_PASS = responseData["PROVIDE_NEW_PASS"] as! String
                            Language.PASS_NOT_MATCH = responseData["PASS_NOT_MATCH"] as! String
                            Language.PLEASE_ENTER_MANGAL = responseData["PLEASE_ENTER_MANGAL"] as! String
                            Language.CASH_ON_DELIVERY = responseData["CASH_ON_DELIVERY"] as! String
                            Language.SELECT_LANGUAGE = responseData["SELECT_LANGUAGE"] as! String
                            Language.ORDER_TIME = responseData["ORDER_TIME"] as! String
                            
                            Language.ITEM_TOTAL = responseData["ITEM_TOTAL"] as! String
                            Language.DELIVERY_CHARGE = responseData["DELIVERY_CHARGE"] as! String
                            Language.TOTAL_PAYABLE_AMT = responseData["TOTAL_PAYABLE_AMT"] as! String
                            
                            Language.LAST_ORDER_ON = responseData["LAST_ORDER_ON"] as! String
                            Language.NUMBER_OF_PAST_ORDER = responseData["NUMBER_OF_PAST_ORDER"] as! String
                            Language.NEW_CUSTOMER = responseData["NEW_CUSTOMER"] as! String
                            
                            Language.COOKING_LEVEL = responseData["COOKING_LEVEL"] as! String
                            
                            Language.UPGRADE_APP = responseData["UPGRADE_APP"] as! String
                            Language.UPGRADE_MESSAGE = responseData["UPGRADE_MESSAGE"] as! String
                            
                            Language.PROVIDE_FNAME = responseData["PROVIDE_FNAME"] as! String
                            Language.PROVIDE_LNAME = responseData["PROVIDE_LNAME"] as! String
                            Language.ENTER_COMPANY = responseData["ENTER_COMPANY"] as! String
                            Language.ENTER_STORE = responseData["ENTER_STORE"] as! String
                            Language.JOIN_US = responseData["JOIN_US"] as! String
                            Language.REGISTER = responseData["REGISTER"] as! String
                            Language.LOGIN_FLOW = responseData["LOGIN_FLOW"] as! String
                            Language.REGISTER_FLOW = responseData["REGISTER_FLOW"] as! String
                            Language.SELECT_STORE = responseData["SELECT_STORE"] as! String
                            Language.SELECT_COMPANY = responseData["SELECT_COMPANY"] as! String
                            
                            Language.NO_REVIEW_FOUND = responseData["NO_REVIEW_FOUND"] as! String
                            
                            Language.FNAME = responseData["FNAME"] as! String
                            Language.LNAME = responseData["LNAME"] as! String
                            Language.PHONE_NUMBER = responseData["PHONE_NUMBER"] as! String
                            Language.COMPANY = responseData["COMPANY"] as! String
                            Language.STORE = responseData["STORE"] as! String
                            Language.COMPLETE = responseData["COMPLETE"] as! String
                            Language.INVOICE_DETAIL = responseData["INVOICE_DETAIL"] as! String
                            Language.ITEMS = responseData["ITEMS"] as! String
                            Language.DELIVERY_TIME = responseData["DELIVERY_TIME"] as! String
                            
                            Language.CUSTOMER_RECEIVE_THIS_POINTS1 = responseData["CUSTOMER_RECEIVE_THIS_POINTS1"] as! String
                            Language.CUSTOMER_RECEIVE_THIS_POINTS2 = responseData["CUSTOMER_RECEIVE_THIS_POINTS2"] as! String
                            Language.CONFIRMATION_ORDER_DISABLE = responseData["CONFIRMATION_ORDER_DISABLE"] as! String
                            Language.YES_LABEL = responseData["YES_LABEL"] as! String
                            Language.NO_LABEL = responseData["NO_LABEL"] as! String
                            Language.TABLE_BOOKING = responseData["TABLE_BOOKING"] as! String
                            
                            Language.TODAY_TABLE_BOOKING = responseData["TODAY_TABLE_BOOKING"] as! String
                            Language.NEW = responseData["NEW"] as! String
                            Language.ARRIVED = responseData["ARRIVED"] as! String
                            Language.REJECT = responseData["REJECT"] as! String
                            Language.ORDERS = responseData["ORDERS"] as! String
                            Language.ONGOING = responseData["ONGOING"] as! String
                            Language.TABLE_NOT_FOUND = responseData["TABLE_NOT_FOUND"] as! String
                            Language.STATUS = responseData["STATUS"] as! String
                            Language.NEXT = responseData["NEXT"] as! String
                            Language.CURRENT = responseData["CURRENT"] as! String
                            Language.BOOKING_TYPE = responseData["BOOKING_TYPE"] as! String
                            Language.ALL_SERVICE = responseData["ALL_SERVICE"] as! String
                            Language.LUNCH = responseData["LUNCH"] as! String
                            Language.DINNER = responseData["DINNER"] as! String
                            Language.SELECT_SERVICE = responseData["SELECT_SERVICE"] as! String
                            
                            Language.PENDING = responseData["PENDING"] as! String
                            Language.SPECIAL_REQ = responseData["SPECIAL_REQ"] as! String
                            Language.RESERVED = responseData["RESERVED"] as! String
                            Language.LEFT = responseData["LEFT"] as! String
                            Language.CANCELLATION_NOTE = responseData["CANCELLATION_NOTE"] as! String
                            
                            Language.REJECT_TBL_RESERVATION = responseData["REJECT_TBL_RESERVATION"] as! String
                            Language.WRITE_TBL_REJECTION_MSG = responseData["WRITE_TBL_REJECTION_MSG"] as! String
                            Language.REJECTS = responseData["REJECTS"] as! String
                            
                            Language.TODAY_TABLE_BOOKING = responseData["TODAY_TABLE_BOOKING"] as! String
                            Language.NEW = responseData["NEW"] as! String
                            Language.ARRIVED = responseData["ARRIVED"] as! String
                            Language.REJECT = responseData["REJECT"] as! String
                            Language.APPROVED = responseData["APPROVED"] as! String
                            
                            Language.ORDERS = responseData["ORDERS"] as! String
                            Language.ONGOING = responseData["ONGOING"] as! String
                            Language.TABLE_NOT_FOUND = responseData["TABLE_NOT_FOUND"] as! String
                            Language.STATUS = responseData["STATUS"] as! String
                            Language.NEXT = responseData["NEXT"] as! String
                            Language.CURRENT = responseData["CURRENT"] as! String
                            Language.BOOKING_TYPE = responseData["BOOKING_TYPE"] as! String
                            Language.ALL_SERVICE = responseData["ALL_SERVICE"] as! String
                            Language.LUNCH = responseData["LUNCH"] as! String
                            Language.DINNER = responseData["DINNER"] as! String
                            Language.SELECT_SERVICE = responseData["SELECT_SERVICE"] as! String
                            
                            Language.TBL_BOOKING_SETTING = responseData["TBL_BOOKING_SETTING"] as! String
                            Language.AVG_MEAL_TIME_HR = responseData["AVG_MEAL_TIME_HR"] as! String
                            Language.AVG_MEAL_TIME_MIN = responseData["AVG_MEAL_TIME_MIN"] as! String
                            Language.TOT_SEAT_CAPACITY = responseData["TOT_SEAT_CAPACITY"] as! String
                            Language.ENTER_HR = responseData["ENTER_HR"] as! String
                            Language.ENTER_MIN = responseData["ENTER_MIN"] as! String
                            Language.ENER_SEAT_CAPACITY = responseData["ENTER_SEAT_CAPACITY"] as! String
                            Language.NO_OF_PERSON_COME = responseData["NO_OF_PERSON_COME"] as! String
                            Language.NO_OF_SEAT_AVAILABLE = responseData["NO_OF_SEAT_AVAILABLE"] as! String
                            Language.AVG_MEAL_TIME = responseData["AVG_MEAL_TIME"] as! String
                            Language.ENTER_UR_REPLY = responseData["ENTER_UR_REPLY"] as! String
                            Language.PLZ_ENTER_UR_REPLY = responseData["PLZ_ENTER_UR_REPLY"] as! String
                            
                            NotificationCenter.default.post(name: Notification.Name("Language_Localization"), object: nil)
                        }
                    }
                }
            }
            
        }) { (error) in
            print(error)
        }
    }
    
    func call_GeneralAppSetting() {
        
        let serviceURL = Constant.WEBURL + Constant.API.GENERAL_SETTING
        
        if UserModel.sharedInstance().user_id == nil || UserModel.sharedInstance().auth_token == nil{
            return
        }
        
        let params = "?res_id=\(UserModel.sharedInstance().user_id!)&auth_token=\(UserModel.sharedInstance().auth_token!)&store_id=\(UserModel.sharedInstance().store_id!)&lang_id=\(UserModel.sharedInstance().app_language!)"
        
        //Starting process to fetch the data.
        APIManager.shared.requestGETURL_WithOutLoader(serviceURL + params, success: { (response) in
            
            //Parsing method started to parse the data.
            if let jsonObject = response.result.value as? [String:AnyObject] {
                
                //Getting status of API. If status is 0 then fetching data otherwise it will show message of failure with reason.
                if let status = jsonObject["status"] as? String{
                    if status == "0"{
                        print("Failed")
                    }else{
                        
                        print(jsonObject)
                        if let responseData = jsonObject["responsedata"] as? [String:AnyObject] {
                            UserModel.sharedInstance().user_id = responseData["res_id"] as? String
                            UserModel.sharedInstance().name = responseData["name"] as? String
                            UserModel.sharedInstance().email = responseData["email"] as? String
                            UserModel.sharedInstance().password = responseData["password"] as? String
                            UserModel.sharedInstance().country = responseData["country"] as? String
                            UserModel.sharedInstance().city = responseData["city"] as? String
                            UserModel.sharedInstance().street = responseData["street"] as? String
                            UserModel.sharedInstance().building_no = responseData["building_no"] as? String
                            UserModel.sharedInstance().province = responseData["province"] as? String
                            UserModel.sharedInstance().profile_image = responseData["image"] as? String
                            UserModel.sharedInstance().zip_code = responseData["zip_code"] as? String
                            UserModel.sharedInstance().latitude = responseData["latitude"] as? String
                            UserModel.sharedInstance().longitude = responseData["longitude"] as? String
                            UserModel.sharedInstance().website = responseData["website"] as? String
                            UserModel.sharedInstance().status = responseData["res_status"] as? String
                            UserModel.sharedInstance().push_notification = responseData["push_notification"] as? String
                            UserModel.sharedInstance().email_notification = responseData["email_notification"] as? String
                            UserModel.sharedInstance().auth_token = responseData["token"] as? String
                            
                            
                            if let avg_meal_min = responseData["avg_meal_min"] as? Int{
                                UserModel.sharedInstance().avg_meal_min = "\(avg_meal_min)"
                            }
                            
                            if let avg_meal_hour = responseData["avg_meal_hour"] as? Int{
                                UserModel.sharedInstance().avg_meal_hour = "\(avg_meal_hour)"
                            }
                            
                            UserModel.sharedInstance().seating_capacity = responseData["no_of_capacity"] as? String
                            
                            UserModel.sharedInstance().synchroniseData()
                        }
                    }
                }
            }
            
        }) { (error) in
            print(error)
        }
    }
    
    func resetPushCounter() {
        
        //Creating API request to fetch the data.
        let serviceURL = Constant.WEBURL + Constant.API.UPDATE_PUSH_CNT
        var params = ""
        
        if UserModel.sharedInstance().deviceToken != nil{
            params = "res_id=\(UserModel.sharedInstance().user_id!)&auth_token=\(UserModel.sharedInstance().auth_token!)&device_token=\(UserModel.sharedInstance().deviceToken!)&store_id=\(UserModel.sharedInstance().store_id!)"
        }else{
            params = "res_id=\(UserModel.sharedInstance().user_id!)&auth_token=\(UserModel.sharedInstance().auth_token!)&device_token=&store_id=\(UserModel.sharedInstance().store_id!)"
        }
        
        APIManager.shared.requestGETURL_WithOutLoader(serviceURL + params, success: { (response) in
            UIApplication.shared.endIgnoringInteractionEvents()
            
        }) { (error) in
            UIApplication.shared.endIgnoringInteractionEvents()
            
            print(error)
        }
    }
    
    func call_CheckAppVersion(){
        
        let url = "http://itunes.apple.com/lookup?id=\(Constant.APP_ID)"
        var appLiveVersion = ""
        APIManager.shared.requestGETURL_WithOutLoader(url, success: { (response) in
            print(response)
            
            if let jsonObject = response.result.value as? [String:AnyObject] {
                let configData = jsonObject["results"] as? [AnyHashable]

                for config in configData ?? [] {
                    appLiveVersion = (config as NSObject).value(forKey: "version") as? String ?? ""
                    break
                }

                UserModel.sharedInstance().app_version = appLiveVersion
                UserModel.sharedInstance().synchroniseData()
            }
            
            
        }) { (error) in
        }
    }
}

