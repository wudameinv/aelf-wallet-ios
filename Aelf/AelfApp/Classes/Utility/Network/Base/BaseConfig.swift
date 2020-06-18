//
//  MoyaConfig.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/5/24.
//  Copyright © 2019 AELF. All rights reserved.
//

import Foundation
import Moya
import ObjectMapper
import Alamofire


private enum APIEnv: Int {

    case dev = 1        // 开发环境
    case test           // 测试环境
    case staging        // 预发布环境
    case prodcution     // 线上环境

    var appHost: String {
        switch self {
        case .dev:
            return "http://192.168.197.40:8082/"
        case .test:
            return "http://192.168.197.40:8082/"
        case .staging:
            return "http://192.168.197.40:8082/"
        case .prodcution:
            return "http://192.168.197.40:8082/"
        }
    }

    // 多套域名可在此添加，参考上面👆
}

struct BaseConfig {

    static var BaseURL: URL {
        guard let url = try? APIEnv(rawValue: appEnv)?.appHost.asURL() else {
            fatalError("请检查 URL 环境配置。")
        }
        return url!
    }

    static var headers: [String : String]? {
        return ["Content-type":"application/x-www-form-urlencoded; charset=utf-8"]
    }

    static let networkActivityPlugin = NetworkActivityPlugin { (change,_)
        -> Void in
        switch(change) {
        case .ended:
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        case .began:
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
            }
        }
    }

    static func baseParameters() -> [String:String] {
        var parameters = [String:String]()
        parameters["device"] = "iOS"
        parameters["udid"] = UUID.keyChainUUID
        parameters["version"] = String.appVersion
        parameters["currency"] = App.currency
        parameters["chainid"] = App.chainID

        logInfo("\n 基础参数：\(parameters)\n")

        parameters.rsaEncode()

        if appEnv == 1 {
            parameters["test"] = "1"
        }
        return parameters
    }

    static func jsonFormatter(_ data: Data) -> Data {
        do {
            let dataAsJSON = try JSONSerialization.jsonObject(with: data)
            let prettyData =  try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
            return prettyData
        } catch {
            return data //fallback to original data if it cant be serialized
        }
    }

    static let manager: Moya.Manager = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        configuration.timeoutIntervalForRequest = 15 // as seconds, you can set your request timeout
        configuration.timeoutIntervalForResource = 15 // as seconds, you can set your resource timeout
        configuration.requestCachePolicy = .useProtocolCachePolicy
        let manager = Manager(configuration: configuration)
        return manager
    }()

}

