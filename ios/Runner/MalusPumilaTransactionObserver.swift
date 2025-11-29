
//: Declare String Begin

/*: "mf/recharge/createApplePay" :*/
fileprivate let kStopId:String = "in enable black safemf/rec"
fileprivate let appBlockNetLargeStr:String = "createAlanguage confirm height phone make"
fileprivate let k_generateTitle:String = "pplePayscene go build if"

/*: "productId" :*/
fileprivate let notiNetworkMessage:String = "result production total auto progressproductId"

/*: "source" :*/
fileprivate let constCarrierDecideMessage:[Character] = ["s","o","u","r","c","e"]

/*: "orderNum" :*/
fileprivate let showFromMsg:String = "oenterde"

/*: "mf/recharge/applePayNotify" :*/
fileprivate let data_eventScreenValue:[Character] = ["m","f","/","r","e","c","h","a","r","g","e","/"]
fileprivate let const_privacyStr:String = "response no progress autoappleP"
fileprivate let noti_largeUrl:String = "clickify"

/*: "reportMoney" :*/
fileprivate let mainTingData:[Character] = ["r","e","p","o","r","t","M","o","n","e"]
fileprivate let constMicZoneValue:String = "group"

/*: "transactionId" :*/
fileprivate let showLaterLinkUrl:[Character] = ["t","r","a","n","s","a","c"]
fileprivate let user_networkKey:String = "adjustment product top tool triggertionId"

/*: "mf/AutoSub/AppleCreateOrder" :*/
fileprivate let data_screenRatingMessage:[Character] = ["m","f","/","A","u","t","o","S","u","b","/","A","p","p","l","e","C","r","e","a","t","e","O","r","d","e","r"]

/*: "orderId" :*/
fileprivate let app_cornerCancelValue:[UInt8] = [0xa9,0xac,0x9e,0x9f,0xac,0x83,0x9e]

fileprivate func failureWill(sound num: UInt8) -> UInt8 {
    let value = Int(num) - 58
    if value < 0 {
        return UInt8(value + 256)
    } else {
        return UInt8(value)
    }
}

/*: "mf/AutoSub/ApplePaySuccess" :*/
fileprivate let showActionText:[Character] = ["m","f","/","A","u","t","o","S","u","b","/","A","p","p","l","e","P","a","y","S","u","c","c","e","s"]
fileprivate let k_warnContent:[Character] = ["s"]

/*: "App" :*/
fileprivate let dataProcessTitle:[Character] = ["A","p","p"]

/*: "OrderTransactionInfo_Cache" :*/
fileprivate let noti_arrowByTitle:String = "Orderblack frame"
fileprivate let appModelKey:[Character] = ["T","r"]
fileprivate let kPleaseText:String = "keynskeyct"
fileprivate let app_deviceUrl:String = "list sourcefo_Cache"

/*: "OrderTransactionInfo_Subscribe_Cache" :*/
fileprivate let main_trustKey:[UInt8] = [0xc0,0xe3,0xd5,0xd6,0xe3,0xc5,0xe3,0xd2,0xdf,0xe4,0xd2,0xd4,0xe5,0xda,0xe0,0xdf,0xba,0xdf,0xd7,0xe0,0xd0,0xc4,0xe6,0xd3,0xe4,0xd4,0xe3,0xda,0xd3,0xd6,0xd0,0xb4,0xd2,0xd4,0xd9,0xd6]

fileprivate func adjustmentLevel(data num: UInt8) -> UInt8 {
    let value = Int(num) + 143
    if value > 255 {
        return UInt8(value - 256)
    } else {
        return UInt8(value)
    }
}

/*: "verifyData" :*/
fileprivate let showWillKey:[UInt8] = [0x91,0x80,0x8d,0x84,0x81,0x94,0x5f,0x7c,0x8f,0x7c]

fileprivate func showBlock(link num: UInt8) -> UInt8 {
    let value = Int(num) + 229
    if value > 255 {
        return UInt8(value - 256)
    } else {
        return UInt8(value)
    }
}

/*: " 未知的交易类型" :*/
fileprivate let k_poorMKey:String = " 未知\u{7684}"
fileprivate let data_schemeUrl:[Character] = ["交","易","类","型"]

//: Declare String End

//: import StoreKit
import StoreKit
// __DEBUG__
// __CLOSE_PRINT__
//: import UIKit
import UIKit

// 最大失败重试次数
//: let APPLE_IAP_MAX_RETRY_COUNT = 9
let appTimeSkipValue = 9

/// 支付类型
//: enum ApplePayType {
enum ActionType {
    //: case Pay
    case Pay // 支付
    //: case Subscribe
    case Subscribe // 订阅
}

