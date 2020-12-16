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

                beforeEach {
                    container.register(resolver: { TestValue() })
                }
                
                it("instance not stored in the container") {
                    expect(container.isInstantiated(TestValue.self)).to(beFalse())
                    expect(container.resolve(TestValue.self)).to(beAKindOf(TestValue.self))
                    expect(container.isInstantiated(TestValue.self)).to(beFalse())
                }
                
                it("each time resolves to different instance") {
                    let first = container.resolve(TestValue.self)
                    expect(first).to(beAKindOf(TestValue.self))
                    let second = container.resolve(TestTest<Int>.self)
                    expect(second).to(beAKindOf(TestValue.self))
                    expect(first).notTo(beIdenticalTo(second))
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

            context("when registered an instance") {

                var instance: TestValue!

                beforeEach {
                    container.register(instance: TestValue())
                    instance = container.resolve(TestValue.self)
                }

                it("can resolve it later") {
                    expect(container.resolve(TestValue.self)).to(beIdenticalTo(instance))
                    expect(container.resolve(TestTest<Int>.self)).to(beIdenticalTo(instance))
                }

                it("instance is stored in the container") {
                    expect(container.isInstantiated(TestValue.self)).to(beTrue())
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
                
                context("and discarded the instance") {
                    var discarded: Any!
                    
                    beforeEach {
                        discarded = container.discard(TestValue.self)
                    }
                    
                    it("discarded to initial instance") {
                        expect(discarded).to(beIdenticalTo(instance))
                    }

                    it("resolves to different instance") {
                        expect(container.resolve(TestValue.self)).notTo(beIdenticalTo(instance))
                    }
                }
                
                context("and discarded all instances") {
                    
                    beforeEach {
                        container.discardAll()
                    }
                    
                    it("removed all instances from registry") {
                        let result = container.registry.values.reduce(into: true) { (result, item) in
                            guard result, case ResolvingContainer.Item.Storage.none = item.storage else {
                                result = false
                                return
                            }
                        }
                        expect(result).to(beTrue())
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
            
            context("when registered provisional instance") {

                beforeEach {
                    container.register(provisional: TestValue())
                }

                it("instance is stored in the container while captured strongly outside") {
                    var instance = container.resolve(TestValue.self)
                    expect(container.resolve(TestValue.self)).to(beIdenticalTo(instance))
                    expect(container.resolve(TestTest<Int>.self)).to(beIdenticalTo(instance))
                    instance = nil
                    expect(container.isInstantiated(TestValue.self)).to(beFalse())
                }
                
                context("when resolved the instance and captured it strongly") {

                    var instance: TestValue!

                    beforeEach {
                        instance = container.resolve(TestValue.self)
                    }

                    it("can resolve it later") {
                        expect(container.resolve(TestValue.self)).to(beIdenticalTo(instance))
                        expect(container.resolve(TestTest<Int>.self)).to(beIdenticalTo(instance))
                    }

                    context("and discarded the instance") {
                        var discarded: Any!
                        
                        beforeEach {
                            discarded = container.discard(TestValue.self)
                        }
                        
                        it("discarded to initial instance") {
                            expect(discarded).to(beIdenticalTo(instance))
                        }

                        it("resolves to different instance") {
                            expect(container.resolve(TestValue.self)).notTo(beIdenticalTo(instance))
                        }
                    }
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
