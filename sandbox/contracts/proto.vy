# @version ^0.3.7
"""
@title Gaussian Currency Future
@author Sam Reeves
@license MIT
"""
value: public(uint256)
end: public(uint256)
mu: public(uint256)
sigma: public(uint256)
t: public(uint256)
z: public(decimal)
owner: public(address)
tail: public(decimal)

@external
@payable
def __init__(_epoch: uint256):
    """
    Initialize the contract with the epoch in seconds.
    The contract requires Eth to be sent to it.
    """
    assert _epoch > 60 * 60 * 24, "Lifetime must be at least 86400 seconds."
    assert msg.value > 0, "Deployment must be given Eth in Wei."
    self.end = block.timestamp + _epoch
    self.owner = msg.sender
    self.value = msg.value
    self.mu = _epoch / 2
    self.sigma = convert((convert(_epoch, decimal) / 3.464101615), uint256)
    self.t = 0
    self.z = 2.5
    self.tail = 1.0

@external
@payable
def __default__():
    """
    Returns an error if Eth is sent to the contract.
    """
    assert msg.value == 0, "No Eth should be sent to this function."

@internal
@view
def z_score() -> decimal:
    """
    Update the Z-score.  This value is always positive.
    Change state, return nothing.
    """
    z: decimal = 0.0
    if self.t > self.mu:
        z = convert(self.t - self.mu, decimal) / convert(self.sigma, decimal)
    else:
        z = convert(self.mu - self.t, decimal) / convert(self.sigma, decimal)
    return z

@internal
@pure
def calculate_tail(_z: decimal) -> decimal:
    """
    Calculate the tail of the distribution given a z-score.
    Change state, return nothing.
    The algorithm uses scaled integers to avoid floating point errors.
    """
    e_whole: uint256 = 27182818284
    y: int256 = floor(13.1946891451 * _z / (9.0 - _z))

    scale_y: uint256 = pow_mod256(10000000000, convert(y, uint256))
    e_y: uint256 = pow_mod256(e_whole, scale_y)
    frac: decimal = convert(e_y, decimal) / convert(scale_y, decimal)
    return 1.0 - 1.0 / (1.0 + frac)

@internal
@view
def calculate_payment(_left_tail: decimal) -> uint256:
    """
    Calculate the payment given a time.
    Change the state, return the payment amount as an integer in Wei.
    No value is sent.
    """
    area: decimal = 0.0

    if self.t < self.mu and block.timestamp < self.mu:
        area = _left_tail - self.tail
    elif self.t < self.mu and block.timestamp > self.mu:
        area = _left_tail - (1.0 - self.tail)
    else:
        area = (1.0 - _left_tail) - (1.0 - self.tail)
    return convert(area * convert(self.value, decimal), uint256)

@external
@payable
def give():
    """
    Update variables and calculate a payment.
    Send that payment to the owner, and change ownership.
    """
    assert msg.sender == self.owner, "Only the owner can give the contract."

    if block.timestamp > self.end:
        send(self.owner, self.balance)
        selfdestruct(self.owner)
    else:
        left_z: decimal = self.z
        left_tail: decimal = self.tail
        self.t = block.timestamp
        self.z = self.z_score()
        self.tail = self.calculate_tail(self.z)
        payment: uint256 = self.calculate_payment(self.tail)
        send(self.owner, payment)
        self.owner = convert(msg.data, address)