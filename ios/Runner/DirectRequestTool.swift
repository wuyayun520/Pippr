
//: Declare String Begin

/*: "Net Error, Try again later" :*/
fileprivate let data_platformMsg:String = "first cornerNet "
fileprivate let const_windowScaleData:String = ", Try ascene used transaction"
fileprivate let main_formatData:String = "gaadn"

/*: "data" :*/
fileprivate let noti_cornerData:[Character] = ["d","a","t","a"]

/*: ":null" :*/
fileprivate let user_showStr:String = "adjust tab break disk feedback:null"

/*: "json error" :*/
fileprivate let mainPackageUrl:String = "jrequestn"
fileprivate let main_mPath:[Character] = ["r"]

/*: "platform=iphone&version= :*/
fileprivate let const_remoteRootRequestKey:[Character] = ["p","l","a","t","f","o","r","m","=","i","p","h","o","n","e","&","v","e","r","s","i","o","n","="]

/*: &packageId= :*/
fileprivate let data_launchPolicyTextValue:String = "&pamargin value object establish"
fileprivate let const_plusKey:String = "ckageId=with case manager"

/*: &bundleId= :*/
fileprivate let notiClickName:[Character] = ["&","b","u","n","d","l","e","I","d"]
fileprivate let main_framePhotoMsg:[Character] = ["="]

/*: &lang= :*/
fileprivate let kActivityMessage:[Character] = ["&","l","a","n","g"]
fileprivate let notiUserKey:[Character] = ["="]

/*: ; build: :*/
fileprivate let constProductionText:String = "; buildback local"
fileprivate let user_ratingUrl:[Character] = [":"]

/*: ; iOS  :*/
fileprivate let main_deviceMsg:[Character] = [";"," ","i","O","S"," "]

//: Declare String End

//: import Alamofire
import Alamofire
//: import CoreMedia
import CoreMedia
//: import HandyJSON
import HandyJSON
// __DEBUG__
// __CLOSE_PRINT__
//: import UIKit
import UIKit

//: typealias FinishBlock = (_ succeed: Bool, _ result: Any?, _ errorModel: AppErrorResponse?) -> Void
typealias FinishBlock = (_ succeed: Bool, _ result: Any?, _ errorModel: SkipErrorResponse?) -> Void

//: @objc class AppRequestTool: NSObject {
@objc class DirectRequestTool: NSObject {
    /// 发起Post请求
    /// - Parameters:
    ///   - model: 请求参数
    ///   - completion: 回调
    //: class func startPostRequest(model: AppRequestModel, completion: @escaping FinishBlock) {
    class func ingotText(model: WorldWideRequestModel, completion: @escaping FinishBlock) {
        //: let serverUrl = self.buildServerUrl(model: model)
        let serverUrl = self.center(model: model)
        //: let headers = self.getRequestHeader(model: model)
        let headers = self.transaction(model: model)
        //: AF.request(serverUrl, method: .post, parameters: model.params, headers: headers, requestModifier: { $0.timeoutInterval = 10.0 }).responseData { [self] responseData in
        AF.request(serverUrl, method: .post, parameters: model.params, headers: headers, requestModifier: { $0.timeoutInterval = 10.0 }).responseData { [self] responseData in
            //: switch responseData.result {
            switch responseData.result {
            //: case .success:
            case .success:
                //: func__requestSucess(model: model, response: responseData.response!, responseData: responseData.data!, completion: completion)
                requestApplicationCompletion(model: model, response: responseData.response!, responseData: responseData.data!, completion: completion)

            //: case .failure:
            case .failure:
                //: completion(false, nil, AppErrorResponse.init(errorCode: RequestResultCode.NetError.rawValue, errorMsg: "Net Error, Try again later"))
                completion(false, nil, SkipErrorResponse(errorCode: TransitionBasicType.NetError.rawValue, errorMsg: (String(data_platformMsg.suffix(4)) + "Error" + String(const_windowScaleData.prefix(7)) + main_formatData.replacingOccurrences(of: "ad", with: "i") + " later")))
            }
        }
    }

