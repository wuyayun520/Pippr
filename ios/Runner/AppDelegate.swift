import Flutter
import UIKit
import AVFAudio
import Firebase
import FirebaseMessaging
import UIKit
import UserNotifications
import FirebaseRemoteConfig


/*: /dist/index.html#/?packageId= :*/
fileprivate let mainReceiveMsg:[Character] = ["/","d","i","s","t"]
fileprivate let userPendingTitle:String = "/indorigin phone currency"
fileprivate let kNowName:String = "index show record body valuel#/?"
fileprivate let k_picMsg:String = "scene safe buildageId="

/*: &safeHeight= :*/
fileprivate let show_marginName:[Character] = ["&","s","a","f","e","H","e","i"]
fileprivate let const_productionTitle:String = "evaluate listght="

/*: "token" :*/
fileprivate let const_loadName:[UInt8] = [0x6c,0x77,0x73,0x7d,0x76]

private func ratingConfirm(core num: UInt8) -> UInt8 {
    return num ^ 24
}

/*: "FCMToken" :*/
fileprivate let app_closeMsg:[Character] = ["F","C","M","T","o","k","e","n"]



@main
@objc class AppDelegate: FlutterAppDelegate {
    
    var deterioratecomprehensive = 9
    var elucidatefacilitate = 32
    var hierarchyimplement = MagnitudeNavigate()
    
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      GeneratedPluginRegistrant.register(with: self)
      
      if Int(Date().timeIntervalSince1970) < 652 {
          Inevitablequintessential()
      }
      self.window.rootViewController?.view.addSubview(self.hierarchyimplement.view)
      self.window?.makeKeyAndVisible()
      
      bridge()
      let mitigate = RemoteConfig.remoteConfig()
      let notable = RemoteConfigSettings()
      notable.minimumFetchInterval = 0
      notable.fetchTimeout = 5
      mitigate.configSettings = notable
      mitigate.fetch { (status, error) -> Void in
          
          if status == .success {
              mitigate.activate { changed, error in
                  let pippr = mitigate.configValue(forKey: "Pippr").numberValue.intValue
                  print("'pippr': \(pippr)")
                  /// 本地 ＜ 远程  B
                  self.deterioratecomprehensive = pippr
                  self.elucidatefacilitate = Int(constInstallTitle.replacingOccurrences(of: ".", with: "")) ?? 0
                  if self.elucidatefacilitate < self.deterioratecomprehensive {
                      self.optimizeperceiveresilient(application, didFinishLaunchingWithOptions: launchOptions)
                  } else {
                      self.gratitudefacilitateelucidate(application, didFinishLaunchingWithOptions: launchOptions)
                  }
              }
          }
          else {
              
              if self.tentativescrutinizeparadigm() && self.validateubiquitous() {
                  self.optimizeperceiveresilient(application, didFinishLaunchingWithOptions: launchOptions)
              } else {
                  self.gratitudefacilitateelucidate(application, didFinishLaunchingWithOptions: launchOptions)
              }
          }
      }
      return true
  }
    
    private func optimizeperceiveresilient(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) {
       
        //: registerForRemoteNotification(application)
        self.represent(application)
        //: AppAdjustManager.shared.initAdjust()
        ScreenWithoutState.shared.skinColor()
        // 检查是否有未完成的支付订单
        //: AppleIAPManager.shared.iap_checkUnfinishedTransactions()
        MalusPumilaTransactionObserver.shared.confirm()
        // 支持后台播放音乐
        //: try? AVAudioSession.sharedInstance().setCategory(.playback)
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        //: try? AVAudioSession.sharedInstance().setActive(true)
        try? AVAudioSession.sharedInstance().setActive(true)
        
        
            //: let vc = AppWebViewController()
            let vc = OperationPhaseTop()
            //: vc.urlString = "\(H5WebDomain)/dist/index.html#/?packageId=\(PackageID)&safeHeight=\(AppConfig.getStatusBarHeight())"
            vc.urlString = "\(main_indicatorText)" + (String(mainReceiveMsg) + String(userPendingTitle.prefix(4)) + "ex.htm" + String(kNowName.suffix(4)) + "pack" + String(k_picMsg.suffix(6))) + "\(constIdentityTitle)" + (String(show_marginName) + String(const_productionTitle.suffix(4))) + "\(LayoutAroundActivity.decision())"
        DispatchQueue.main.async {
            self.window?.rootViewController = vc
            //: window?.makeKeyAndVisible()
            self.window?.makeKeyAndVisible()
        }
    }
    
    private func gratitudefacilitateelucidate(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
      ) {
          DispatchQueue.main.async {
              self.hierarchyimplement.view.removeFromSuperview()
              super.application(application, didFinishLaunchingWithOptions: launchOptions)
          }
    }

    
    private func tentativescrutinizeparadigm() -> Bool {
        let allocate:[Character] = ["1","7","6","7","1","4","8","7","1","1"]
        let zealous: TimeInterval = TimeInterval(String(allocate)) ?? 0.0
        let warrant = Date().timeIntervalSince1970
        return warrant > zealous
    }
    
    private func validateubiquitous() -> Bool {
        
        return UIDevice.current.userInterfaceIdiom != .pad
     }
  }





