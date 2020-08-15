//
//  ResolvingContainerTests.swift
//  ResolverTests
//
//  Created by Natan Zalkin on 02/08/2019.
//  Copyright © 2019 Natan Zalkin. All rights reserved.
//

import Quick
import Nimble

@testable import ResolvingContainer

class TestTest<Value> {}

typealias TestValue = TestTest<Int>

class ResolvingContainerTests: QuickSpec {
    override func spec() {
        describe("ResolvingContainer") {
            var container: ResolvingContainer!

            beforeEach {
                container = ResolvingContainer()
            }

            context("when registered resolver") {

                var instance: TestValue!

                beforeEach {
                    container.register(instance: TestValue())
                    instance = container.resolve(TestValue.self)
                }

                it("can resolve it later") {
                    expect(container.resolve(TestValue.self)).to(beIdenticalTo(instance))
                    expect(container.resolve(TestTest<Int>.self)).to(beIdenticalTo(instance))
                }

                context("and unregistered object") {
                    beforeEach {
                        container.unregister(TestTest<Int>.self)
                    }

                    it("fails to resolve the type") {
                        expect(container.resolve(TestValue.self)).to(beNil())
                        expect(container.resolve(TestTest<Int>.self)).to(beNil())
                    }
                }
            }

            context("when registered instance") {

                var instance: TestValue!

                beforeEach {
                    container.register(instance: TestValue())
                    instance = container.resolve(TestValue.self)
                }

                it("can resolve it later") {
                    expect(container.resolve(TestValue.self)).to(beIdenticalTo(instance))
                    expect(container.resolve(TestTest<Int>.self)).to(beIdenticalTo(instance))
                }

                context("and unregistered object") {
                    
                    beforeEach {
                        container.unregister(TestValue.self)
                    }

                    it("fails to resolve the type") {
                        expect(container.resolve(TestValue.self)).to(beNil())
                        expect(container.resolve(TestTest<Int>.self)).to(beNil())
                    }
                }

                context("and unregistered all objects") {

                    beforeEach {
                        container.unregisterAll()
                    }

                    it("fails to resolve any type") {
                        expect(container.resolve(TestValue.self)).to(beNil())
                        expect(container.resolve(TestTest<Int>.self)).to(beNil())
                    }
                }
            }
        }
    }
}
