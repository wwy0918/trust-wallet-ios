// Copyright SIX DAY LLC. All rights reserved.

import XCTest
@testable import Trust
import BigInt

class TransactionConfiguratorTests: XCTestCase {

    func testDefault() {
        let configurator = TransactionConfigurator(session: .make(), account: .make(), transaction: .make(gasLimit: BigInt(90000), gasPrice: .none))
        
        XCTAssertEqual(GasPriceConfiguration.default, configurator.configuration.gasPrice)
        XCTAssertEqual(GasLimitConfiguration.default, configurator.configuration.gasLimit)
        XCTAssertEqual(GasPriceConfiguration.default, configurator.calculatedGasPrice)
    }
    
    func testAdjustGasPrice() {
        let desiderGasPrice = BigInt(2000000000)
        let configurator = TransactionConfigurator(session: .make(), account: .make(), transaction: .make(gasPrice: desiderGasPrice))
        
        XCTAssertEqual(desiderGasPrice, configurator.configuration.gasPrice)
    }
    
    func testMinCalculatedGasPrice() {
        let configurator = TransactionConfigurator(session: .make(), account: .make(), transaction: .make(gasPrice: BigInt(0)))
        
        XCTAssertEqual(GasPriceConfiguration.min, configurator.calculatedGasPrice)
    }

    func testSetCalculatedGasPrice() {
        let gasPrice = BigInt(990000000000)
        let configurator = TransactionConfigurator(session: .make(), account: .make(), transaction: .make(gasPrice: gasPrice))

        XCTAssertEqual(gasPrice, configurator.calculatedGasPrice)
    }
    
    func testMaxGasPrice() {
        let configurator = TransactionConfigurator(session: .make(), account: .make(), transaction: .make(gasPrice: BigInt(990000000000)))
        
        XCTAssertEqual(GasPriceConfiguration.max, configurator.configuration.gasPrice)
    }
    
    func testLoadEtherConfiguration() {
        let configurator = TransactionConfigurator(session: .make(), account: .make(), transaction: .make(gasLimit: BigInt(90000), gasPrice: .none))

        configurator.load { _ in }
        
        XCTAssertEqual(BigInt(GasPriceConfiguration.default), configurator.configuration.gasPrice)
        XCTAssertEqual(BigInt(90000), configurator.configuration.gasLimit)
    }
    
    func testBalanceValidationWithNoBalance() {
        let emptyBalance = TransactionConfigurator(session: .make(), account: .make(), transaction: .make(gasLimit: BigInt(90000), gasPrice: .none))
        let status = emptyBalance.balanceValidStatus()
        XCTAssertEqual(false, status.sufficient)
        XCTAssertEqual(.insufficientGas, status.insufficientTextKey)
    }
    
    func testBalanceValidationWithEthTransaction() {
        let ethBalance = TransactionConfigurator(session: .makeWithEthBalance(amount: "10000000000000000000"), account: .make(), transaction: .make(gasLimit: BigInt(90000), gasPrice: .none))
        let status = ethBalance.balanceValidStatus()
        XCTAssertEqual(true, status.sufficient)
        XCTAssertEqual(.correct, status.insufficientTextKey)
    }

    func testBalanceValidationWithInsufficientEthTransaction() {
        let ethBalance = TransactionConfigurator(session: .makeWithEthBalance(amount: "900000"), account: .make(), transaction: .make(value: BigInt(1000000), gasLimit: BigInt(90000), gasPrice: .none))
        let status = ethBalance.balanceValidStatus()
        XCTAssertEqual(false, status.sufficient)
        XCTAssertEqual(.insufficientEther, status.insufficientTextKey)
    }

    func testBalanceValidationWithInsufficientGasTransaction() {
        let ethBalance = TransactionConfigurator(session: .makeWithEthBalance(amount: "100000000000000"), account: .make(), transaction: .make(gasLimit: BigInt(100000000000000), gasPrice: BigInt(21000000000)))
        let status = ethBalance.balanceValidStatus()
        XCTAssertEqual(false, status.sufficient)
        XCTAssertEqual(.insufficientGas, status.insufficientTextKey)
    }
    
    func testBalanceValidationWithTokensTransaction() {
        let ethBalanceForTokens = TransactionConfigurator(session: .makeWithEthBalance(amount: "10000000000000000000"), account: .make(), transaction: .makeToken(gasLimit: BigInt(90000), gasPrice: BigInt(21000000000)))
        let status = ethBalanceForTokens.balanceValidStatus()
        XCTAssertEqual(true, status.sufficient)
        XCTAssertEqual(.correct, status.insufficientTextKey)
    }
    
    func testBalanceValidationWithInsufficientTokensTransaction() {
        let ethBalanceForTokensNotEnough = TransactionConfigurator(session: .makeWithEthBalance(amount: "1000000"), account: .make(), transaction: .makeNotEnoughtToken(gasLimit: BigInt(90000), gasPrice: .none))
        let status = ethBalanceForTokensNotEnough.balanceValidStatus()
        XCTAssertEqual(false, status.sufficient)
        XCTAssertEqual(.insufficientToken, status.insufficientTextKey)
    }

    func testBalanceValidationForTokensWithInsufficientGasTransaction() {
        let emptyBalance = TransactionConfigurator(session: .makeWithEthBalance(amount: "1"), account: .make(), transaction: .makeToken(gasLimit: BigInt(90000), gasPrice: BigInt(21000000000)))
        let status = emptyBalance.balanceValidStatus()
        XCTAssertEqual(false, status.sufficient)
        XCTAssertEqual(.insufficientGas, status.insufficientTextKey)
    }
    
    func testValueToSent() {
        let configurator = TransactionConfigurator(session: .makeWithEthBalance(amount:"1"), account: .make(), transaction: .make(gasLimit: BigInt(900000000000000), gasPrice: .none))
        let value = configurator.valueToSend()
        XCTAssertEqual(.plus, value.sign)
    }
}
