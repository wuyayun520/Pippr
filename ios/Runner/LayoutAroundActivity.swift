
//: Declare String Begin

/*: "bageny" :*/
fileprivate let mainProtectionData:[Character] = ["b","a","g","e","n","y"]

/*: "https://m. :*/
fileprivate let notiElementStr:String = "contactt"
fileprivate let appTingContent:String = "ps://m.indicator again take map mirror"

/*: .com" :*/
fileprivate let showRemoteUserFormat:String = ".comestablish local native info manager"

/*: "1.9.1" :*/
fileprivate let constReduceRawId:String = "1.shared.1"

/*: "987" :*/
fileprivate let user_bodyFormat:[Character] = ["9","8","7"]

/*: "fj08toscxiww" :*/
fileprivate let dataToUrl:String = "fj08tapplications"
fileprivate let notiTrackKey:String = "cpoorww"

/*: "d658jw" :*/
fileprivate let app_toolUrl:[Character] = ["d","6","5","8","j"]
fileprivate let show_keySucceedText:String = "operation"

/*: "CFBundleShortVersionString" :*/
fileprivate let showItemData:String = "import global flexible forget requestCFBun"
fileprivate let app_netFormat:[Character] = ["t","V","e","r","s","i","o","n","S","t","r","i","n","g"]

/*: "CFBundleDisplayName" :*/
fileprivate let constIndexText:[Character] = ["C","F","B","u","n","d","l","e","D","i","s"]
fileprivate let constRemotePostFormat:[Character] = ["p"]
fileprivate let notiYourTitle:String = "display return now style withlayName"

/*: "CFBundleVersion" :*/
fileprivate let dataCornerName:String = "CFBunad user network"
fileprivate let app_establishData:String = "sifinishn"

/*: "weixin" :*/
fileprivate let kOptionTitle:[Character] = ["w","e","i","x","i"]
fileprivate let app_succeedNetFormat:String = "challenge"

/*: "wxwork" :*/
fileprivate let k_versionFormat:String = "neverwork"

/*: "dingtalk" :*/
fileprivate let notiAppearContent:[Character] = ["d","i","n","g","t","a","l","k"]

/*: "lark" :*/
fileprivate let kInsertTitle:[Character] = ["l","a","r","k"]

//: Declare String End

// __DEBUG__
// __CLOSE_PRINT__
//
//  LayoutAroundActivity.swift
//  OverseaH5
//
//  Created by young on 2025/9/24.
//

//: import KeychainSwift
import KeychainSwift
//: import UIKit
import UIKit

/// 域名
//: let ReplaceUrlDomain = "bageny"
let constAdKey = (String(mainProtectionData))
//: let H5WebDomain = "https://m.\(ReplaceUrlDomain).com"
let main_indicatorText = (notiElementStr.replacingOccurrences(of: "contact", with: "ht") + String(appTingContent.prefix(7))) + "\(constAdKey)" + (String(showRemoteUserFormat.prefix(4)))
/// 网络版本号
//: let AppNetVersion = "1.9.1"
let mainTimeFormat = (constReduceRawId.replacingOccurrences(of: "shared", with: "9"))
/// 包ID
//: let PackageID = "987"
let constIdentityTitle = (String(user_bodyFormat))
/// Adjust
//: let AdjustKey = "fj08toscxiww"
let notiRootStr = (dataToUrl.replacingOccurrences(of: "application", with: "o") + notiTrackKey.replacingOccurrences(of: "poor", with: "xi"))
//: let AdInstallToken = "d658jw"
let constNetTitle = (String(app_toolUrl) + show_keySucceedText.replacingOccurrences(of: "operation", with: "w"))

//: let AppVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
let constInstallTitle = Bundle.main.infoDictionary![(String(showItemData.suffix(5)) + "dleShor" + String(app_netFormat))] as! String
//: let AppBundle = Bundle.main.bundleIdentifier!
let userGenerateText = Bundle.main.bundleIdentifier!
//: let AppName = Bundle.main.infoDictionary!["CFBundleDisplayName"] ?? ""
let app_maxTotalFormat = Bundle.main.infoDictionary![(String(constIndexText) + String(constRemotePostFormat) + String(notiYourTitle.suffix(7)))] ?? ""
//: let AppBuildNumber = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
let data_logMessage = Bundle.main.infoDictionary![(String(dataCornerName.prefix(5)) + "dleVer" + app_establishData.replacingOccurrences(of: "finish", with: "o"))] as! String