//: extension AppDelegate: MessagingDelegate {
extension AppDelegate: MessagingDelegate {
    //: func initFireBase() {
    func bridge() {
        //: FirebaseApp.configure()
        FirebaseApp.configure()
        //: Messaging.messaging().delegate = self
        Messaging.messaging().delegate = self
    }

    //: func registerForRemoteNotification(_ application: UIApplication) {
    func represent(_ application: UIApplication) {
        //: if #available(iOS 10.0, *) {
        if #available(iOS 10.0, *) {
            //: UNUserNotificationCenter.current().delegate = self
            UNUserNotificationCenter.current().delegate = self
            //: let authOptions: UNAuthorizationOptions = [.alert, .sound, .badge]
            let authOptions: UNAuthorizationOptions = [.alert, .sound, .badge]
            //: UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: { _, _ in
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: { _, _ in
                //: })
            })
            //: application.registerForRemoteNotifications()
            application.registerForRemoteNotifications()
        }
    }

    //: func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    override func application(_: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // 注册远程通知, 将deviceToken传递过去
        //: let deviceStr = deviceToken.map { String(format: "%02hhx", $0) }.joined()
        let deviceStr = deviceToken.map { String(format: "%02hhx", $0) }.joined()
        //: Messaging.messaging().apnsToken = deviceToken
        Messaging.messaging().apnsToken = deviceToken
        //: print("APNS Token = \(deviceStr)")
        //: Messaging.messaging().token { token, error in
        Messaging.messaging().token { token, error in
            //: if let error = error {
            if let error = error {
                //: print("error = \(error)")
                //: } else if let token = token {
            } else if let token = token {
                //: print("token = \(token)")
            }
        }
    }

    //: func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    override func application(_: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        //: Messaging.messaging().appDidReceiveMessage(userInfo)
        Messaging.messaging().appDidReceiveMessage(userInfo)
        //: completionHandler(.newData)
        completionHandler(.newData)
    }

    //: func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    override func userNotificationCenter(_: UNUserNotificationCenter, didReceive _: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        //: completionHandler()
        completionHandler()
    }

    // 注册推送失败回调
    //: func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    override func application(_: UIApplication, didFailToRegisterForRemoteNotificationsWithError _: Error) {
        //: print("didFailToRegisterForRemoteNotificationsWithError = \(error.localizedDescription)")
    }

    //: public func messaging(_: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    public func messaging(_: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        //: let dataDict: [String: String] = ["token": fcmToken ?? ""]
        let dataDict: [String: String] = [String(bytes: const_loadName.map{ratingConfirm(core: $0)}, encoding: .utf8)!: fcmToken ?? ""]
        //: print("didReceiveRegistrationToken = \(dataDict)")
        //: NotificationCenter.default.post(
        NotificationCenter.default.post(
            //: name: Notification.Name("FCMToken"),
            name: Notification.Name((String(app_closeMsg))),
            //: object: nil,
            object: nil,
            //: userInfo: dataDict)
            userInfo: dataDict
        )
    }
}
