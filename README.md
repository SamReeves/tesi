# Cryptobonds

#### Sam Reeves 2022
#### CUNY School of Professional Studies


## Description

Smart contracts that return the initial value over a fixed period, wih programmed intervals,
and payment amounts based on predetermined closed form distributions.

Based on the Vyper smart contract language, targeting the EVM.  Modifying the built-in interface
ERC4626, we compile down from vyper to ABI to target the Ethereum Virtual Machine.  After the
contract is pushed to the network from a full node, it will use a predetermined amount of the
principle to make payments until it is empty, then it will "burn" itself.

These bonds do not accrue interest, but they cannot be modified in any way, and will continue
paying out as long as there is value left for gas fees.  The value of this as an asset is
related to the possibility of making effectively a perpetuity.

The uncertainty of the base cryptocurrency value, coupled with the uncertainty of gas fees, 
combined with the payout distribution offer a wide range of possibilities for valuation by the
market.

## Index

* text -- sources I read or cited