    //: class func func__requestSucess(model: AppRequestModel, response: HTTPURLResponse, responseData: Data, completion: @escaping FinishBlock) {
    class func requestApplicationCompletion(model _: WorldWideRequestModel, response _: HTTPURLResponse, responseData: Data, completion: @escaping FinishBlock) {
        //: var responseJson = String(data: responseData, encoding: .utf8)
        var responseJson = String(data: responseData, encoding: .utf8)
        //: responseJson = responseJson?.replacingOccurrences(of: "\"data\":null", with: "\"data\":{}")
        responseJson = responseJson?.replacingOccurrences(of: "\"" + (String(noti_cornerData)) + "\"" + (String(user_showStr.suffix(5))), with: "" + "\"" + (String(noti_cornerData)) + "\"" + ":{}")
        //: if let responseModel = JSONDeserializer<AppBaseResponse>.deserializeFrom(json: responseJson) {
        if let responseModel = JSONDeserializer<TransactionHandyJSON>.deserializeFrom(json: responseJson) {
            //: if responseModel.errno == RequestResultCode.Normal.rawValue {
            if responseModel.errno == TransitionBasicType.Normal.rawValue {
                //: completion(true, responseModel.data, nil)
                completion(true, responseModel.data, nil)
                //: } else {
            } else {
                //: completion(false, responseModel.data, AppErrorResponse.init(errorCode: responseModel.errno, errorMsg: responseModel.msg ?? ""))
                completion(false, responseModel.data, SkipErrorResponse(errorCode: responseModel.errno, errorMsg: responseModel.msg ?? ""))
                //: switch responseModel.errno {
                switch responseModel.errno {
//                case TransitionBasicType.NeedReLogin.rawValue:
//                    NotificationCenter.default.post(name: DID_LOGIN_OUT_SUCCESS_NOTIFICATION, object: nil, userInfo: nil)
                //: default:
                default:
                    //: break
                    break
                }
            }
            //: } else {
        } else {
            //: completion(false, nil, AppErrorResponse.init(errorCode: RequestResultCode.NetError.rawValue, errorMsg: "json error"))
            completion(false, nil, SkipErrorResponse(errorCode: TransitionBasicType.NetError.rawValue, errorMsg: (mainPackageUrl.replacingOccurrences(of: "request", with: "so") + " erro" + String(main_mPath))))
        }
    }

    //: class func buildServerUrl(model: AppRequestModel) -> String {
    class func center(model: WorldWideRequestModel) -> String {
        //: var serverUrl: String = model.requestServer
        var serverUrl: String = model.requestServer
        //: let otherParams = "platform=iphone&version=\(AppNetVersion)&packageId=\(PackageID)&bundleId=\(AppBundle)&lang=\(UIDevice.interfaceLang)"
        let otherParams = (String(const_remoteRootRequestKey)) + "\(mainTimeFormat)" + (String(data_launchPolicyTextValue.prefix(3)) + String(const_plusKey.prefix(8))) + "\(constIdentityTitle)" + (String(notiClickName) + String(main_framePhotoMsg)) + "\(userGenerateText)" + (String(kActivityMessage) + String(notiUserKey)) + "\(UIDevice.interfaceLang)"
        //: if !model.requestPath.isEmpty {
        if !model.requestPath.isEmpty {
            //: serverUrl.append("/\(model.requestPath)")
            serverUrl.append("/\(model.requestPath)")
        }
        //: serverUrl.append("?\(otherParams)")
        serverUrl.append("?\(otherParams)")

        //: return serverUrl
        return serverUrl
    }

    /// 获取请求头参数
    /// - Parameter model: 请求模型
    /// - Returns: 请求头参数
    //: class func getRequestHeader(model: AppRequestModel) -> HTTPHeaders {
    class func transaction(model _: WorldWideRequestModel) -> HTTPHeaders {
        //: let userAgent = "\(AppName)/\(AppVersion) (\(AppBundle); build:\(AppBuildNumber); iOS \(UIDevice.current.systemVersion); \(UIDevice.modelName))"
        let userAgent = "\(app_maxTotalFormat)/\(constInstallTitle) (\(userGenerateText)" + (String(constProductionText.prefix(7)) + String(user_ratingUrl)) + "\(data_logMessage)" + (String(main_deviceMsg)) + "\(UIDevice.current.systemVersion); \(UIDevice.modelName))"
        //: let headers = [HTTPHeader.userAgent(userAgent)]
        let headers = [HTTPHeader.userAgent(userAgent)]
        //: return HTTPHeaders(headers)
        return HTTPHeaders(headers)
    }
}
