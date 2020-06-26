import Dflat
@testable import SQLiteDflat
import FlatBuffers
import XCTest
import Foundation
import SQLite3

class SchemaUpgradeTests: XCTestCase {
  var filePath: String?
  var dflat: Workspace?
  
  override func setUp() {
    let filePath = NSTemporaryDirectory().appending("\(UUID().uuidString).db")
    self.filePath = filePath
    dflat = SQLiteWorkspace(filePath: filePath, fileProtectionLevel: .noProtection)
  }
  
  override func tearDown() {
  }

  func testQueryIndexWithoutIndexRows() {
    guard let dflat = dflat else { return }
    guard let filePath = filePath else { return }
    let expectation = XCTestExpectation(description: "transcation done")
    dflat.performChanges([MyGame.Sample.Monster.self], changesHandler: {txnContext in
      let creationRequest1 = MyGame.Sample.MonsterChangeRequest.creationRequest()
      creationRequest1.name = "name1"
      creationRequest1.mana = 100
      creationRequest1.color = .green
      txnContext.submit(creationRequest1)
      let creationRequest2 = MyGame.Sample.MonsterChangeRequest.creationRequest()
      creationRequest2.name = "name2"
      creationRequest2.mana = 50
      creationRequest2.color = .green
      txnContext.submit(creationRequest2)
      let creationRequest3 = MyGame.Sample.MonsterChangeRequest.creationRequest()
      creationRequest3.name = "name3"
      creationRequest3.mana = 20
      creationRequest3.color = .green
      txnContext.submit(creationRequest3)
      let creationRequest4 = MyGame.Sample.MonsterChangeRequest.creationRequest()
      creationRequest4.name = "name4"
      creationRequest4.mana = 120
      creationRequest4.color = .green
      txnContext.submit(creationRequest4)
    }) { success in
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 10.0)
    // Now delete the index, we know the table name.
    let connection = SQLiteConnection(filePath: filePath, createIfMissing: false)
    sqlite3_exec(connection?.sqlite!, "DELETE FROM mygame__sample__monster__mana", nil, nil, nil)
    let fetchedResult = dflat.fetchFor(MyGame.Sample.Monster.self).where(MyGame.Sample.Monster.mana < 100, orderBy: [MyGame.Sample.Monster.mana.ascending])
    XCTAssert(fetchedResult.count == 2)
    XCTAssertEqual(fetchedResult[0].name, "name3")
    XCTAssertEqual(fetchedResult[1].name, "name2")
    connection?.close()
  }

  func testQueryIndexWithPartialIndexRows() {
    guard let dflat = dflat else { return }
    guard let filePath = filePath else { return }
    let expectation = XCTestExpectation(description: "transcation done")
    dflat.performChanges([MyGame.Sample.Monster.self], changesHandler: {txnContext in
      let creationRequest1 = MyGame.Sample.MonsterChangeRequest.creationRequest()
      creationRequest1.name = "name1"
      creationRequest1.mana = 100
      creationRequest1.color = .green
      txnContext.submit(creationRequest1)
      let creationRequest2 = MyGame.Sample.MonsterChangeRequest.creationRequest()
      creationRequest2.name = "name2"
      creationRequest2.mana = 50
      creationRequest2.color = .green
      txnContext.submit(creationRequest2)
      let creationRequest3 = MyGame.Sample.MonsterChangeRequest.creationRequest()
      creationRequest3.name = "name3"
      creationRequest3.mana = 20
      creationRequest3.color = .green
      txnContext.submit(creationRequest3)
      let creationRequest4 = MyGame.Sample.MonsterChangeRequest.creationRequest()
      creationRequest4.name = "name4"
      creationRequest4.mana = 120
      creationRequest4.color = .green
      txnContext.submit(creationRequest4)
    }) { success in
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 10.0)
    // Now delete the index, we know the table name.
    let connection = SQLiteConnection(filePath: filePath, createIfMissing: false)
    sqlite3_exec(connection?.sqlite!, "DELETE FROM mygame__sample__monster__mana WHERE rowid >= 3", nil, nil, nil)
    let fetchedResult = dflat.fetchFor(MyGame.Sample.Monster.self).where(MyGame.Sample.Monster.mana < 120, orderBy: [MyGame.Sample.Monster.mana.ascending])
    XCTAssert(fetchedResult.count == 3)
    XCTAssertEqual(fetchedResult[0].name, "name3")
    XCTAssertEqual(fetchedResult[1].name, "name2")
    XCTAssertEqual(fetchedResult[2].name, "name1")
    connection?.close()
  }

  func testQueryIndexWithoutIndexTable() {
    guard let dflat = dflat else { return }
    guard let filePath = filePath else { return }
    let expectation = XCTestExpectation(description: "transcation done")
    dflat.performChanges([MyGame.Sample.Monster.self], changesHandler: {txnContext in
      let creationRequest1 = MyGame.Sample.MonsterChangeRequest.creationRequest()
      creationRequest1.name = "name1"
      creationRequest1.mana = 100
      creationRequest1.color = .green
      txnContext.submit(creationRequest1)
      let creationRequest2 = MyGame.Sample.MonsterChangeRequest.creationRequest()
      creationRequest2.name = "name2"
      creationRequest2.mana = 50
      creationRequest2.color = .green
      txnContext.submit(creationRequest2)
      let creationRequest3 = MyGame.Sample.MonsterChangeRequest.creationRequest()
      creationRequest3.name = "name3"
      creationRequest3.mana = 20
      creationRequest3.color = .green
      txnContext.submit(creationRequest3)
      let creationRequest4 = MyGame.Sample.MonsterChangeRequest.creationRequest()
      creationRequest4.name = "name4"
      creationRequest4.mana = 120
      creationRequest4.color = .green
      txnContext.submit(creationRequest4)
    }) { success in
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 10.0)
    // Now delete the index, we know the table name.
    let connection = SQLiteConnection(filePath: filePath, createIfMissing: false)
    sqlite3_exec(connection?.sqlite!, "DROP TABLE mygame__sample__monster__mana", nil, nil, nil)
    let fetchedResult = dflat.fetchFor(MyGame.Sample.Monster.self).where(MyGame.Sample.Monster.mana < 100, orderBy: [MyGame.Sample.Monster.mana.ascending])
    XCTAssert(fetchedResult.count == 2)
    XCTAssertEqual(fetchedResult[0].name, "name3")
    XCTAssertEqual(fetchedResult[1].name, "name2")
    connection?.close()
  }
}