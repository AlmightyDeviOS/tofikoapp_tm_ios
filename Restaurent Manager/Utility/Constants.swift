//
//  Constants.swift

import Foundation
import UIKit

struct AppColors {
    static let light_Brown = UIColor(red: CGFloat(55/255.0), green: CGFloat(175/255.0), blue: CGFloat(180/255.0), alpha: 1.0)
}

public class Helper {
    public class var isIpad:Bool {
        if #available(iOS 8.0, *) {
            return UIScreen.main.traitCollection.userInterfaceIdiom == .pad
        } else {
            return UIDevice.current.userInterfaceIdiom == .pad
        }
    }
    public class var isIphone:Bool {
        if #available(iOS 8.0, *) {
            return UIScreen.main.traitCollection.userInterfaceIdiom == .phone
        } else {
            return UIDevice.current.userInterfaceIdiom == .phone
        }
    }
}

struct Fonts {
    static func Regular(fontSize: CGFloat) -> UIFont {
        return UIFont(name: "HelveticaNeueCE-Roman", size: fontSize)!
    }
}

struct ScreenSize
{
    static let SCREEN_WIDTH         = UIScreen.main.bounds.size.width
    static let SCREEN_HEIGHT        = UIScreen.main.bounds.size.height
    static let SCREEN_MAX_LENGTH    = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH    = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}

class Constant
{
    static var WEBURL = "https://tofiko.com/webservices/manager/"
    //OLD : http://zaur.it/restaurantapp/webservices/manager/
    //NEW : http://appadmin.mangal.house/webservices/manager/
    
    static var APP_STORE_LINK = "https://apps.apple.com/us/app/tofiko-manager/id1564254605"
//    static var APP_STORE_LINK = "https://apps.apple.com/in/app/mrdaas/id1544444142"

    static var APP_ID = "1564254605"
    
    static var web_url_content=""
    static var web_url_common=""
    static var PROJECT_NAME = "MagalHouse" as NSString
    static var defaults = UserDefaults.standard
    
    static var FBShareURL = "https://www.facebook.com/mangalhousetorino/"
    static var InstaShareURL = "https://www.instagram.com/mangal_house_torino/"
    static var MagalHouseWebURL = "http://www.mangal.house/"
    
    struct API {
        static var LOGIN = "login.php"
        static var FORGOT_PASSWORD = "forgot_password.php"
        static var CHANGE_PASSWORD = "change_password.php"
        static var NOTIFICATION_STATUS = "set_notification.php"
        static var UPDATE_PUSH_CNT = "update_push_counter.php"
        static var STATIC_PAGE = "static_page.php"
        static var SUPPORT_QUESTION_LIST = "support_questions.php"
        static var ORDER_HISTORY = "order_history.php"
        static var CURRENT_ORDER_LIST = "current_order_list.php"
        static var CHANGE_ORDER_STATUS = "change_order_status.php"
        static var ORDER_DETAIL = "order_detail.php"
        static var MENU_CATEGORY = "menu_category.php"
        static var SEND_SUPPORT = "generate_ticket.php"
        static var GET_REVIEW_LIST = "restaurant_review.php"
        static var REPLY_OF_REVIEW = "add_review_reply.php"
        static var SET_RESTAURENT_OFF_ON = "set_restaurant_off.php"
        static var ITEM_LIST = "item_list.php"
        static var CHANGE_ITEM_STATUS = "change_item_status.php"
        static var CHANGE_ITEM_IMAGE = "edit_item_image.php"
        static var ITEM_DETAIL = "item_detail.php"
        static var CUSTOMIZATION_LIST = "customization_list.php"
        static var OPEN_CLOSE_TIME = "open_close_time.php"
        static var ADD_HOLIDAY_DATES = "add_holiday_dates.php"
        static var SET_OPEN_CLOSE_TIME = "set_open_close_time.php"
        static var GET_CUSTOMER_DETAIL = "get_user_details.php"
        static var ADD_POINTS = "add_points.php"
        static var LOG_OUT = "logout.php"
        static var EDIT_PROFILE = "edit_profile.php"
        