/// 支付状态
//: enum AppleIAPStatus: String {
enum ResponseOutputStreamable: String {
    //: case unknow            = "未知类型"
    case unknow = "未知类型"
    //: case createOrderFail   = "创建订单失败"
    case createOrderFail = "创建订单失败"
    //: case notArrow          = "设备不允许"
    case notArrow = "设备不允许"
    //: case noProductId       = "缺少产品Id"
    case noProductId = "缺少产品Id"
    //: case failed            = "交易失败/取消"
    case failed = "交易失败/取消"
    //: case restored          = "已购买过该商品"
    case restored = "已购买过该商品"
    //: case deferred          = "交易延期"
    case deferred = "交易延期"
    //: case verityFail        = "服务器验证失败"
    case verityFail = "服务器验证失败"
    //: case veritySucceed     = "服务器验证成功"
    case veritySucceed = "服务器验证成功"
    //: case renewSucceed      = "自动续订成功"
    case renewSucceed = "自动续订成功"
}

//: typealias IAPcompletionHandle = (AppleIAPStatus, Double, ApplePayType) -> Void
typealias IAPcompletionHandle = (ResponseOutputStreamable, Double, ActionType) -> Void

//: class AppleIAPManager: NSObject {
class MalusPumilaTransactionObserver: NSObject {
    //: var completionHandle: IAPcompletionHandle?
    var completionHandle: IAPcompletionHandle?
    //: private var productInfoReq: SKProductsRequest?
    private var productInfoReq: SKProductsRequest?
    //: private var reqRetryCountDict = [String: Int]()
    private var reqRetryCountDict = [String: Int]() // 记录每个交易请求重试次数
    //: private var payCacheList = [[String: String]]()
    private var payCacheList = [[String: String]]() // 【购买】缓存数据
    //: private var subscribeCacheList = [[String: String]]()
    private var subscribeCacheList = [[String: String]]() // 【订阅】缓存数据
    //: private var createOrderId: String?
    private var createOrderId: String? // 当前支付服务端创建的订单id
    //: private var currentPayType: ApplePayType = .Pay
    private var currentPayType: ActionType = .Pay // 当前支付类型

    // singleton
    //: static let shared = AppleIAPManager()
    static let shared = MalusPumilaTransactionObserver()
    //: override func copy() -> Any { return self }
    override func copy() -> Any { return self }
    //: override func mutableCopy() -> Any { return self }
    override func mutableCopy() -> Any { return self }
    //: private override init() {
    override private init() {
        //: super.init()
        super.init()
        //: SKPaymentQueue.default().add(self as SKPaymentTransactionObserver)
        SKPaymentQueue.default().add(self as SKPaymentTransactionObserver)
        // 监听应用将要销毁
        //: NotificationCenter.default.addObserver(self, selector: #selector(appWillTerminate),
        NotificationCenter.default.addObserver(self, selector: #selector(globalTerminate),
                                               //: name: UIApplication.willTerminateNotification,
                                               name: UIApplication.willTerminateNotification,
                                               //: object: nil)
                                               object: nil)
    }

    // MARK: - NotificationCenter

    //: @objc func appWillTerminate() {
    @objc func globalTerminate() {
        //: SKPaymentQueue.default().remove(self as SKPaymentTransactionObserver)
        SKPaymentQueue.default().remove(self as SKPaymentTransactionObserver)
    }
}

// MARK: - 【苹果购买】业务接口

//: extension AppleIAPManager {
private extension MalusPumilaTransactionObserver {
    /// 【购买】创建业务订单
    /// - Parameters:
    ///   - productId: 产品Id
    ///   - block: 回调
    //: fileprivate func req_pay_createAppleOrder(productId: String, source: Int, handle: @escaping (String?, Bool) -> Void) {
    func pic(productId: String, source: Int, handle: @escaping (String?, Bool) -> Void) {
        //: let reqModel = AppRequestModel.init()
        let reqModel = WorldWideRequestModel()
        //: reqModel.requestPath = "mf/recharge/createApplePay"
        reqModel.requestPath = (String(kStopId.suffix(6)) + "harge/" + String(appBlockNetLargeStr.prefix(7)) + String(k_generateTitle.prefix(7)))
        //: var dict = Dictionary<String, Any>()
        var dict = [String: Any]()
        //: dict["productId"] = productId
        dict[(String(notiNetworkMessage.suffix(9)))] = productId
        //: dict["source"] = source
        dict[(String(constCarrierDecideMessage))] = source
        //: reqModel.params = dict
        reqModel.params = dict
        //: AppRequestTool.startPostRequest(model: reqModel) { succeed, result, errorModel in
        DirectRequestTool.ingotText(model: reqModel) { succeed, result, _ in
            //: guard succeed == true else {
            guard succeed == true else {
                //: handle(nil, succeed)
                handle(nil, succeed)
                //: return
                return
            }

            //: var orderId: String?
            var orderId: String?
            //: let dict = result as? [String: Any]
            let dict = result as? [String: Any]
            //: if let value = dict?["orderNum"] as? String {
            if let value = dict?[(showFromMsg.replacingOccurrences(of: "enter", with: "r") + "rNum")] as? String {
                //: orderId = value
                orderId = value
            }
            //: handle(orderId, succeed)
            handle(orderId, succeed)
        }
    }