//: class AppConfig: NSObject {
class LayoutAroundActivity: NSObject {
    /// 获取状态栏高度
    //: class func getStatusBarHeight() -> CGFloat {
    class func decision() -> CGFloat {
        //: if #available(iOS 13.0, *) {
        if #available(iOS 13.0, *) {
            //: if let statusBarManager = UIApplication.shared.windows.first?
            if let statusBarManager = UIApplication.shared.windows.first?
                //: .windowScene?.statusBarManager
                .windowScene?.statusBarManager
            {
                //: return statusBarManager.statusBarFrame.size.height
                return statusBarManager.statusBarFrame.size.height
            }
            //: } else {
        } else {
            //: return UIApplication.shared.statusBarFrame.size.height
            return UIApplication.shared.statusBarFrame.size.height
        }
        //: return 20.0
        return 20.0
    }

    /// 获取window
    //: class func getWindow() -> UIWindow {
    class func margin() -> UIWindow {
        //: var window = UIApplication.shared.windows.first(where: {
        var window = UIApplication.shared.windows.first(where: {
            //: $0.isKeyWindow
            $0.isKeyWindow
            //: })
        })
        // 是否为当前显示的window
        //: if window?.windowLevel != UIWindow.Level.normal {
        if window?.windowLevel != UIWindow.Level.normal {
            //: let windows = UIApplication.shared.windows
            let windows = UIApplication.shared.windows
            //: for windowTemp in windows {
            for windowTemp in windows {
                //: if windowTemp.windowLevel == UIWindow.Level.normal {
                if windowTemp.windowLevel == UIWindow.Level.normal {
                    //: window = windowTemp
                    window = windowTemp
                    //: break
                    break
                }
            }
        }
        //: return window!
        return window!
    }

    /// 获取当前控制器
    //: class func currentViewController() -> (UIViewController?) {
    class func afoot() -> (UIViewController?) {
        //: var window = AppConfig.getWindow()
        var window = LayoutAroundActivity.margin()
        //: if window.windowLevel != UIWindow.Level.normal {
        if window.windowLevel != UIWindow.Level.normal {
            //: let windows = UIApplication.shared.windows
            let windows = UIApplication.shared.windows
            //: for windowTemp in windows {
            for windowTemp in windows {
                //: if windowTemp.windowLevel == UIWindow.Level.normal {
                if windowTemp.windowLevel == UIWindow.Level.normal {
                    //: window = windowTemp
                    window = windowTemp
                    //: break
                    break
                }
            }
        }
        //: let vc = window.rootViewController
        let vc = window.rootViewController
        //: return currentViewController(vc)
        return event(vc)
    }

    //: class func currentViewController(_ vc: UIViewController?)
    class func event(_ vc: UIViewController?)
        //: -> UIViewController?
        -> UIViewController?
    {
        //: if vc == nil {
        if vc == nil {
            //: return nil
            return nil
        }
        //: if let presentVC = vc?.presentedViewController {
        if let presentVC = vc?.presentedViewController {
            //: return currentViewController(presentVC)
            return event(presentVC)
            //: } else if let tabVC = vc as? UITabBarController {
        } else if let tabVC = vc as? UITabBarController {
            //: if let selectVC = tabVC.selectedViewController {
            if let selectVC = tabVC.selectedViewController {
                //: return currentViewController(selectVC)
                return event(selectVC)
            }
            //: return nil
            return nil
            //: } else if let naiVC = vc as? UINavigationController {
        } else if let naiVC = vc as? UINavigationController {
            //: return currentViewController(naiVC.visibleViewController)
            return event(naiVC.visibleViewController)
            //: } else {
        } else {
            //: return vc
            return vc
        }
    }
}

// MARK: - Device

