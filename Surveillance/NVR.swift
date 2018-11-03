//
//  NVR.swift
//  Surveillance
//
//  Created by Robert Dougan on 01/11/2018.
//  Copyright © 2018 Robert Dougan. All rights reserved.
//

import Foundation

import RealmSwift

fileprivate let STORAGE_NVR_URL_KEY = "STORAGE_NVR_URL_KEY"
fileprivate let STORAGE_NVR_APIKEY_KEY = "STORAGE_NVR_APIKEY_KEY"

let NVR_NOTIFICATION_FETCHED_CAMERAS = Notification.Name("NVR_NOTIFICATION_FETCHED_CAMERAS")
let NVR_NOTIFICATION_REQUIRES_NVR_URL = Notification.Name("NVR_NOTIFICATION_REQUIRES_NVR_URL")
let NVR_NOTIFICATION_REQUIRES_NVR_API_KEY = Notification.Name("NVR_NOTIFICATION_REQUIRES_NVR_API_KEY")
let NVR_NOTIFICATION_FAILED_TO_CONNECT = Notification.Name("NVR_NOTIFICATION_FAILED_TO_CONNECT")

enum NVRError: Error {
    case invalidURL
    case invalidAPIKey
}

class NVR {
    
    static let shared = NVR()
    
    var url: URL? {
        get {
            return UserDefaults.standard.url(forKey: STORAGE_NVR_URL_KEY)
        }
        
        set(nvrURL) {
            UserDefaults.standard.set(nvrURL, forKey: STORAGE_NVR_URL_KEY)
        }
    }
    
    var apiKey: String? {
        get {
            return UserDefaults.standard.string(forKey: STORAGE_NVR_APIKEY_KEY)
        }
        
        set(apiKey) {
            UserDefaults.standard.set(apiKey, forKey: STORAGE_NVR_APIKEY_KEY)
        }
    }
    
    var cameras: [Camera]? {
        didSet {
            NotificationCenter.default.post(name: NVR_NOTIFICATION_FETCHED_CAMERAS, object: nil)
        }
    }
    
    func getCameras() throws {
        guard let url = self.url else {
            throw NVRError.invalidURL
        }
        
        guard let apiKey = self.apiKey else {
            throw NVRError.invalidAPIKey
        }
        
        var components = URLComponents(string: url.appendingPathComponent("api/2.0/camera").absoluteString)
        
        components?.queryItems = [
            URLQueryItem(name: "apiKey", value: apiKey)
        ]
        
        guard let fullUrl = components?.url else {
            throw NVRError.invalidAPIKey
        }
        
        var request = URLRequest(url: fullUrl)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request, completionHandler: { data, response, error -> Void in
            do {
                let jsonDecoder = JSONDecoder()
                let response = try jsonDecoder.decode(CameraResponse.self, from: data!)
                
                self.cameras = response.data
            } catch {
                print("JSON Serialization error: \(error)")
                
                NotificationCenter.default.post(name: NVR_NOTIFICATION_FAILED_TO_CONNECT, object: nil)
            }
        }).resume()
    }
}


struct CameraResponse: Decodable {
    
    let data: [Camera]
    
}

struct Camera: Decodable, Equatable {
    
    let id: String
    let name: String
    let internalHost: String
//    let channels: [CameraChannel]
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case internalHost
//        case channels
    }
    
    static func == (lhs: Camera, rhs: Camera) -> Bool {
        return lhs.id == rhs.id
    }
    
    var snapshotURL: URL? {
        get {
            guard let baseURL = URL(string: "http://\(self.internalHost)") else { return nil }
            
            return baseURL.appendingPathComponent("snap.jpeg")
        }
    }

}

//struct CameraChannel: Decodable {
//
//    let id: String
//    let name: String
//    let enabled: Bool
//    let isRtspEnabled: Bool
//    let rtspUris: [String]
//    let width: Int
//    let height: Int
//
//}