    /// 【购买】上传支付信息到服务器验证
    /// - Parameters:
    ///   - transaction: 交易信息
    ///   - params: 接口参数
    //: fileprivate func req_pay_uploadAppletransaction(_ transactionId: String, params: [String: String]) {
    func post(_ transactionId: String, params: [String: String]) {
        //: let reqModel = AppRequestModel.init()
        let reqModel = WorldWideRequestModel()
        //: reqModel.requestPath = "mf/recharge/applePayNotify"
        reqModel.requestPath = (String(data_eventScreenValue) + String(const_privacyStr.suffix(6)) + "ayNo" + noti_largeUrl.replacingOccurrences(of: "click", with: "t"))
        //: reqModel.params = params
        reqModel.params = params
        //: AppRequestTool.startPostRequest(model: reqModel) { succeed, result, errorModel in
        DirectRequestTool.ingotText(model: reqModel) { succeed, result, errorModel in
            //: guard succeed == true || errorModel?.errorCode == 405 else {
            guard succeed == true || errorModel?.errorCode == 405 else { // 验证接口失败，重试接口
                //: DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                    //: self.transcationPurchasedToCheck(transactionId, .Pay)
                    self.permission(transactionId, .Pay)
                }
                //: return
                return
            }

            //: let dict = result as? [String: Any]
            let dict = result as? [String: Any]
            //: let reportMoney: Double = {
            let reportMoney: Double = {
                //: if let d = dict?["reportMoney"] as? Double { return d }
                if let d = dict?[(String(mainTingData) + constMicZoneValue.replacingOccurrences(of: "group", with: "y"))] as? Double { return d }
                //: return 0
                return 0
                //: }()
            }()

            // 过滤已验证成功的订单数据
            //: let newPayCacheList = self.payCacheList.filter({$0["transactionId"] != transactionId})
            let newPayCacheList = self.payCacheList.filter { $0[(String(showLaterLinkUrl) + String(user_networkKey.suffix(6)))] != transactionId }
            //: let diskPath = self.getPayCachePath()
            let diskPath = self.item()
            //: NSKeyedArchiver.archiveRootObject(newPayCacheList, toFile: diskPath)
            NSKeyedArchiver.archiveRootObject(newPayCacheList, toFile: diskPath)

            // 成功回调
            //: self.completionHandle?(.veritySucceed, reportMoney, .Pay)
            self.completionHandle?(.veritySucceed, reportMoney, .Pay)
        }
    }
}

// MARK: - 【苹果订阅】业务接口

//: extension AppleIAPManager {
private extension MalusPumilaTransactionObserver {
    /// 【订阅】创建业务订单
    /// - Parameters:
    ///   - productId: 产品Id
    ///   - block: 回调
    //: fileprivate func req_subscribe_createAppleOrder(productId: String, source: Int, handle: @escaping (String?, Bool) -> Void) {
    func quantityry(productId: String, source: Int, handle: @escaping (String?, Bool) -> Void) {
        //: let reqModel = AppRequestModel.init()
        let reqModel = WorldWideRequestModel()
        //: reqModel.requestPath = "mf/AutoSub/AppleCreateOrder"
        reqModel.requestPath = (String(data_screenRatingMessage))
        //: var dict = Dictionary<String, Any>()
        var dict = [String: Any]()
        //: dict["productId"] = productId
        dict[(String(notiNetworkMessage.suffix(9)))] = productId
        //: dict["source"] = source
        dict[(String(constCarrierDecideMessage))] = source
        //: reqModel.params = dict
        reqModel.params = dict
        //: AppRequestTool.startPostRequest(model: reqModel) { succeed, result, errorModel in
        DirectRequestTool.ingotText(model: reqModel) { succeed, result, _ in
            //: guard succeed == true else {
            guard succeed == true else {
                //: handle(nil, succeed)
                handle(nil, succeed)
                //: return
                return
            }

            //: var orderId: String? = nil
            var orderId: String?
            //: let dict = result as? [String: Any]
            let dict = result as? [String: Any]
            //: if let value = dict?["orderId"] as? String {
            if let value = dict?[String(bytes: app_cornerCancelValue.map{failureWill(sound: $0)}, encoding: .utf8)!] as? String {
                //: orderId = value
                orderId = value
            }
            //: handle(orderId, succeed)
            handle(orderId, succeed)
        }
    }

