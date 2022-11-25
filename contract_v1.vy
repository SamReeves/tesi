# @version ^0.3.7

v: immutable(uint256)
epoch: immutable(timedelta)
mu: immutable(uint256)
sd: immutable(uint256)

o: public(address)
t: public(timestamp)
z: public(uint256)

@external
def __init__(owner: address, v_0: uint256, t: timestamp, t_m: timestamp):
    self.o = msg.sender
    self.v_0 = msg.value
    self.t = block.timestamp
    self.t_m = t + self.epoch

    assert block.timestamp > t_m, "Asset epoch is negative!"
    assert msg.value > 0, "Initial value must be greater than zero!"
    
    self.mu = floor((t_m - t) / 2)
    self.sd = self.mu / 1.7320508076

@internal
def z_score():
	return abs(convert(self.t - self.mu, decimal) / self.sd)

@internal
def tail():
	y = 13.1946891451 * self.z / (9 - self.z)
	return 1 - 1 / (1 + 2.7182818284 ** y)

@internal
def weight(new_t: timestamp):
	z: decimal = self.z(self.t)

	if (self.t < self.mu) & (self.t > self.mu):
		return 1 - self.z - tail(z_n)
	else:
		return abs(tail(z_n) - self.z)

@payable
@external
def give(noob: address):
    assert msg.sender == self.o, "Incorrect owner!"
    if msg.timestamp < self.t_m:
        self.o = noob