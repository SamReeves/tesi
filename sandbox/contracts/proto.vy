# @version ^0.3.7
"""
@title Gaussian Currency Future
@author Sam Reeves
@license MIT
"""
value_0: public(uint256)
epoch: public(uint256)
start: public(uint256)
mu: public(uint256)
sigma: public(decimal)
z: public(decimal)
owner: public(address)
tail: public(decimal)

@external
@payable
def __init__(_epoch: uint256):
    assert _epoch > 0, "Epoch must be given in seconds"
    assert msg.value > 0, "Deployment must be given Eth in Wei"
    self.epoch = _epoch
    self.mu = (self.epoch) / 2
    self.sigma = convert(self.mu, decimal) / 3.4641016151
    self.z = 2.5
    self.value_0 = msg.value
    self.start = block.timestamp
    self.owner = msg.sender
    self.tail = 1.0

@external
def z_score(t: uint256):
    dif: uint256 = t - self.mu
    numerator: decimal = convert(dif, decimal)

    self.z = numerator / self.sigma

@external
def calculate_tail():
    e_whole: uint256 = 27182818284
    y: decimal = 13.1946891451 * self.z / (9.0 - self.z)

    scale_y: uint256 = pow_mod256(10000000000, convert(y, uint256))
    e_y: uint256 = pow_mod256(e_whole, scale_y)
    frac: decimal = convert(e_y, decimal) / convert(scale_y, decimal)

    self.tail = 1.0 - 1.0 / (1.0 + frac)