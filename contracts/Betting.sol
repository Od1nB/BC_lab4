// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.6.0 <=0.8.9;

contract Betting {
    /* Define the Bet struct */
    struct Bet {
        bytes32 outcome; // the guessed outcome
        uint256 amount; // the bet amount
    }

    address public owner; // the contract owner
    address public oracle; // the oracle that will decide the outcome of the betting
    address[] public gamblers; // list of the gamblers addresses
    mapping(address => bool) public isGambler;

    /* Maps the gambler's addresses to their bets */
    mapping(address => Bet) public bets;

    bool public decisionMade;

    /* List of all winners (maps are not iterable in solidity)*/
    address[] public winners;
    /* Maps the winners to their prize amount */
    mapping(address => uint256) public wins;

    /* Keep track of all possible outcomes */
    bytes32[] public outcomes;
    /* Map the valid outcomes for his betting */
    mapping(bytes32 => bool) public validOutcomes;
    /* Keep track of the total bet amount in all outcomes */
    mapping(bytes32 => uint256) public outcomeBets;

    /* Add any events you think are necessary */
    event BetMade(
        address indexed gambler,
        bytes32 indexed outcome,
        uint256 amount
    );
    event Winners(address[] indexed wins, uint256 totalPrize);
    event OracleChanged(
        address indexed previousOracle,
        address indexed newOracle
    );
    event Withdrawn(address indexed gambler, uint256 amount);

    /* Uh Oh, what are these? */
    modifier onlyOwner() {
        require(msg.sender == owner, "sender isn't the owner");
        _;
    }

    modifier onlyOracle() {
        require(isOracle(msg.sender), "sender isn't the oracle");
        _;
    }

    modifier requireOracle() {
        require(oracle != address(0), "no oracle found");
        _;
    }

    modifier outcomeExists(bytes32 outcome) {
        require(validOutcomes[outcome], "outcome not registered");
        _;
    }

    modifier onlyWinners() {
        require(wins[msg.sender] > 0, "sender should be a winner");
        _;
    }

    /* Constructor function, where owner and outcomes are set */
    constructor(bytes32[] memory initOutcomes) {
        /* TODO (students) */
        // should register at least 2 possible outcomes,
        require(initOutcomes.length > 1, "must register at least 2 outcomes");
        outcomes = initOutcomes;
        for (uint256 i = 0; i < outcomes.length; i++) {
            validOutcomes[outcomes[i]] = true;
        }
        // and define the contract owner.
        owner = msg.sender;
    }

    function setOutcomes(bytes32[] memory _outcomes) public {
        /* TODO (students) */
        // I guess this function can be used to initialize the outcomes
        require(_outcomes.length > 1, "must register at least 2 outcomes");
        for (uint256 i = 0; i < outcomes.length; i++) {
            validOutcomes[outcomes[i]] = false;
        }
        outcomes = _outcomes;
        for (uint256 i = 0; i < outcomes.length; i++) {
            validOutcomes[outcomes[i]] = true;
        }
    }

    /**
     * @notice This function allows owner to chooses their trusted Oracle.
     * @param newOracle The address of the new oracle.
     */
    function chooseOracle(address newOracle) public onlyOwner {
        /* TODO (students) */
        // Must be called only by the contract owner
        // The oracle cannot be neither a gambler or the owner
        require(newOracle != owner, "the owner cannot be an oracle");
        require(
            isGambler[newOracle] == false,
            "the oracle cannot be a gambler"
        );
        // Should emit OracleChanged event
        oracle = newOracle;
        emit OracleChanged(oracle, newOracle);
    }

    /**
     * @notice Make a bet.
     * @param outcome The hash of the outcome to bet on.
     */
    function makeBet(bytes32 outcome)
        public
        payable
        outcomeExists(outcome)
        requireOracle
    {
        /* TODO (students) */
        // Owner and oracle cannot make a bet
        require(msg.sender != owner, "the owner cannot bet");
        require(msg.sender != oracle, "the oracle of the betting cannot bet");
        // A gambler cannot bet twice
        require(bets[msg.sender].amount == 0, "each gambler can only bet once");
        // A gambler can only bet on a registered outcome //Modifier
        // An oracle should be assigned before starting bets //Modifier
        // Must be impossible to bet after decision was made
        require(!decisionMade, "cannot bet after decision was made");
        // Betters are registered by placing a bet
        bets[msg.sender] = Bet(outcome, msg.value);
        isGambler[msg.sender] = true;
        gamblers.push(msg.sender);
        outcomeBets[outcome] += msg.value;
        // Should emit BetMade event
        emit BetMade(msg.sender, outcome, msg.value);
    }

    /**
     * @notice Decide on an outcome.
     * @param decidedOutcome The chosen outcome.
     */
    function makeDecision(bytes32 decidedOutcome) public onlyOracle {
        /* TODO (students) */
        // Must be called only by the oracle //Modifier
        // Winning outcome must exist
        require(validOutcomes[decidedOutcome], "outcome not registered");
        // Gamblers and bets must exists before make a decision
        // for (uint256 g = 0; g < gamblers.length; g++) {
        //     require(isGambler[gamblers[g]], "mess");
        // }
        // The oracle must chooses which outcome wins calling and set the winners.
        require(!decisionMade, "can make decision only once");
        uint256 totBetAmount = 0;
        uint256 totLosersAmount = 0;
        for (uint256 g = 0; g < gamblers.length; g++) {
            totBetAmount += bets[gamblers[g]].amount;
            if (bets[gamblers[g]].outcome == decidedOutcome) {
                winners.push(gamblers[g]);
            } else {
                totLosersAmount += bets[gamblers[g]].amount;
            }
        }
        if (winners.length == gamblers.length) {
            for (uint256 node = 0; node < winners.length; node++) {
                wins[winners[node]] += bets[winners[node]].amount;
            }
        } else if (winners.length == 0) {
            wins[oracle] += totBetAmount;
        } else {
            for (uint256 w = 0; w < winners.length; w++) {
                address w1 = winners[w];
                wins[w1] =
                    bets[w1].amount +
                    (bets[w1].amount * totLosersAmount) /
                    outcomeBets[decidedOutcome];
            }
        }
        // Should be called only once before reset
        decisionMade = true;
        // The winners receive a proportional share of the total funds at stake if they all bet on the correct outcome
        // If all gamblers bet on the correct outcome, then they must get reimbursed their funds.
        // If no gamblers bet on the correct outcome, then the oracle wins the sum of the funds.
        // Should emit Winners event
        emit Winners(winners, totBetAmount);
    }

    /**
     * @notice This function allows the winners to withdraw their
     * winnings safely (if they win something).
     * @param amount The amount to be withdrawn
     */
    function withdraw(uint256 amount) public onlyWinners {
        /* TODO (students) */
        // Should only be called by winners //Modifier
        // Winners can withdraw multiple times until the total amount of their prize
        require(amount <= wins[msg.sender], "insufficient requested amount");
        // Should emit Withdrawn event
        wins[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        emit Withdrawn(msg.sender, amount);
    }

    /**
     * @notice Reset the contract state
     */
    function contractReset() public onlyOwner {
        /* TODO (students) */
        // Must only be called by the contract owner. //Modifier
        // Should not allow reset the contract state before a decision is made
        require(decisionMade == true, "cannot reset before decision");
        // Must reset the contract variables to the initial state to allow new bettings and outcomes.
        decisionMade = false;
        for (uint256 w = 0; w < winners.length; w++) {
            wins[winners[w]] = 0;
        }
        delete winners;

        for (uint256 g = 0; g < gamblers.length; g++) {
            isGambler[gamblers[g]] = false;
            bets[gamblers[g]] = Bet(0, 0);
        }
        delete gamblers;

        for (uint256 o = 0; o < outcomes.length; o++) {
            outcomeBets[outcomes[o]] = 0;
            validOutcomes[outcomes[o]] = false;
        }
        delete outcomes;
        owner = address(0x0);
        oracle = address(0x0);
    }

    /**
     * @dev This function allows anyone to check the amount
     * already betted per outcome.
     * @param outcome The hash of the outcome to be checked.
     * @return The amount betted for the given outcome.
     */
    function checkOutcome(bytes32 outcome) public view returns (uint256) {
        /* TODO (students) */
        // Must revert if outcome does not exist
        require(validOutcomes[outcome], "outcome not registered");
        // Returns the current stake for the given outcome
        return outcomeBets[outcome];
    }

    /**
     * @notice This function is similar to `checkOutcome` but
     * it receives the outcome as string.
     * @param outcomeString The string representation of the outcome
     * to be checked.
     * @dev It uses the `keccak256` hash function to get the hash of the `outcomeString`
     * @return The amount betted for the given outcome.
     */
    function checkOutcomeString(string memory outcomeString)
        public
        view
        returns (uint256)
    {
        /* TODO (students) */
        bytes32 outbit = bytes32(keccak256(abi.encodePacked(outcomeString)));
        // hash outcomestring using keccak256. Then checkOutcome
        return checkOutcome(outbit);
    }

    /**
     * @notice This function allows anyone to check their winnings.
     * @return The winning amount of the msg.sender if it exists.
     */
    function checkWinnings() public view returns (uint256) {
        return wins[msg.sender];
    }

    function isOracle(address _oracle) public view returns (bool) {
        return oracle == _oracle;
    }

    function getGamblers() public view returns (address[] memory) {
        return gamblers;
    }

    function getWinners() public view returns (address[] memory) {
        return winners;
    }

    function getOutcomes() public view returns (bytes32[] memory) {
        return outcomes;
    }
}
