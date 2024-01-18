## tokenLending: LEVEL 2 Challenges

**This is a basic lending and borrowing contract designed to accept/use a specified ERC20 token.**


The main contracts of this repo are:

-   **token.sol**: The ERC20 token that is deployed in tandem with the lending/borrowing contract and is the only ERC20 token that is compatible with the contract

-   **tokenLending.sol**: A basic lending and borrowing contract designed to be compatible only with the `token.sol` ERC20 contract

-   **HelperConfig.s.sol**: Used to help automate deployment

-   **tokenLendingDeployment.s.sol**: Deployment contract used to deploy both the tokenLending.sol and token.sol contracts 

**test_tokenLending.t.sol**: Tests file for all the above listed contracts and their functionalities

