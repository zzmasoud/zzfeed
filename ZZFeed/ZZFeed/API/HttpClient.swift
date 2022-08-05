//
//  HttpClient.swift
//  ZZFeed
//
//  Created by Masoud Sheikh Hosseini on 8/5/22.
//

import Foundation

public enum HttpClientResult {
    case failure(Error)
    case success(Data, HTTPURLResponse)
}

public protocol HttpClient {
    func get(from url: URL, completion: @escaping (HttpClientResult)->Void)
}
