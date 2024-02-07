// SPDX-License-Identifier: GPL-3.0
        
pragma solidity >=0.4.22 <0.9.0;

// This import is automatically injected by Remix
import "remix_tests.sol"; 

// This import is required to use custom transaction context
// Although it may fail compilation in 'Solidity Compiler' plugin
// But it will work fine in 'Solidity Unit Testing' plugin
// import "remix_accounts.sol";
import "../DeFiInsurance/Copy_Insurance.sol";

// File name has to end with '_test.sol', this file can contain more than one testSuite contracts
contract testSuite {

    Insurance public insurance;
    /// 'beforeAll' runs before all other tests
    /// More special functions are: 'beforeEach', 'beforeAll', 'afterEach' & 'afterAll'
    function beforeAll() public {
        // <instantiate contract>
        insurance = new Insurance(
            0x5B38Da6a701c568545dCfcB03FcB875f56beddC4, "SpoToken", "SPT"
        );
    }

    function checkInsuranceTypeBasic() public {
        // Use 'Assert' methods: https://remix-ide.readthedocs.io/en/latest/assert_library.html
        insurance.setInsuranceType("Basic", 100);

        Assert.equal(
            insurance.getInsuranceFee("Basic"), 100, "Amount Payable for Basic should be equal to 100"
        );
        
    }

    function checkInsuranceTypeSilver() public {
        // Use 'Assert' methods: https://remix-ide.readthedocs.io/en/latest/assert_library.html
        insurance.setInsuranceType("Silver", 200);

        Assert.equal(
            insurance.getInsuranceFee("Silver"), 200, "Amount Payable for Silver should be equal to 200"
        );
    }

    function checkRemoveInsuranceTypeSilver() public {
        // Use 'Assert' methods: https://remix-ide.readthedocs.io/en/latest/assert_library.html
        insurance.removeInsuranceType("Silver");

        Assert.equal(
            insurance.getInsuranceFee("Silver"), 200, "Insurance Type removed"
        );
    }

    // function checkInsuranceTypeRepetition() public {
    //     // Use 'Assert' methods: https://remix-ide.readthedocs.io/en/latest/assert_library.html
    //     insurance.setInsuranceType("Basic", 200);
        
    //     Assert.equal(
    //         insurance.getInsuranceFee("Basic"), 200, "Insurance Type is already registered"
    //     );
    // }

    function checkSubscription() public {
        // Use 'Assert' methods: https://remix-ide.readthedocs.io/en/latest/assert_library.html
        insurance.getTokens(1000);
        insurance.subscribeForInsurance("Basic");
        
        Assert.equal(
            insurance.isUserSubscribed(), true, "User subscription status should be true"
        );
        Assert.equal(
            insurance.getBalance(), 900, "User balance should be 900"
        );
    }

    function checkDoubleSubscription() public {
        // Use 'Assert' methods: https://remix-ide.readthedocs.io/en/latest/assert_library.html
        // insurance.getTokens(1000);
        insurance.subscribeForInsurance("Silver");
        
        // Assert.equal(
        //     insurance.isUserSubscribed(), true, "User subscription status should be true"
        // );
    }

    function checkEndSubscription() public {
        // Use 'Assert' methods: https://remix-ide.readthedocs.io/en/latest/assert_library.html
        
        insurance.endSubscription();
        
        Assert.equal(
            insurance.isUserSubscribed(), false, "Subscription ended"
        );
    }

    // function checkEndSubscription2() public {
    //     // Use 'Assert' methods: https://remix-ide.readthedocs.io/en/latest/assert_library.html
        
    //     insurance.endSubscription();
        
    //     Assert.equal(
    //         insurance.isUserSubscribed(), false, "No Subscription"
    //     );
    // }

    function checkSubscription2() public {
        // Use 'Assert' methods: https://remix-ide.readthedocs.io/en/latest/assert_library.html
        
        Assert.equal(
            insurance.isUserSubscribed(), true, "User subscription status should be true"
        );
    }

    function checkPayCompensation() public {
        // Use 'Assert' methods: https://remix-ide.readthedocs.io/en/latest/assert_library.html
        insurance.payCompensation();

        Assert.equal(
            insurance.getBalance(), 1000, "User balance should be 1000"
        );
    }
}
    