# @version ^0.3.7
"""
@title Gaussian Currency Future
@author Sam Reeves
@license MIT
"""
o: public(address)
v: public(uint256)
epoch: public(uint256)
t_m: public(uint256)
mu: public(uint256)
sd: public(decimal)
t: public(uint256)
z: public(decimal)
bal: public(uint256)

@external
@payable
def __init__(_epoch: uint256):
    self.o = msg.sender
    self.v = msg.value
    self.t = block.timestamp
    self.epoch = _epoch
    self.t_m = self.t + self.epoch
    assert self.t < self.t_m, "Asset epoch is negative!"
    assert self.v > 0, "Initial value must be greater than zero!"
    self.z = 2.5
    self.bal = self.v
    self.mu = (self.t_m - self.t) / 2
    self.sd = convert(self.mu, decimal) / 1.7320508076

@internal
@view
def z_score():
	return abs(convert(self.t - self.mu, decimal) / self.sd)

@internal
@view
def tail():
	y = 13.1946891451 * self.z / (9.0 - self.z)
	return 1.0 - 1.0 / (1.0 + 2.7182818284 ** y)

@internal
@view
def weight(new_t: timestamp):
	z: decimal = self.z(self.t)

	if (self.t < self.mu) & (self.t > self.mu):
		return 1 - self.z - self.tail(z_n)
	else:
		return abs(self.tail(z_n) - self.tail(self.z))

@external
def give(noob: address):
    assert msg.sender == self.o, "Incorrect owner!"
    if msg.timestamp < self.t_m:
        amt = self.weight(msg.timestamp) * self.v
        self.o.transfer(amt)
        self.bal -= amt
        self.o = noob
    else:
        self.o.transfer(self.bal)
        selfdestruct(self.o)