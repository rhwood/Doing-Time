//
//  EventTests.swift
//  Doing TimeTests
//
//  Created by Randall Wood on 2020-11-22.
//
//  Copyright 2020 Randall Wood DBA Alexandria Software
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

import XCTest
@testable import Doing_Time

class EventTests: XCTestCase {

    var event: Event?

    override func setUpWithError() throws {
        event = Event(title: "Test",
                      start: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
                      end: Calendar.current.date(byAdding: .day, value: 1, to: Date())!,
                      includeEnd: true)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        // Nothing to do
    }

    func testSingleDayIncludeEndTodayIsComplete() throws {
        let subject = Event()
        XCTAssertTrue(subject.includeEnd)
        XCTAssertEqual(subject.todayIs, .complete)
        XCTAssertEqual(subject.totalDuration, 1)
        XCTAssertEqual(subject.completedDuration, 1)
        XCTAssertEqual(subject.remainingDuration, 0)
        XCTAssertEqual(subject.completedPercentage, 1.0, accuracy: 0.0)
        XCTAssertEqual(subject.remainingPercentage, 0.0, accuracy: 0.0)
        XCTAssertEqual(subject.todayPercentage, 0.0, accuracy: 0.0)
    }

    func testSingleDayIncludeEndTodayIsRemaining() throws {
        let subject = Event(todayIs: .remaining)
        XCTAssertTrue(subject.includeEnd)
        XCTAssertEqual(subject.todayIs, .remaining)
        XCTAssertEqual(subject.totalDuration, 1)
        XCTAssertEqual(subject.completedDuration, 0)
        XCTAssertEqual(subject.remainingDuration, 1)
        XCTAssertEqual(subject.completedPercentage, 0.0, accuracy: 0.0)
        XCTAssertEqual(subject.remainingPercentage, 1.0, accuracy: 0.0)
        XCTAssertEqual(subject.todayPercentage, 0.0, accuracy: 0.0)
    }

    func testLastDayIncludeEnd() throws {
        let subject = try! XCTUnwrap(event)
        XCTAssertTrue(subject.includeEnd)
        XCTAssertEqual(Calendar.current.component(.hour, from: subject.lastDay), 23)
        XCTAssertEqual(Calendar.current.component(.minute, from: subject.lastDay), 59)
        XCTAssertEqual(Calendar.current.component(.second, from: subject.lastDay), 59)
        XCTAssertEqual(Calendar.current.component(.day, from: subject.lastDay), Calendar.current.component(.day, from: subject.end))
        XCTAssertEqual(subject.totalDuration, 3)
        XCTAssertEqual(subject.totalDurationAsString, "3")
    }

    func testLastDayExcludeEnd() throws {
        var subject = try! XCTUnwrap(event)
        subject.includeEnd = false
        XCTAssertFalse(subject.includeEnd)
        XCTAssertEqual(Calendar.current.component(.hour, from: subject.lastDay), 23)
        XCTAssertEqual(Calendar.current.component(.minute, from: subject.lastDay), 59)
        XCTAssertEqual(Calendar.current.component(.second, from: subject.lastDay), 59)
        XCTAssertEqual(Calendar.current.component(.day, from: subject.lastDay), Calendar.current.component(.day, from: subject.end) - 1)
        XCTAssertEqual(subject.totalDuration, 2)
        XCTAssertEqual(subject.totalDurationAsString, "2")
    }

    func testDurationsIncludeEndTodayIsUncounted() throws {
        var subject = try! XCTUnwrap(event)
        subject.todayIs = .uncounted
        XCTAssertEqual(subject.todayIs, .uncounted)
        XCTAssertTrue(subject.includeEnd)
        XCTAssertEqual(subject.totalDuration, 3)
        XCTAssertEqual(subject.completedDuration, 1)
        XCTAssertEqual(subject.remainingDuration, 1)
        XCTAssertEqual(subject.completedPercentage, 0.33, accuracy: 0.01)
        XCTAssertEqual(subject.remainingPercentage, 0.33, accuracy: 0.01)
        XCTAssertEqual(subject.todayPercentage, 0.33, accuracy: 0.01)
    }

    func testDurationsIncludeEndTodayIsRemaining() throws {
        var subject = try! XCTUnwrap(event)
        subject.todayIs = .remaining
        XCTAssertEqual(subject.todayIs, .remaining)
        XCTAssertTrue(subject.includeEnd)
        XCTAssertEqual(subject.totalDuration, 3)
        XCTAssertEqual(subject.completedDuration, 1)
        XCTAssertEqual(subject.remainingDuration, 2)
        XCTAssertEqual(subject.completedPercentage, 0.33, accuracy: 0.01)
        XCTAssertEqual(subject.remainingPercentage, 0.66, accuracy: 0.01)
        XCTAssertEqual(subject.todayPercentage, 0.0, accuracy: 0.0)
    }

    func testDurationsIncludeEndTodayIsCompleted() throws {
        var subject = try! XCTUnwrap(event)
        subject.todayIs = .complete
        XCTAssertEqual(subject.todayIs, .complete)
        XCTAssertTrue(subject.includeEnd)
        XCTAssertEqual(subject.totalDuration, 3)
        XCTAssertEqual(subject.completedDuration, 2)
        XCTAssertEqual(subject.remainingDuration, 1)
        XCTAssertEqual(subject.completedPercentage, 0.66, accuracy: 0.01)
        XCTAssertEqual(subject.remainingPercentage, 0.33, accuracy: 0.01)
        XCTAssertEqual(subject.todayPercentage, 0.0, accuracy: 0.0)
    }

    func testSetDurationIncludeEnd() throws {
        var subject = try! XCTUnwrap(event)
        subject.includeEnd = true
        XCTAssertTrue(subject.includeEnd)
        XCTAssertEqual(subject.totalDuration, 3)
        subject.totalDurationAsString = "4"
        XCTAssertEqual(subject.totalDuration, 4)
        // when adding duration to firstDay to match expected value with includeEnd,
        // add 1 less than total duration
        XCTAssertEqual(subject.end, Calendar.current.date(byAdding: .day, value: 3, to: subject.firstDay))
    }

    func testSetDurationExcludeEnd() throws {
        var subject = try! XCTUnwrap(event)
        subject.includeEnd = false
        XCTAssertFalse(subject.includeEnd)
        XCTAssertEqual(subject.totalDuration, 2)
        subject.totalDuration = 3
        XCTAssertEqual(subject.totalDuration, 3)
        // when adding duration to firstDay to match expected value with out includeEnd,
        // use total duration
        XCTAssertEqual(subject.end, Calendar.current.date(byAdding: .day, value: 3, to: subject.firstDay))
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
