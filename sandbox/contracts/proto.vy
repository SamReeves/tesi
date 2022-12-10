# @version ^0.3.7
"""
@title Gaussian Currency Future
@author Sam Reeves
@license MIT
"""
value: public(uint256)
start: public(uint256)
epoch: public(uint256)
mu: public(uint256)
sigma: public(uint256)
owner: public(address)
t: public(uint256)
z: public(decimal)
left: public(decimal)

@external
@payable
def __init__(_epoch: uint256):
    """
    Initialize the contract with the epoch in seconds.
    Throw errors if the epoch is too short or no Eth is sent.
    """
    assert _epoch > 60 * 60 * 24, "Lifetime must be at least 86400 seconds."
    assert msg.value > 0, "Deployment must be given Eth in Wei."
    self.start = block.timestamp
    self.epoch = _epoch
    self.owner = msg.sender
    self.value = msg.value
    self.mu = _epoch / 2
    self.sigma = convert((convert(_epoch, decimal) / 3.464101615), uint256)
    self.t = 0
    self.z = 2.5
    self.left = 1.0

@external
@payable
def __default__():
    """
    Returns an error if Eth is sent to the contract or the 
    message comes from the wrong owner.
    """
    assert msg.value == 0, "No Eth should be sent to this function."
    assert msg.sender == self.owner, "Only the owner can makes calls."

@internal
@pure
def z_score(t: uint256, mu: uint256, sigma: uint256) -> decimal:
    """
    Take a time and return the z-score.
    """
    z: decimal = 0.0
    if t > mu:
        z = convert(t - mu, decimal) / convert(sigma, decimal)
    else:
        z = convert(mu - t, decimal) / convert(sigma, decimal)
    return z

@internal
@pure
def e_power(x: decimal) -> decimal:
    """
    List whole, tenth, and hundredth powers of e.
    Compute the non-integer power of e by the product rule of exponents.
    """
    ones: decimal[10] = [1.0, 2.7182818285, 7.3890560989, 20.0855369232, 54.5981500331,
        148.4131591026, 403.4287934927, 1096.6331584285, 2980.9579870417, 8103.0839275754]
    tenths: decimal[10] = [1.0, 1.105, 1.221, 1.35, 1.492, 1.649, 1.822, 2.014, 2.226, 2.46]
    hundredths: decimal[10] = [1.0, 1.01, 1.02, 1.03, 1.041, 1.051, 1.062, 1.073, 1.083, 1.094]

    r: int256 = floor(x)
    f10: int256 = floor(x * 10.0 - convert(r * 10, decimal))
    f100: int256 = floor(x * 100.0 - convert(r * 100, decimal) - convert(f10 * 10, decimal))

    ans: decimal = hundredths[f100] * tenths[f10] * ones[r]
    return ans

@internal
@pure
def y(z: decimal) -> decimal:
    """
    Take a z-score and return the a constant.
    First part of calculating a PDF.
    Credit: Lin 1990 "Pocket Calculator Approximation of the Normal Distribution"
    """    
    return 13.194689145 * z / (9.0 - z) # tail approximation, step 1

@internal
@pure
def tail(_exp: decimal) -> decimal:
    return 1.0 - 1.0 / (1.0 + _exp)

@internal
@pure
def weight(left: decimal, right: decimal,
                      phase: uint8) -> decimal:
    """
    Take a left and right tail and calculate a payment.
    Return the area under the curve for the relevant times.
    """
    weight: decimal = 0.0

    if phase == 0:
        weight = left - right
    elif phase == 1:
        weight = left - (1.0 - right)
    else:
        weight = (1.0 - left) - (1.0 - right)
    return weight

@internal
@pure
def payment(v: uint256, w: decimal) -> uint256:
    return convert((convert(v, decimal) * w), uint256)

@external
@payable
def give(new: address):
    """
    Take a time and return the payment.
    """
    assert msg.sender == self.owner, "Only the owner can makes calls."
    assert new != ZERO_ADDRESS, "New owner cannot be the zero address."
    assert msg.value == 0, "No Eth should be sent to this function."
    assert new != self.owner, "New owner cannot be the same as the old owner."

    if block.timestamp > self.start + self.epoch:
        send(self.owner, self.balance)
        selfdestruct(self.owner)
    else: 
        t1: uint256 = block.timestamp - self.start
        mu: uint256 = self.mu
        sigma: uint256 = self.sigma
        z1: decimal = self.z
        tail1: decimal = self.left
        phase: uint8 = 0
        if t1 > mu:
            phase = 1
        t2: uint256 = block.timestamp - self.start
        if t2 > mu:
            phase = 2
        z2: decimal = self.z_score(t2, mu, sigma)
        tail2: decimal = self.tail(self.e_power(self.y(z2)))
        weight: decimal = self.weight(tail1, tail2, phase)
        payment: uint256 = self.payment(self.value, weight)
        send(self.owner, payment)
        self.t = t2
        self.z = z2
        self.left = tail2
        self.owner = new