    /// 【订阅】上传支付信息到服务器验证
    /// - Parameters:
    ///   - transaction: 交易信息
    ///   - params: 接口参数
    //: fileprivate func req_subscribe_uploadAppletransaction(_ transactionId: String, params: [String: String]) {
    func createFail(_ transactionId: String, params: [String: String]) {
        //: let reqModel = AppRequestModel.init()
        let reqModel = WorldWideRequestModel()
        //: reqModel.requestPath = "mf/AutoSub/ApplePaySuccess"
        reqModel.requestPath = (String(showActionText) + String(k_warnContent))
        //: reqModel.params = params
        reqModel.params = params
        //: AppRequestTool.startPostRequest(model: reqModel) { succeed, result, errorModel in
        DirectRequestTool.ingotText(model: reqModel) { succeed, result, errorModel in
            //: guard succeed == true || errorModel?.errorCode == 405 else {
            guard succeed == true || errorModel?.errorCode == 405 else { // 验证接口失败，重试接口
                //: DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
                    //: self.transcationPurchasedToCheck(transactionId, .Subscribe)
                    self.permission(transactionId, .Subscribe)
                }
                //: return
                return
            }

            //: let dict = result as? [String: Any]
            let dict = result as? [String: Any]
            //: let reportMoney: Double = {
            let reportMoney: Double = {
                //: if let d = dict?["reportMoney"] as? Double { return d }
                if let d = dict?[(String(mainTingData) + constMicZoneValue.replacingOccurrences(of: "group", with: "y"))] as? Double { return d }
                //: return 0
                return 0
                //: }()
            }()

            // 过滤已验证成功的订单数据
            //: let newSubscribeCacheList = self.subscribeCacheList.filter({$0["transactionId"] != transactionId})
            let newSubscribeCacheList = self.subscribeCacheList.filter { $0[(String(showLaterLinkUrl) + String(user_networkKey.suffix(6)))] != transactionId }
            //: let diskPath = self.getSubscribeCachePath()
            let diskPath = self.panelPath()
            //: NSKeyedArchiver.archiveRootObject(newSubscribeCacheList, toFile: diskPath)
            NSKeyedArchiver.archiveRootObject(newSubscribeCacheList, toFile: diskPath)

            // 成功回调
            //: self.completionHandle?(.veritySucceed, reportMoney, .Subscribe)
            self.completionHandle?(.veritySucceed, reportMoney, .Subscribe)
        }
    }
}

// MARK: - Event

//: extension AppleIAPManager {
extension MalusPumilaTransactionObserver {
    /// 初始化数据
    //: private func iap_initData() {
    private func active() {
        //: self.payCacheList = getLocalPayCacheList(payType: .Pay)
        self.payCacheList = camera(payType: .Pay)
        //: self.subscribeCacheList = getLocalPayCacheList(payType: .Subscribe)
        self.subscribeCacheList = camera(payType: .Subscribe)
        //: self.createOrderId = nil
        self.createOrderId = nil
    }

    /// 获取缓存列表
    /// - Parameter payType: 支付类型
    /// - Returns: 缓存列表
    //: private func getLocalPayCacheList(payType: ApplePayType) -> [[String: String]] {
    private func camera(payType: ActionType) -> [[String: String]] {
        //: var list: [[String: String]]?
        var list: [[String: String]]?
        //: var diskPath = ""
        var diskPath = ""
        //: if payType == .Pay {
        if payType == .Pay {
            //: diskPath = getPayCachePath()
            diskPath = item()
            //: } else {
        } else {
            //: diskPath = getSubscribeCachePath()
            diskPath = panelPath()
        }

        //: if FileManager.default.fileExists(atPath: diskPath) {
        if FileManager.default.fileExists(atPath: diskPath) {
            //: list = NSKeyedUnarchiver.unarchiveObject(withFile: diskPath) as? [[String: String]]
            list = NSKeyedUnarchiver.unarchiveObject(withFile: diskPath) as? [[String: String]]
            //: if list == nil {
            if list == nil {
                //: try? FileManager.default.removeItem(atPath: diskPath)
                try? FileManager.default.removeItem(atPath: diskPath)
            }
        }
        //: if list == nil {
        if list == nil {
            //: list = [[String: String]]()
            list = [[String: String]]()
        }
        //: return list!
        return list!
    }

    /// 获取【购买】缓存路径【和uid关联】
    /// - Returns: 缓存路径
    //: private func getPayCachePath() -> String {
    private func item() -> String {
        //: let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""
        //: let appDirectoryPath = (documentDirectoryPath as NSString).appendingPathComponent("App")
        let appDirectoryPath = (documentDirectoryPath as NSString).appendingPathComponent((String(dataProcessTitle)))

        //: let fileManager = FileManager.default
        let fileManager = FileManager.default
        //: if fileManager.fileExists(atPath: appDirectoryPath) == false {
        if fileManager.fileExists(atPath: appDirectoryPath) == false {
            //: try? fileManager.createDirectory(atPath: appDirectoryPath, withIntermediateDirectories: true)
            try? fileManager.createDirectory(atPath: appDirectoryPath, withIntermediateDirectories: true)
        }

        //: let filePath = (appDirectoryPath as NSString).appendingPathComponent("OrderTransactionInfo_Cache")
        let filePath = (appDirectoryPath as NSString).appendingPathComponent((String(noti_arrowByTitle.prefix(5)) + String(appModelKey) + kPleaseText.replacingOccurrences(of: "key", with: "a") + "ionIn" + String(app_deviceUrl.suffix(8))))
        //: return filePath
        return filePath
    }

