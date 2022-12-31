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
        let (_, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadCount, 0)
    }
    
    func test_viewDidLoad_loadsFeed() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadCount, 1)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt8 = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)

        return (sut, loader)
    }
    
    class LoaderSpy: Feedloader {
        private(set) var loadCount = 0
        
        func load(completion: @escaping (Feedloader.Result) -> Void) {
            loadCount += 1
        }
    }
}
