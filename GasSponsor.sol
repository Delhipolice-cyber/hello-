// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GasSponsor {

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    // Event to log transactions
    event TransactionRelayed(address indexed from, address indexed to, uint256 amount);

    // Function to send transaction with gas sponsorship
    function sendTransactionWithGasSponsor(
        address receiver, 
        uint256 amount, 
        bytes memory signature
    ) external payable {
        require(msg.value > 0, "Insufficient gas");

        // Verify the signature
        // Assuming the message is the signed data provided by the frontend
        bytes32 message = keccak256(abi.encodePacked("I approve sending ", amount, " BNB to ", receiver, " for verification purposes."));
        address signer = recoverSigner(message, signature);
        require(signer == msg.sender, "Invalid signature");

        // Transfer BNB to the receiver
        (bool success, ) = receiver.call{value: amount}("");
        require(success, "Transaction failed");

        // Emit the event
        emit TransactionRelayed(msg.sender, receiver, amount);
    }

    // Helper function to recover the signer from the signature
    function recoverSigner(bytes32 message, bytes memory signature) internal pure returns (address) {
        bytes32 ethSignedMessageHash = _hashTypedDataV4(message);
        return ECDSA.recover(ethSignedMessageHash, signature);
    }

    // Override to handle signature recovery
    function _hashTypedDataV4(bytes32 message) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", message));
    }

    // Allow the owner to withdraw funds
    function withdraw() external {
        require(msg.sender == owner, "Only the owner can withdraw");
        payable(owner).transfer(address(this).balance);
    }

    // Fallback function to accept BNB
    receive() external payable {}
}
