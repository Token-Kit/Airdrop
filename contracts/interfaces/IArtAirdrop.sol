pragma solidity >=0.4.24;


interface IArtAirdrop {
    function claimable(address account) external view returns (uint256);
    function claim() external;
    function init() external;
    function update(address[] calldata accounts, uint256[] calldata points) external;
    function epochStart() external;
    function notifyAirdropAmount(uint256 amount) external;
    function recover(uint256 amount) external;
}
