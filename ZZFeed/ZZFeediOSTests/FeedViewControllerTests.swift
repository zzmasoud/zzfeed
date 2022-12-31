//
//  FeedViewControllerTests.swift
//  ZZFeediOSTests
//
//  Created by Masoud Sheikh Hosseini on 12/31/22.
//

import XCTest
import UIKit
import ZZFeed

public class FeedViewController: UIViewController {
    private var loader: Feedloader?
    
    convenience init(loader: Feedloader) {
        self.init()
        self.loader = loader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        loader?.load { _ in }
    }
}

final class FeedViewControllerTests: XCTestCase {
    
    func test_init_doesNotLoadFeed() {
        let loader = LoaderSpy()
        _ = FeedViewController(loader: loader)
        
        XCTAssertEqual(loader.loadCount, 0)
    }
    
    func test_viewDidLoad_loadsFeed() {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadCount, 1)
    }
    
    // MARK: - Helpers
    class LoaderSpy: Feedloader {
        private(set) var loadCount = 0
        
        func load(completion: @escaping (Feedloader.Result) -> Void) {
            loadCount += 1
        }
    }
}