        static var LANGUAGE_LIST = "languages.php"
        static var SET_LANGUAGE = "set_app_language.php"
        static var GET_LANGUAGE = "get_lang_keyword.php"
        
        static var GENERAL_SETTING = "get_profile.php"
        static var EDIT_ORDER_TIME = "change_order_time.php"
        
        static var GET_COMPANY = "get_companies.php"
        static var GET_STORE_BY_COMPANY = "get_store_by_company.php"
        
        static var REGISTER = "user_register.php"
        static var TABLE_BOOKING_REQUEST = "get_table_booking_requests.php"
        static var CHANGE_TABLE_BOOKING_REQUEST = "change_table_request_status.php"
        static var BOOKING_REPLY = "booking_reply.php"
        static var TBL_BOOKING_SETTING = "change_avg_meal_time.php"
        
        
        
        static var GET_CALENDER_DATE = "get_calendar_dates.php"
        static var DASHBOARD = "dashboard.php"
        
        
    }
}

class Language {
        
    static var EMAIL_ADDRESS = "Email Address"
    static var PASSWORD = "Password"
    static var LOGIN = "LOGIN"
    static var FORGOT_PASSWORD = "Forgot Password?"
    static var SEND_PASS = "We'll send your password to your regsitered email address"
    static var SUBMIT = "SUBMIT"
    static var DASHBOARD = "Dashboard"
    static var MENU = "Menù"
    static var ORDER_HISTORY = "Order History"
    static var SCAN_BARCODE = "Scan Barcode"
    static var SCHEDULE = "Schedule"
    static var REVIEW = "Review"
    static var SETTING = "Setting"
    static var LOGOUT = "Logout"
    static var PRODUCT_LIST = "Product List"
    static var ALL_ENABLE_DISABLE = "All Enable / Disable"
    static var ITEM_DETAIL = "Item Detail"
    static var SHOW_CUST = "Show Customization"
    static var INGREDIENTS = "Ingredients"
    static var ALLERGENS = "Allergens"
    static var CHOOSE_OPTION = "Choose Option"
    static var GALLERY = "Gallery"
    static var CAMERA = "Camera"
    static var CANCEL = "Cancel"
    static var FREE = "Free"
    static var PAID = "Paid"
    static var CUSTOMIZATION = "Customization"
    static var WOOPS = "Woops!"
    static var UPCOMING = "Upcoming"
    static var IN_PREPARE = "In Prepare"
    static var DELIVERY = "Delivery"
    static var ACCEPT = "Accept"
    static var DECLINE = "Decline"
    static var DELIVER = "Deliver"
    static var ORDER_NOT_FOUND = "Order not found"
    static var SELECT_REASON_TO_CANCEL = "Select any one reason for order cancellation"
    static var NAME = "Name"
    static var PHONE_NO = "Phone No"
    static var ADDRESS = "Address"
    static var PRICE = "Price"
    static var DELIVERY_TYPE = "Delivery Type"
    static var SELECT_TIME = "Select Time"
    static var LATER = "Later"
    static var NOW = "Now"
    static var SELECT = "Select"
    static var PRODUCT_NOT_AVAILABLE = "Product not available"
    static var EXTRA_CLOSURE = "Extraordinary closure"
    static var TECH_PROBLEM = "Technical Problems"
    static var OTHER = "Other"
    static var ORDER_DETAIL = "Order Detail"
    static var TOTAL_AMT = "Total Amount"
    static var ORDER_NUMBER = "Order Number"
    static var CUSTOMER_NAME = "Customer Name"
    static var CUSTOMER_NUMBER = "Customer Number"
    static var PAYMENT_TYPE = "Payment Type"
    static var ORDER_TYPE = "Order Type"
    static var SPE_NOTE = "Special Notes"
    static var REMOVE = "Remove"
    static var TASTE = "Taste"
    static var ADD_ONS = "Add-ons"
    static var PAST_ORDERS = "Past Orders"
    static var ALL = "All"
    static var TODAY = "Today"
    static var YESTERDAY = "Yesterday"
    static var LAST_WEEK = "Last Week"
    static var CURRENT_MONTH = "Current Month"
    static var ACCEPTED = "Accepted"
    static var CANCELLED = "Cancelled"
    static var DECLINED = "Declined"
    static var CANCEL_NOTE = "Order cancel due to this reason"
    static var COMPLETED = "Completed"
    static var COMPLETE = "Complete"
    static var COMPLETED_AMOUNT = "Completed Amount"
    static var DECLINED_AMOUNT = "Declined Amount"
    static var HOLIDAY_IN_RESTAURANT = "Holidays in restaurant"
    static var OPENING_TIME = "Opening Time"
    static var CLOSING_TIME = "Closing Time"
    static var HOLIDAY = "Holiday in restaurant"
    static var SUNDAY = "Sunday"
    static var MONDAY = "Monday"
    static var TUESDAY = "Tuesday"
    static var WEDNESDAY = "Wednesday"
    static var THURSDAY = "Thursday"
    static var FRIDAY = "Friday"
    static var SATURDAY = "Saturday"
    static var WRITE_FEEDBACK = "Write your feedback here"
    static var TYPE_REPLY = "Type here reply..."
    static var REPLY = "Reply"
    static var PROFILE = "Profile"
    static var PUSH_NOTIFICATION = "Push Notification"
    static var SUPPORT = "Support"
    static var TERMS_CONDITIONS = "Terms & Conditions"
    static var PRIVACY_POLICY = "Privacy Policy"
    static var COOKIE_POLICY = "Cookies Policy"
    static var VERSION = "Version"
    static var LOCATION = "Location"
    static var STREET = "Street"
    static var STREET_LINE2 = "Street Line 2"
    static var ZIPCODE = "Zipcode"
    static var PROVINCE = "Province"
    static var COUNTRY = "Country"
    static var CHANGE_PASS = "Change Password"
    static var OLD_PASS = "Old Password"
    static var NEW_PASS = "New Password"
    static var CONFIRM_PASSWORD = "Confirm Password"
    static var UPDATE = "Update"
    static var NOTIFICATION = "Notification"
    static var ORDER_NOTIFICATION = "ORDER NOTIFICATION"
    static var EMAIL_NOTIFICATION = "Email Notification"
    static var SCANNER = "Scanner"
    static var APPROACH_QR_CODE = "Approach the QR Code"
    static var ADD_POINT = "Add Point"
    static var CUST_INFO = "Customer Information"
    static var ENTER_MANGALS = "Enter mangals below"
    static var SEND_QUERY_TEAM = "Enter your query to send support team"
    static var SEND = "Send"
    static var WRITE_QUERY_HERE = "Write your query here"
    static var ERROR = "Error"
    static var WARNING = "Warning"
    static var SUCCESS = "Success"
    static var CHECK_INTERNET = "Please check your internet connection"
    static var WENT_WRONG = "Something went wrong"
    static var VAILD_EMAIL = "Provide Valid Email Address"
    static var PROVIDE_PASS = "Provide Password"
    static var PROVIDE_EMAIL = "Provide Email address"
    static var PROVIDE_OLD_PASS = "Provide old password"
    static var PROVIDE_NEW_PASS = "Provide new password"
    static var PASS_NOT_MATCH = "Password and confirm passoword doesn't match"
    static var PLEASE_ENTER_MANGAL = "Please enter mangals"
    static var CASH_ON_DELIVERY = "Cash On Delivery"
    static var DELIVERY_TIME = "Delivery Time"
    static var SELECT_LANGUAGE = "Select Language"
    static var ORDER_TIME = "Order Time"
    