    /// 获取【订阅】缓存路径【和uid关联】
    /// - Returns: 缓存路径
    //: private func getSubscribeCachePath() -> String {
    private func panelPath() -> String {
        //: let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""
        //: let appDirectoryPath = (documentDirectoryPath as NSString).appendingPathComponent("App")
        let appDirectoryPath = (documentDirectoryPath as NSString).appendingPathComponent((String(dataProcessTitle)))

        //: let fileManager = FileManager.default
        let fileManager = FileManager.default
        //: if fileManager.fileExists(atPath: appDirectoryPath) == false {
        if fileManager.fileExists(atPath: appDirectoryPath) == false {
            //: try? fileManager.createDirectory(atPath: appDirectoryPath, withIntermediateDirectories: true)
            try? fileManager.createDirectory(atPath: appDirectoryPath, withIntermediateDirectories: true)
        }

        //: let filePath = (appDirectoryPath as NSString).appendingPathComponent("OrderTransactionInfo_Subscribe_Cache")
        let filePath = (appDirectoryPath as NSString).appendingPathComponent(String(bytes: main_trustKey.map{adjustmentLevel(data: $0)}, encoding: .utf8)!)
        //: return filePath
        return filePath
    }

    /// 获取本地收据数据
    /// - Parameters:
    ///   - transactionId: 收据标识符
    ///   - payType: 支付类型
    /// - Returns: 收据数据
    //: fileprivate func getVerifyData(_ transactionId: String, _ payType: ApplePayType) -> String? {
    fileprivate func create(_ transactionId: String, _ payType: ActionType) -> String? {
        // 有未完成的订单，先取缓存
        //: var paramsArr = [[String: String]]()
        var paramsArr = [[String: String]]()
        //: switch(payType) {
        switch payType {
        //: case .Pay:
        case .Pay:
            //: paramsArr = self.payCacheList.filter({$0["transactionId"] == transactionId})
            paramsArr = self.payCacheList.filter { $0[(String(showLaterLinkUrl) + String(user_networkKey.suffix(6)))] == transactionId }
        //: case .Subscribe:
        case .Subscribe:
            //: paramsArr = self.subscribeCacheList.filter({$0["transactionId"] == transactionId})
            paramsArr = self.subscribeCacheList.filter { $0[(String(showLaterLinkUrl) + String(user_networkKey.suffix(6)))] == transactionId }
        }
        //: if paramsArr.count > 0 && paramsArr.first!["verifyData"] != nil {
        if paramsArr.count > 0, paramsArr.first![String(bytes: showWillKey.map{showBlock(link: $0)}, encoding: .utf8)!] != nil {
            //: return paramsArr.first!["verifyData"]
            return paramsArr.first![String(bytes: showWillKey.map{showBlock(link: $0)}, encoding: .utf8)!]
        }

        // 取本地
        //: guard let receiptUrl = Bundle.main.appStoreReceiptURL else { return nil }
        guard let receiptUrl = Bundle.main.appStoreReceiptURL else { return nil }
        //: let data = NSData(contentsOf: receiptUrl)
        let data = NSData(contentsOf: receiptUrl)
        //: let receiptStr = data?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        let receiptStr = data?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        //: return receiptStr
        return receiptStr
    }
}

// MARK: - 失败重试流程

//: extension AppleIAPManager {
extension MalusPumilaTransactionObserver {
    /// 检测未完成的苹果支付【只会重试当前登录用户】
    //: func iap_checkUnfinishedTransactions() {
    func confirm() {
        //: iap_initData()
        active()

        // 【购买】失败重试
        //: for dict in self.payCacheList {
        for dict in self.payCacheList {
            //: iap_failedRetry(dict["transactionId"], .Pay)
            recordRetry(dict[(String(showLaterLinkUrl) + String(user_networkKey.suffix(6)))], .Pay)
        }

        // 【订阅】失败重试
        //: for dict in self.subscribeCacheList {
        for dict in self.subscribeCacheList {
            //: iap_failedRetry(dict["transactionId"], .Subscribe)
            recordRetry(dict[(String(showLaterLinkUrl) + String(user_networkKey.suffix(6)))], .Subscribe)
        }
    }

    /// 失败重试
    /// - Parameters:
    ///   - transactionId: Id
    ///   - payType: 支付类型
    //: private func iap_failedRetry(_ transactionId: String?, _ payType: ApplePayType) {
    private func recordRetry(_ transactionId: String?, _ payType: ActionType) {
        //: guard let transactionId = transactionId else { return }
        guard let transactionId = transactionId else { return }
        // 初始化每个交易请求次数
        //: reqRetryCountDict[transactionId] = 0
        reqRetryCountDict[transactionId] = 0
        // 3. 服务端校验流程
        //: transcationPurchasedToCheck(transactionId, payType)
        permission(transactionId, payType)
    }
}

