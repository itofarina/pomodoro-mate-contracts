//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./PMToken.sol";

contract PomodoroManager {
    string public name = "Pomodoro Manager";
    PMToken public pmToken;
    uint32 public sessionLength;

    struct Pomodoro {
        uint32 staked;
        uint32 sessionsCompleted;
        uint32 readyTime;
    }

    event SessionCompleted(address account, Pomodoro pomodoro);
    event FundsWithdrawn(address account, uint256 newBalance);
    mapping(address => Pomodoro) doerToPomodoro;

    constructor(PMToken _pmToken, uint32 _sessionLengthMinutes) {
        pmToken = _pmToken;
        sessionLength = uint32(_sessionLengthMinutes * 1 minutes);
    }

    function _validPomodoro(Pomodoro memory pomodoro)
        private
        view
        returns (bool)
    {
        return (pomodoro.sessionsCompleted == 0 ||
            pomodoro.readyTime >= uint32(block.timestamp + sessionLength));
    }

    function _triggerReadyTime(Pomodoro storage pomodoro) private {
        pomodoro.readyTime = sessionLength + uint32(block.timestamp);
    }

    function sessionCompleted() public {
        Pomodoro storage pomodoro = doerToPomodoro[msg.sender];
        require(
            _validPomodoro(pomodoro),
            "A session must be completed to redeem a new token."
        );

        pomodoro.staked++;
        pomodoro.sessionsCompleted++;
        _triggerReadyTime(pomodoro);
        emit SessionCompleted(msg.sender, pomodoro);
    }
}
