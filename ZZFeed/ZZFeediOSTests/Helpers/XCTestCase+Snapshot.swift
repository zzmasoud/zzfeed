//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import XCTest

extension XCTestCase {
    func assert(snapshot: UIImage, named: String, file: StaticString = #filePath , line: UInt = #line) {
        let snapshotURL = makeSnapshotURL(named: named, file: file)
        let snapshotData = makeSnapshotData(for: snapshot, file: file, line: line)

        guard let storedSnapshotData = try? Data(contentsOf: snapshotURL) else {
            XCTFail("No snapshot found at URL: \(snapshotURL). Use `record` method to store a snapshot before asserting.")
            return
        }
        
        if snapshotData != storedSnapshotData {
            let tempURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
                .appendingPathComponent(snapshotURL.lastPathComponent)
            
            try? snapshotData?.write(to: tempURL)
            
            XCTFail("New snapshot doesn't match stored snapshot. New snapshot URL: \(tempURL), Stored snapshot URL: \(snapshotURL)", file: file, line: line)
        }
    }
    
    func record(snapshot: UIImage, named: String, file: StaticString = #filePath, line: UInt = #line) {
        let snapshotURL = makeSnapshotURL(named: named, file: file)
        let snapshotData = makeSnapshotData(for: snapshot, file: file, line: line)

        do {
            try FileManager.default.createDirectory(
                at: snapshotURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try snapshotData?.write(to: snapshotURL)
        } catch {
            XCTFail("failed to save snapshot data with error: \(error)", file: file, line: line)
        }
    }
    
    func makeSnapshotData(for snapshot: UIImage, file: StaticString, line: UInt) -> Data? {
        guard let snapshotData = snapshot.pngData() else {
            XCTFail("failed to generate PNG file from the snapshot UIImage", file: file, line: line)
            return nil
        }
        return snapshotData
    }
    
    func makeSnapshotURL(named name: String, file: StaticString) -> URL {
        return URL(fileURLWithPath: String(describing: file))
            .deletingLastPathComponent()
            .appendingPathComponent("snapshots")
            .appendingPathComponent("\(name).png")
    }
}