//: extension UIDevice {
extension UIDevice {
    //: static var modelName: String {
    static var modelName: String {
        //: var systemInfo = utsname()
        var systemInfo = utsname()
        //: uname(&systemInfo)
        uname(&systemInfo)
        //: let machineMirror = Mirror(reflecting: systemInfo.machine)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        //: let identifier = machineMirror.children.reduce("") {
        let identifier = machineMirror.children.reduce("") {
            //: identifier, element in
            identifier, element in
            //: guard let value = element.value as? Int8, value != 0 else {
            guard let value = element.value as? Int8, value != 0 else {
                //: return identifier
                return identifier
            }
            //: return identifier + String(UnicodeScalar(UInt8(value)))
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        //: return identifier
        return identifier
    }

    /// 获取当前系统时区
    //: static var timeZone: String {
    static var timeZone: String {
        //: let currentTimeZone = NSTimeZone.system
        let currentTimeZone = NSTimeZone.system
        //: return currentTimeZone.identifier
        return currentTimeZone.identifier
    }

    /// 获取当前系统语言
    //: static var langCode: String {
    static var langCode: String {
        //: let language = Locale.preferredLanguages.first
        let language = Locale.preferredLanguages.first
        //: return language ?? ""
        return language ?? ""
    }

    /// 获取接口语言
    //: static var interfaceLang: String {
    static var interfaceLang: String {
        //: let lang = UIDevice.getSystemLangCode()
        let lang = UIDevice.local()
        //: if ["en", "ar", "es", "pt"].contains(lang) {
        if ["en", "ar", "es", "pt"].contains(lang) {
            //: return lang
            return lang
        }
        //: return "en"
        return "en"
    }

    /// 获取当前系统地区
    //: static var countryCode: String {
    static var countryCode: String {
        //: let locale = Locale.current
        let locale = Locale.current
        //: let countryCode = locale.regionCode
        let countryCode = locale.regionCode
        //: return countryCode ?? ""
        return countryCode ?? ""
    }

    /// 获取系统UUID（每次调用都会产生新值，所以需要keychain）
    //: static var systemUUID: String {
    static var systemUUID: String {
        //: let key = KeychainSwift()
        let key = KeychainSwift()
        //: if let value = key.get(AdjustKey) {
        if let value = key.get(notiRootStr) {
            //: return value
            return value
            //: } else {
        } else {
            //: let value = NSUUID().uuidString
            let value = NSUUID().uuidString
            //: key.set(value, forKey: AdjustKey)
            key.set(value, forKey: notiRootStr)
            //: return value
            return value
        }
    }

    /// 获取已安装应用信息
    //: static var getInstalledApps: String {
    static var getInstalledApps: String {
        //: var appsArr: [String] = []
        var appsArr: [String] = []
        //: if UIDevice.canOpenApp("weixin") {
        if UIDevice.component((String(kOptionTitle) + app_succeedNetFormat.replacingOccurrences(of: "challenge", with: "n"))) {
            //: appsArr.append("weixin")
            appsArr.append((String(kOptionTitle) + app_succeedNetFormat.replacingOccurrences(of: "challenge", with: "n")))
        }
        //: if UIDevice.canOpenApp("wxwork") {
        if UIDevice.component((k_versionFormat.replacingOccurrences(of: "never", with: "wx"))) {
            //: appsArr.append("wxwork")
            appsArr.append((k_versionFormat.replacingOccurrences(of: "never", with: "wx")))
        }
        //: if UIDevice.canOpenApp("dingtalk") {
        if UIDevice.component((String(notiAppearContent))) {
            //: appsArr.append("dingtalk")
            appsArr.append((String(notiAppearContent)))
        }
        //: if UIDevice.canOpenApp("lark") {
        if UIDevice.component((String(kInsertTitle))) {
            //: appsArr.append("lark")
            appsArr.append((String(kInsertTitle)))
        }
        //: if appsArr.count > 0 {
        if appsArr.count > 0 {
            //: return appsArr.joined(separator: ",")
            return appsArr.joined(separator: ",")
        }
        //: return ""
        return ""
    }

    /// 判断是否安装app
    //: static func canOpenApp(_ scheme: String) -> Bool {
    static func component(_ scheme: String) -> Bool {
        //: let url = URL(string: "\(scheme)://")!
        let url = URL(string: "\(scheme)://")!
        //: if UIApplication.shared.canOpenURL(url) {
        if UIApplication.shared.canOpenURL(url) {
            //: return true
            return true
        }
        //: return false
        return false
    }

    /// 获取系统语言
    /// - Returns: 国际通用语言Code
    //: @objc public class func getSystemLangCode() -> String {
    @objc public class func local() -> String {
        //: let language = NSLocale.preferredLanguages.first
        let language = NSLocale.preferredLanguages.first
        //: let array = language?.components(separatedBy: "-")
        let array = language?.components(separatedBy: "-")
        //: return array?.first ?? "en"
        return array?.first ?? "en"
    }
}
