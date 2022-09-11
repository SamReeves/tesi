# @version ^0.3.0
# Sam Reeves

# Declare variables
active: bool
owner: address
value: uint256
value_init: uint256
time_maturity: uint256
time: uint256
time_prev: uint256
mu: uint256
dev: decimal
z: decimal

updates: HashMap[address, uint256]

@external
def __init__():
	# Initialize variables
	self.active = False
	self.time = convert(block.timestamp, uint256)
	self.owner = msg.sender
	self.value = ZERO_WEI
	self.value_init = ZERO_WEI
	self.time_maturity = self.time
	self.time_prev = 0
	self.z = 0
	self.mu = 0
	self.dev = 0
	self.updates = {}

@internal
def calculate_gas():
	return ZERO_WEI

@internal
def z_score(t: uint256):
	return abs(convert(t - self.mu, decimal) / self.dev)

@internal
def Lin_tail(z: decimal):
	y = 13.1946891451 * z / (9 - z)
	return 1 - 1 / (1 + 2.7182818284 ** y)

#def Polya_tail(z):
#	y = 1 - 2.7182818284 ** (-2 * (z**2) / 3.14159265359)
#	return 0.5 * (1 + sqrt(y))

#def Winitzki_tail(z):
#	a = -z**2/2
#	b = 0.147 * a
#	c = 1 - 2.7182818284 ** ((a * (4 / 3.14159265359 + b)) / (1 + b))
#	return 0.5 * (1 + sqrt(c))

@internal
def calculate_w():
	# Calculate the value of weighting coefficient
	z_n: decimal = self.z_score(self.time)

	if (self.time_prev < self.mu) & (self.time > self.mu):
		return 1 - self.z - Lin_tail(z_n)
	else:
		return abs(Lin_tail(z_n) - self.z)

@internal
def burn():
	pass
	
@external
@payable
def activate(time_maturity: uint256):
	# Activate the contract
	assert msg.sender == self.owner
	assert not self.active
	self.value = msg.value
	self.value_init = self.value
	self.time_maturity = time_maturity
	self.mu = (self.time + self.time_maturity) / 2
	self.dev = convert(self.time_maturity - self.time, decimal) / 3.464101615
	self.active = True

@external
def trade(new_owner: address):
	# Transfer ownership of the contract
	assert self.active == True and msg.sender == self.owner
	self.updates[self.owner] = self.value
	self.time_prev = self.time
	self.time = block.timestamp
	send(self.owner, self.value / 2)
	self.owner = new_owner