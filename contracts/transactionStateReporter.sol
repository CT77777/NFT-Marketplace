//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract transactionStateReporter {
    enum transactionState {
        inProgress,
        completed,
        revoked
    }
}