// MARK: - 苹果正常支付流程

//: extension AppleIAPManager {
extension MalusPumilaTransactionObserver {
    /// 发起苹果支付【1.创建订单； 2.发起苹果支付； 3.服务端校验】
    /// - Parameters:
    ///   - purchID: 产品ID
    ///   - payType: 支付类型
    ///   - handle: 回调
    ///   - source: 0 常规充值 1 观看视频后充值或订阅
    //: func iap_startPurchase(productId: String, payType: ApplePayType, source: Int = 0, handle: @escaping IAPcompletionHandle) {
    func serverList(productId: String, payType: ActionType, source: Int = 0, handle: @escaping IAPcompletionHandle) {
        //: iap_initData()
        active()
        //: self.completionHandle = handle
        self.completionHandle = handle
        //: self.currentPayType = payType
        self.currentPayType = payType

        // 1. 根据类型创建订单
        //: switch(payType) {
        switch payType {
        //: case .Pay:
        case .Pay:
            //: req_pay_createAppleOrder(productId: productId, source: source) { [weak self] orderId, succeed in
            pic(productId: productId, source: source) { [weak self] orderId, succeed in
                //: guard let self = self else { return }
                guard let self = self else { return }
                //: guard succeed == true && orderId != nil else {
                guard succeed == true && orderId != nil else { // 订单创建失败
                    //: self.completionHandle?(.createOrderFail, 0, .Pay)
                    self.completionHandle?(.createOrderFail, 0, .Pay)
                    //: return
                    return
                }

                //: self.createOrderId = orderId
                self.createOrderId = orderId
                //: self.requestProductInfo(productId)
                self.appressed(productId)
            }

        //: case .Subscribe:
        case .Subscribe:
            //: req_subscribe_createAppleOrder(productId: productId, source: source) { [weak self] orderId, succeed in
            quantityry(productId: productId, source: source) { [weak self] orderId, succeed in
                //: guard let self = self else { return }
                guard let self = self else { return }
                //: guard succeed == true && orderId != nil else {
                guard succeed == true && orderId != nil else { // 订单创建失败
                    //: self.completionHandle?(.createOrderFail, 0, .Subscribe)
                    self.completionHandle?(.createOrderFail, 0, .Subscribe)
                    //: return
                    return
                }

                //: self.createOrderId = orderId
                self.createOrderId = orderId
                //: self.requestProductInfo(productId)
                self.appressed(productId)
            }
        }
    }

    // 2 发起苹果支付，查询apple内购商品
    //: fileprivate func requestProductInfo(_ productId: String) {
    fileprivate func appressed(_ productId: String) {
        //: guard SKPaymentQueue.canMakePayments() else {
        guard SKPaymentQueue.canMakePayments() else {
            //: self.completionHandle?(.notArrow, 0, currentPayType)
            self.completionHandle?(.notArrow, 0, currentPayType)
            //: return
            return
        }

        // 销毁当前请求
        //: self.clearProductInfoRequest()
        self.establishSource()
        // 查询apple内购商品
        //: let identifiers: Set<String> = [productId]
        let identifiers: Set<String> = [productId]
        //: productInfoReq = SKProductsRequest(productIdentifiers: identifiers)
        productInfoReq = SKProductsRequest(productIdentifiers: identifiers)
        //: productInfoReq?.delegate = self
        productInfoReq?.delegate = self
        //: productInfoReq?.start()
        productInfoReq?.start()
    }

    // 销毁当前请求
    //: fileprivate func clearProductInfoRequest() {
    fileprivate func establishSource() {
        //: guard productInfoReq != nil else { return }
        guard productInfoReq != nil else { return }
        //: productInfoReq?.delegate = nil
        productInfoReq?.delegate = nil
        //: productInfoReq?.cancel()
        productInfoReq?.cancel()
        //: productInfoReq = nil
        productInfoReq = nil
    }
}

// MARK: - SKProductsRequestDelegate【商品查询】

//: extension AppleIAPManager: SKProductsRequestDelegate {
extension MalusPumilaTransactionObserver: SKProductsRequestDelegate {
    // 查询apple内购商品成功回调
    //: func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
    func productsRequest(_: SKProductsRequest, didReceive response: SKProductsResponse) {
        //: guard response.products.count > 0 else {
        guard response.products.count > 0 else {
            //: self.completionHandle?( .noProductId, 0, currentPayType)
            self.completionHandle?(.noProductId, 0, currentPayType)
            //: return
            return
        }

        //: let payment = SKPayment(product: response.products.first!)
        let payment = SKPayment(product: response.products.first!)
        //: SKPaymentQueue.default().add(payment)
        SKPaymentQueue.default().add(payment)
    }

