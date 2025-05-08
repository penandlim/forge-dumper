## ForgeDumper Usage

`ForgeDumper` is a Solidity library designed to dump the current forge test state into a JSON file that is compatible with Anvil's `anvil_loadState` RPC method. This is useful for creating reproducible test environments or for inspecting state at specific points in your tests.

### How to Use

1.  **Import `ForgeDumper`**: Add `import {ForgeDumper} from "../src/ForgeDumper.sol";` (adjust path as necessary) to your test contract.

2.  **Set Up a Base State (Optional but Recommended)**:
    In your `setUp()` function, after deploying and initializing your contracts to a desired base state, you can dump this state:
    ```solidity
    // In your test contract (e.g., MyContract.t.sol)
    import {Test, console} from "forge-std/Test.sol";
    import {ForgeDumper} from "../src/ForgeDumper.sol"; // Adjust path if needed
    import {MyContract} from "../src/MyContract.sol";

    contract MyContractTest is Test {
        MyContract internal myContract;
        string constant basePath = "dumpStates/base_state.json";

        function setUp() public {
            myContract = new MyContract();
            myContract.initializeSomething(42);
            // Dump the initial state
            ForgeDumper.dumpState(basePath);
        }
    }
    ```
    This creates `dumpStates/base_state.json` (the directory will be created if it doesn't exist).

3.  **Dump State in Tests**:
    In your individual test functions, after performing actions that change the state, you can dump the new state. If you created a base state, you can provide its path to create a merged state dump where the new state is layered on top of the base state.

    *   **Dumping state without a base (fresh dump)**:
        ```solidity
        function test_SomeAction() public {
            myContract.performAction(123);
            // ... other actions and assertions ...
            ForgeDumper.dumpState("dumpStates/some_action_state.json");
        }
        ```
        Note that without a base dump, the resulting file will only contain state that was accessed within this specific test function. Any storage accesses that occurred during `setUp()` will not be included in the dump.

    *   **Dumping state and merging with a base state**:
        ```solidity
        function test_AnotherActionWithBase() public {
            // Assumes setUp created basePath = "dumpStates/base_state.json"
            myContract.performAnotherAction(789);
            // ... other actions and assertions ...
            ForgeDumper.dumpState(basePath, "dumpStates/another_action_state.json");
        }
        ```
        In this case, `dumpStates/another_action_state.json` will contain the initial state from `base_state.json` plus any modifications and new state from the `test_AnotherActionWithBase` function. Values from the current test's dump will overwrite values from the base state if there are overlaps.

### Output

The library generates JSON files in the format expected by Anvil's `anvil_loadState`. You can then use these files to start an Anvil instance with a specific state.

For example, after running your tests and generating `dumpStates/my_desired_state.json`:

```shell
$ anvil --load-state dumpStates/my_desired_state.json
```