    static var ITEM_TOTAL = "Item Total"
    static var DELIVERY_CHARGE = "Delivery Charge"
    static var TOTAL_PAYABLE_AMT = "TOTAL_PAYABLE_AMT"
    
    static var LAST_ORDER_ON="Last order on"
    static var NUMBER_OF_PAST_ORDER="Number of previous orders"
    static var NEW_CUSTOMER="New customer"
    static var COOKING_LEVEL="Cooking Level"
    
    static var UPGRADE_APP = "Upgrade App"
    static var UPGRADE_MESSAGE = "Look like you have an older version of the app. Please update to get latest features and experience."
    

    static var FNAME="First Name"
    static var LNAME="Last Name"
    static var PHONE_NUMBER="Cellular Phone Number"
    static var COMPANY = "Company"
    static var STORE = "Store"
    
    static var PROVIDE_FNAME="Provide First Name"
    static var PROVIDE_LNAME="Provide Last Name"
    
    static var ENTER_COMPANY = "Please select company"
    static var ENTER_STORE = "Please enter store"
    
    
    static var JOIN_US = "Join with us"
    static var REGISTER = "REGISTER"
    
    static var LOGIN_FLOW = "You already have an acount? Login"
    static var REGISTER_FLOW = "Don't have an account? Sign Up"
    
