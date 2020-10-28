import Dflat
import SQLiteDflat
import FlatBuffers
import XCTest
import Foundation

class ConcurrencyTests: XCTestCase {
  var filePath: String?
  var dflat: Workspace?
  
  override func setUp() {
    let filePath = NSTemporaryDirectory().appending("\(UUID().uuidString).db")
    self.filePath = filePath
    dflat = SQLiteWorkspace(filePath: filePath, fileProtectionLevel: .noProtection)
  }
  
  override func tearDown() {
    let group = DispatchGroup()
    group.enter()
    dflat?.shutdown {
      group.leave()
    }
    group.wait()
  }

  func testConcurrentUpdates() {
    guard let dflat = dflat else { return }
    let update1 = XCTestExpectation(description: "transcation 1")
    dflat.performChanges([MyGame.Sample.Monster.self], changesHandler: {txnContext in
      let creationRequest1 = MyGame.Sample.MonsterChangeRequest.creationRequest()
      creationRequest1.name = "name1"
      creationRequest1.mana = 100
      creationRequest1.color = .green
      try! txnContext.submit(creationRequest1)
      let creationRequest2 = MyGame.Sample.MonsterChangeRequest.creationRequest()
      creationRequest2.name = "name2"
      creationRequest2.mana = 50
      creationRequest2.color = .green
      try! txnContext.submit(creationRequest2)
      let creationRequest3 = MyGame.Sample.MonsterChangeRequest.creationRequest()
      creationRequest3.name = "name3"
      creationRequest3.mana = 20
      creationRequest3.color = .green
      try! txnContext.submit(creationRequest3)
      let creationRequest4 = MyGame.Sample.MonsterChangeRequest.creationRequest()
      creationRequest4.name = "name4"
      creationRequest4.mana = 120
      creationRequest4.color = .green
      try! txnContext.submit(creationRequest4)
    }) { success in
      update1.fulfill()
    }
    let update2 = XCTestExpectation(description: "transcation 2")
    dflat.performChanges([MyGame.SampleV2.Monster.self], changesHandler: {txnContext in
      let creationRequest1 = MyGame.SampleV2.MonsterChangeRequest.creationRequest()
      creationRequest1.name = "name1"
      creationRequest1.mana = 100
      creationRequest1.color = .green
      try! txnContext.submit(creationRequest1)
      let creationRequest2 = MyGame.SampleV2.MonsterChangeRequest.creationRequest()
      creationRequest2.name = "name2"
      creationRequest2.mana = 50
      creationRequest2.color = .green
      try! txnContext.submit(creationRequest2)
      let creationRequest3 = MyGame.SampleV2.MonsterChangeRequest.creationRequest()
      creationRequest3.name = "name3"
      creationRequest3.mana = 20
      creationRequest3.color = .green
      try! txnContext.submit(creationRequest3)
      let creationRequest4 = MyGame.SampleV2.MonsterChangeRequest.creationRequest()
      creationRequest4.name = "name4"
      creationRequest4.mana = 120
      creationRequest4.color = .green
      try! txnContext.submit(creationRequest4)
    }) { success in
      update2.fulfill()
    }
    let update3 = XCTestExpectation(description: "transcation 3")
    dflat.performChanges([MyGame.Sample.Monster.self, MyGame.SampleV2.Monster.self], changesHandler: {txnContext in
      // At this point, we should be able to see all 
      let fetchedResult1 = dflat.fetch(for: MyGame.Sample.Monster.self).all()
      XCTAssert(fetchedResult1.count == 4)
      let fetchedResult2 = dflat.fetch(for: MyGame.SampleV2.Monster.self).all()
      XCTAssert(fetchedResult2.count == 4)
      let deleteObj1 = MyGame.SampleV2.Monster(name: "name1", color: .green)
      let deletionRequest1 = MyGame.SampleV2.MonsterChangeRequest.deletionRequest(deleteObj1)
      try! txnContext.submit(deletionRequest1!)
      let deleteObj2 = MyGame.Sample.Monster(name: "name2", color: .green)
      let deletionRequest2 = MyGame.Sample.MonsterChangeRequest.deletionRequest(deleteObj2)
      try! txnContext.submit(deletionRequest2!)
    }) { success in
      update3.fulfill()
    }
    wait(for: [update1, update2, update3], timeout: 10.0)
    let fetchedResult1 = dflat.fetch(for: MyGame.Sample.Monster.self).all()
    XCTAssert(fetchedResult1.count == 3)
    XCTAssertEqual(fetchedResult1[0].name, "name1")
    XCTAssertEqual(fetchedResult1[1].name, "name3")
    XCTAssertEqual(fetchedResult1[2].name, "name4")
    let fetchedResult2 = dflat.fetch(for: MyGame.SampleV2.Monster.self).all()
    XCTAssert(fetchedResult2.count == 3)
    XCTAssertEqual(fetchedResult2[0].name, "name2")
    XCTAssertEqual(fetchedResult2[1].name, "name3")
    XCTAssertEqual(fetchedResult2[2].name, "name4")
  }