    // 查询apple内购商品失败
    //: func request(_ request: SKRequest, didFailWithError error: Error) {
    func request(_: SKRequest, didFailWithError _: Error) {
        //: self.completionHandle?( .noProductId, 0, currentPayType)
        self.completionHandle?(.noProductId, 0, currentPayType)
    }

    // 查询apple内购商品完成
    //: func requestDidFinish(_ request: SKRequest) {
    func requestDidFinish(_: SKRequest) {}
}

// MARK: - SKPaymentTransactionObserver【支付回调】

//: extension AppleIAPManager: SKPaymentTransactionObserver {
extension MalusPumilaTransactionObserver: SKPaymentTransactionObserver {
    /// 2.2 apple内购完成回调
    //: func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
    func paymentQueue(_: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        //: for transaction in transactions {
        for transaction in transactions {
            //: switch transaction.transactionState {
            switch transaction.transactionState {
            //: case .purchasing:
            case .purchasing: // 交易中
                //: break
                break

            //: case .purchased:
            case .purchased: // 交易成功
                /**
                 original.transactionIdentifier 首次订阅时为nil，transaction.transactionIdentifier有值；
                 后续自动订阅、续订时，original.transactionIdentifier为首次订阅时生成的transaction.transactionIdentifier，值固定不变；
                 每次订阅transaction.transactionIdentifier都不一样，为当前交易的标识；
                 */
                //: if transaction.original != nil && createOrderId == nil {
                if transaction.original != nil && createOrderId == nil { // 启动自动续订时，不需要调用服务端验证接口
                    //: self.completionHandle?(.renewSucceed, 0, currentPayType)
                    self.completionHandle?(.renewSucceed, 0, currentPayType)
                    //: } else {
                } else { // 普通购买和订阅
                    // 初始化每个交易请求次数
                    //: reqRetryCountDict[transaction.transactionIdentifier!] = 0
                    reqRetryCountDict[transaction.transactionIdentifier!] = 0
                    // 3. 服务端校验流程
                    //: transcationPurchasedToCheck(transaction.transactionIdentifier!, self.currentPayType)
                    permission(transaction.transactionIdentifier!, self.currentPayType)
                }
                // 移除苹果支付系统缓存
                //: SKPaymentQueue.default().finishTransaction(transaction)
                SKPaymentQueue.default().finishTransaction(transaction)
                //: createOrderId = nil
                createOrderId = nil

            //: case .failed:
            case .failed: // 交易失败/取消
                //: SKPaymentQueue.default().finishTransaction(transaction)
                SKPaymentQueue.default().finishTransaction(transaction)
                //: self.completionHandle?(.failed, 0, currentPayType)
                self.completionHandle?(.failed, 0, currentPayType)
                //: createOrderId = nil
                createOrderId = nil

            //: case .restored:
            case .restored: // 已购买过该商品
                //: SKPaymentQueue.default().finishTransaction(transaction)
                SKPaymentQueue.default().finishTransaction(transaction)
                //: self.completionHandle?(.restored, 0, currentPayType)
                self.completionHandle?(.restored, 0, currentPayType)
                //: createOrderId = nil
                createOrderId = nil

            //: case .deferred:
            case .deferred: // 交易延期
                //: SKPaymentQueue.default().finishTransaction(transaction)
                SKPaymentQueue.default().finishTransaction(transaction)
                //: self.completionHandle?(.deferred, 0, currentPayType)
                self.completionHandle?(.deferred, 0, currentPayType)
                //: createOrderId = nil
                createOrderId = nil

            //: @unknown default:
            @unknown default:
                //: SKPaymentQueue.default().finishTransaction(transaction)
                SKPaymentQueue.default().finishTransaction(transaction)
                //: self.completionHandle?(.unknow, 0, currentPayType)
                self.completionHandle?(.unknow, 0, currentPayType)
                //: createOrderId = nil
                createOrderId = nil
                //: fatalError(" 未知的交易类型")
                fatalError((k_poorMKey + String(data_schemeUrl)))
            }
        }
    }