    static var SELECT_STORE = "Select Store"
    static var SELECT_COMPANY = "Select Company"
    
    static var NO_REVIEW_FOUND = "No review found"
    static var INVOICE_DETAIL = "Invoice Detail"
    static var ITEMS = "Items"
    
    static var CUSTOMER_RECEIVE_THIS_POINTS1 = "Customer will receive"
    static var CUSTOMER_RECEIVE_THIS_POINTS2 = "points for this order"
    
    static var CONFIRMATION_ORDER_DISABLE = "Are you sure you want to disable accepting orders?"
    static var YES_LABEL = "Yes"
    static var NO_LABEL = "No"
    
    static var TABLE_BOOKING = "Table Booking"
    static var TODAY_TABLE_BOOKING = "Today's Table Bookings"
    static var NEW = "New"
    static var ARRIVED = "Arrived"
    static var LEFT = "Left"
    static var REJECT = "Rejected"
    static var ORDERS = "Orders"
    static var APPROVED = "Accepted"
    static var ONGOING = "Ongoing"
    static var TABLE_NOT_FOUND = "Table booking not found"
    static var STATUS = "Status"
    static var NEXT = "Next"
    static var CURRENT = "Current"
    static var BOOKING_TYPE = "Booking type"
    static var ALL_SERVICE = "All Service"
    static var LUNCH = "Lunch"
    static var DINNER = "Dinner"
    static var SELECT_SERVICE = "Select Service"
    static var PENDING = "Pending"
    static var SPECIAL_REQ = "Special request"
    static var RESERVED = "Reserved"
    
    static var CANCELLATION_NOTE = "Cancellation note"
    
    static var REJECT_TBL_RESERVATION = "Reject Table Reservation"
    static var WRITE_TBL_REJECTION_MSG = "Please write rejection message"
    static var REJECTS = "Reject"
    
    static var TBL_BOOKING_SETTING = "Table Booking Setting"
    static var AVG_MEAL_TIME_HR = "Average meal time hour"
    static var AVG_MEAL_TIME_MIN = "Average meal time minute"
    static var TOT_SEAT_CAPACITY = "Total Seating Capacity"
    static var ENTER_HR = "Enter Hours"
    static var ENTER_MIN = "Enter Minutes"
    static var ENER_SEAT_CAPACITY = "Enter Seating Capacity"
    static var NO_OF_PERSON_COME = "No. of persons will come"
    static var NO_OF_SEAT_AVAILABLE = "No. of seats available"
    static var AVG_MEAL_TIME = "avg. meal time"
    static var ENTER_UR_REPLY = "Enter your reply"
    static var PLZ_ENTER_UR_REPLY = "Please enter reply"
    
}
