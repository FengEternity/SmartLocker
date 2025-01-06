import QtQml 2.15

QtObject {
    // General
    property string appTitle: "Smart Locker System"
    property string settings: "Settings"
    property string confirm: "Confirm"
    property string cancel: "Cancel"
    property string error: "Error"
    property string success: "Success"
    property string warning: "Warning"
    
    // Theme switching
    property string switchToLight: "Switch to Light Theme"
    property string switchToDark: "Switch to Dark Theme"
    property string switchToEnglish: "Switch to English"
    property string switchToChinese: "切换到中文"
    
    // Login related
    property string login: "Login"
    property string logout: "Logout"
    property string register: "Register"
    property string username: "Username"
    property string password: "Password"
    property string phoneNumber: "Phone Number"
    property string usernamePlaceholder: "Enter phone number"
    property string passwordPlaceholder: "Enter password"
    
    // Page titles
    property string courierHome: "Courier Home"
    property string adminHome: "Admin Home"
    property string userHome: "User Home"
    
    // Courier page
    property string enterPackageInfo: "Enter Package Information"
    property string receiverPhone: "Receiver's Phone"
    property string selectLocker: "Select Locker"
    property string lockerNumber: "Locker No."
    property string depositPackage: "Deposit Package"
    property string depositSuccess: "Package Deposited Successfully!"
    property string pickupCode: "Pickup Code"
    property string depositFailed: "Deposit Failed"
    
    // Admin page
    property string modifyLockerStatus: "Modify Locker Status"
    property string refreshOverdue: "Refresh Overdue"
    property string overdueList: "Overdue Packages"
    property string noOverduePackages: "No Overdue Packages"
    property string userRatings: "User Ratings"
    property string refresh: "Refresh"
    property string noRatings: "No Ratings Yet"
    
    // User page
    property string enterPickupCode: "Enter Pickup Code"
    property string pickup: "Pickup"
    property string pickupSuccess: "Pickup Successful!"
    property string pickupFailed: "Pickup Failed"
    property string queryPickupCode: "Enter Phone Number to Query Pickup Code"
    property string queryCode: "Query Code"
    property string rateService: "Rate Service"
    property string submitRating: "Submit Rating"
    property string ratingScore: "Rate Our Service"
    property string ratingComment: "Enter Your Comment (Optional)"
    
    // Locker status
    property string statusEmpty: "Empty"
    property string statusOccupied: "Occupied"
    property string statusMaintenance: "Maintenance"
    
    // Role selection
    property string roleCourier: "Courier"
    property string roleAdmin: "Administrator"
    property string roleUser: "User"
    
    // Login page
    property string loginTitle: "Login"
    property string loginFailed: "Login Failed"
    property string loginSuccess: "Login Successful"
    
    // Register page
    property string registerTitle: "Register"
    property string registerSuccess: "Registration Successful"
    property string registerFailed: "Registration Failed"
    property string passwordConfirm: "Confirm Password"
    property string passwordMismatch: "Passwords do not match"
    property string phoneInvalid: "Please enter a valid phone number"
    property string userExists: "Phone number already registered"
    
    // Courier page additions
    property string packageQuery: "Package Query"
    property string enterPhoneToQuery: "Enter phone number to query packages"
    property string query: "Query"
    property string noPackagesFound: "No packages found"
    property string lockerNumberPrefix: "Locker No.: "
    
    // Dialogs
    property string depositResult: "Deposit Result"
    property string queryResult: "Query Result"
    property string ok: "OK"
    property string close: "Close"
    
    // Rating options
    property string rating5: "5 - Excellent"
    property string rating4: "4 - Good"
    property string rating3: "3 - Average"
    property string rating2: "2 - Poor"
    property string rating1: "1 - Very Poor"
    property string thankForRating: "Thank you for your rating!"
    property string ratingFailed: "Failed to submit rating, please try again later"
    
    // Overdue packages
    property string overduePackagesTitle: "Overdue Packages Notice"
    property string overduePackagesNotice: "You have the following overdue packages, please pick them up as soon as possible:"
} 