    /// 3. 服务端校验流程
    /// - Parameters:
    ///   - transactionId: 交易唯一标识符
    ///   - payType: 支付类型
    //: fileprivate func transcationPurchasedToCheck(_ transactionId: String, _ payType: ApplePayType) {
    fileprivate func permission(_ transactionId: String, _ payType: ActionType) {
        //: guard let receiptStr = getVerifyData(transactionId, payType) else {
        guard let receiptStr = create(transactionId, payType) else {
            //: self.completionHandle?(.verityFail, 0, payType)
            self.completionHandle?(.verityFail, 0, payType)
            //: return
            return
        }

        // 缓存支付成功信息，防止接口校验失败
        //: if createOrderId != nil {
        if createOrderId != nil { // 正常支付流程
            //: switch(payType) {
            switch payType {
            //: case .Pay:
            case .Pay:
                //: if self.payCacheList.filter({$0["transactionId"] == transactionId || $0["orderId"] == createOrderId}).count == 0 {  // 防止重复添加缓存数据
                if self.payCacheList.filter({ $0[(String(showLaterLinkUrl) + String(user_networkKey.suffix(6)))] == transactionId || $0[String(bytes: app_cornerCancelValue.map{failureWill(sound: $0)}, encoding: .utf8)!] == createOrderId }).count == 0 { // 防止重复添加缓存数据
                    //: let cacheDict = ["transactionId": transactionId,
                    let cacheDict = [(String(showLaterLinkUrl) + String(user_networkKey.suffix(6))): transactionId,
                                     //: "orderId": createOrderId!,
                                     String(bytes: app_cornerCancelValue.map{failureWill(sound: $0)}, encoding: .utf8)!: createOrderId!,
                                     //: "verifyData": receiptStr]
                                     String(bytes: showWillKey.map{showBlock(link: $0)}, encoding: .utf8)!: receiptStr]
                    //: self.payCacheList.append(cacheDict)
                    self.payCacheList.append(cacheDict)
                    //: let diskPath = self.getPayCachePath()
                    let diskPath = self.item()
                    //: NSKeyedArchiver.archiveRootObject(self.payCacheList, toFile: diskPath)
                    NSKeyedArchiver.archiveRootObject(self.payCacheList, toFile: diskPath)
                }

            //: case .Subscribe:
            case .Subscribe:
                //: if self.subscribeCacheList.filter({$0["transactionId"] == transactionId || $0["orderId"] == createOrderId}).count == 0 { // 防止重复添加缓存数据
                if self.subscribeCacheList.filter({ $0[(String(showLaterLinkUrl) + String(user_networkKey.suffix(6)))] == transactionId || $0[String(bytes: app_cornerCancelValue.map{failureWill(sound: $0)}, encoding: .utf8)!] == createOrderId }).count == 0 { // 防止重复添加缓存数据
                    //: let cacheDict = ["transactionId": transactionId,
                    let cacheDict = [(String(showLaterLinkUrl) + String(user_networkKey.suffix(6))): transactionId,
                                     //: "orderId": createOrderId!,
                                     String(bytes: app_cornerCancelValue.map{failureWill(sound: $0)}, encoding: .utf8)!: createOrderId!,
                                     //: "verifyData": receiptStr]
                                     String(bytes: showWillKey.map{showBlock(link: $0)}, encoding: .utf8)!: receiptStr]
                    //: self.subscribeCacheList.append(cacheDict)
                    self.subscribeCacheList.append(cacheDict)
                    //: let diskPath = self.getSubscribeCachePath()
                    let diskPath = self.panelPath()
                    //: NSKeyedArchiver.archiveRootObject(self.subscribeCacheList, toFile: diskPath)
                    NSKeyedArchiver.archiveRootObject(self.subscribeCacheList, toFile: diskPath)
                }
            }
        }

        // 限制交易重试最大次数
        //: var reqCount = reqRetryCountDict[transactionId] ?? 0
        var reqCount = reqRetryCountDict[transactionId] ?? 0
        //: reqCount += 1
        reqCount += 1
        //: reqRetryCountDict[transactionId] = reqCount
        reqRetryCountDict[transactionId] = reqCount
        //: if reqCount > APPLE_IAP_MAX_RETRY_COUNT {
        if reqCount > appTimeSkipValue {
            //: self.completionHandle?(.verityFail, 0, payType)
            self.completionHandle?(.verityFail, 0, payType)
            //: return
            return
        }

        // 3.服务端校验，根据transactionId从缓存中取
        //: switch(payType) {
        switch payType {
        //: case .Pay:
        case .Pay:
            //: let paramsArr = self.payCacheList.filter({$0["transactionId"] == transactionId})
            let paramsArr = self.payCacheList.filter { $0[(String(showLaterLinkUrl) + String(user_networkKey.suffix(6)))] == transactionId }
            //: guard paramsArr.count > 0 else { return }
            guard paramsArr.count > 0 else { return }
            //: req_pay_uploadAppletransaction(transactionId, params: paramsArr.first!)
            post(transactionId, params: paramsArr.first!)

        //: case .Subscribe:
        case .Subscribe:
            //: let paramsArr = self.subscribeCacheList.filter({$0["transactionId"] == transactionId})
            let paramsArr = self.subscribeCacheList.filter { $0[(String(showLaterLinkUrl) + String(user_networkKey.suffix(6)))] == transactionId }
            //: guard paramsArr.count > 0 else { return }
            guard paramsArr.count > 0 else { return }
            //: req_subscribe_uploadAppletransaction(transactionId, params: paramsArr.first!)
            createFail(transactionId, params: paramsArr.first!)
        }
    }
}