  func testSQLiteWriteLock() {
    guard let dflat = dflat else { return }
    let update1 = XCTestExpectation(description: "transcation 1")
    dflat.performChanges([MyGame.Sample.Monster.self], changesHandler: {txnContext in
      let creationRequest1 = MyGame.Sample.MonsterChangeRequest.creationRequest()
      creationRequest1.name = "name1"
      creationRequest1.mana = 100
      creationRequest1.color = .green
      try! txnContext.submit(creationRequest1)
      let creationRequest2 = MyGame.Sample.MonsterChangeRequest.creationRequest()
      creationRequest2.name = "name2"
      creationRequest2.mana = 50
      creationRequest2.color = .green
      try! txnContext.submit(creationRequest2)
      let creationRequest3 = MyGame.Sample.MonsterChangeRequest.creationRequest()
      creationRequest3.name = "name3"
      creationRequest3.mana = 20
      creationRequest3.color = .green
      try! txnContext.submit(creationRequest3)
      let creationRequest4 = MyGame.Sample.MonsterChangeRequest.creationRequest()
      creationRequest4.name = "name4"
      creationRequest4.mana = 120
      creationRequest4.color = .green
      try! txnContext.submit(creationRequest4)
    }) { success in
      update1.fulfill()
    }
    wait(for: [update1], timeout: 10.0)
    let update2 = XCTestExpectation(description: "transcation 2")
    dflat.performChanges([MyGame.SampleV2.Monster.self], changesHandler: {txnContext in
      let creationRequest1 = MyGame.SampleV2.MonsterChangeRequest.creationRequest()
      creationRequest1.name = "name1"
      creationRequest1.mana = 100
      creationRequest1.color = .green
      try! txnContext.submit(creationRequest1)
      let creationRequest2 = MyGame.SampleV2.MonsterChangeRequest.creationRequest()
      creationRequest2.name = "name2"
      creationRequest2.mana = 50
      creationRequest2.color = .green
      try! txnContext.submit(creationRequest2)
      let creationRequest3 = MyGame.SampleV2.MonsterChangeRequest.creationRequest()
      creationRequest3.name = "name3"
      creationRequest3.mana = 20
      creationRequest3.color = .green
      try! txnContext.submit(creationRequest3)
      let creationRequest4 = MyGame.SampleV2.MonsterChangeRequest.creationRequest()
      creationRequest4.name = "name4"
      creationRequest4.mana = 120
      creationRequest4.color = .green
      try! txnContext.submit(creationRequest4)
    }) { success in
      update2.fulfill()
    }
    wait(for: [update2], timeout: 10.0)
    let group = DispatchGroup()
    group.enter()
    group.enter()
    let update3 = XCTestExpectation(description: "transcation 3")
    dflat.performChanges([MyGame.Sample.Monster.self], changesHandler: {txnContext in
      let o1 = MyGame.Sample.Monster(name: "name1", color: .green)
      let o2 = MyGame.Sample.Monster(name: "name2", color: .green)
      if let changeRequest1 = MyGame.Sample.MonsterChangeRequest.changeRequest(o1) {
        changeRequest1.mana = 10
        if let changeRequest2 = MyGame.Sample.MonsterChangeRequest.changeRequest(o2) {
          changeRequest2.mana = 20
          group.leave()
          group.wait()
          try! txnContext.submit(changeRequest1)
          try! txnContext.submit(changeRequest2)
        }
      }
    }) { success in
      update3.fulfill()
    }
    let update4 = XCTestExpectation(description: "transcation 4")
    dflat.performChanges([MyGame.SampleV2.Monster.self], changesHandler: {txnContext in
      let o1 = MyGame.SampleV2.Monster(name: "name1", color: .green)
      let o2 = MyGame.SampleV2.Monster(name: "name2", color: .green)
      if let changeRequest1 = MyGame.SampleV2.MonsterChangeRequest.changeRequest(o1) {
        changeRequest1.mana = 10
        if let changeRequest2 = MyGame.SampleV2.MonsterChangeRequest.changeRequest(o2) {
          changeRequest2.mana = 20
          group.leave()
          group.wait()
          try! txnContext.submit(changeRequest1)
          try! txnContext.submit(changeRequest2)
        }
      }
    }) { success in
      update4.fulfill()
    }
    wait(for: [update3, update4], timeout: 10.0)
    let fetchedResult1 = dflat.fetch(for: MyGame.Sample.Monster.self).all()
    XCTAssert(fetchedResult1.count == 4)
    XCTAssertEqual(fetchedResult1[0].name, "name1")
    XCTAssertEqual(fetchedResult1[0].mana, 10)
    XCTAssertEqual(fetchedResult1[1].name, "name2")
    XCTAssertEqual(fetchedResult1[1].mana, 20)
    XCTAssertEqual(fetchedResult1[2].name, "name3")
    XCTAssertEqual(fetchedResult1[3].name, "name4")
    let fetchedResult2 = dflat.fetch(for: MyGame.SampleV2.Monster.self).all()
    XCTAssert(fetchedResult2.count == 4)
    XCTAssertEqual(fetchedResult1[0].name, "name1")
    XCTAssertEqual(fetchedResult1[0].mana, 10)
    XCTAssertEqual(fetchedResult2[1].name, "name2")
    XCTAssertEqual(fetchedResult1[1].mana, 20)
    XCTAssertEqual(fetchedResult2[2].name, "name3")
    XCTAssertEqual(fetchedResult2[3].name, "name4")
  }

  static let allTests = [
    ("testConcurrentUpdates", testConcurrentUpdates),
    ("testSQLiteWriteLock", testSQLiteWriteLock)
  ]
}
