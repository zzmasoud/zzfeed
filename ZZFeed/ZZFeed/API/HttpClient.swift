//
//  HttpClient.swift
//  ZZFeed
//
//  Created by zzmasoud on 8/5/22.
//

import Foundation

public protocol HttpClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    
    func get(from url: URL, completion: @escaping (Result)->Void)
}
