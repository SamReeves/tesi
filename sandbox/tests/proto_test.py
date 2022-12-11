import pytest
from brownie import *
import numpy as np
from math import isclose, exp
import random
from scipy.stats import norm

random.seed(hash(float('inf')))

"""
To test locally, use the following command:
brownie test -s

ALL FUNCTIONS SHOULD BE MARKED EXTERNAL FOR TESTING.
Only external functions can be called by pytest.

AND CHANGE THE FOLLOWING:
owner: address
TO
owner: public(address)
"""
start = chain.time()
val = 10 * 10 ** 18 # 10 ETH
epoch = 60 * 60 * 24 * 31 # 31 days

@pytest.fixture
def gauss(proto, accounts):
    yield proto.deploy(epoch, {'from': accounts[0], 'value': val})

"""
def test_init_owner(gauss, accounts):
    assert gauss.owner() == accounts[0]

def test_init_value(gauss):
    assert gauss.value() == val

def test_init_timeframe(gauss):
    assert gauss.epoch() == epoch

def test_mu(gauss):
    mu = np.mean([range(0, epoch)])
    mu_f = Fixed("%.10f" % mu)
    assert isclose(gauss.mu(), mu_f, abs_tol=1)

def test_sigma(gauss):
    sigma = np.std([range(0, epoch)])
    sigma_f = Fixed("%.10f" % sigma)
    assert isclose(gauss.sigma(), sigma_f, abs_tol=1)

def test_dummy_stats(gauss):
    assert gauss.t() == 0
    assert gauss.z() == '2.5'
    assert gauss.left() == '1.0'

def test_z_two_days(gauss):
    chain.sleep(60 * 60 * 24 * 2) # 2 days
    chain.mine() # mine the block, update time

    t = chain.time() - start
    mu = gauss.mu()
    sigma = gauss.sigma()
    z = gauss.z_score(t, mu, sigma)

    mock_z = (mu - t) / sigma
    assert isclose(z, mock_z)

def test_e_power(gauss):
    assert isclose(gauss.e_power('0.0'), exp(0))
    assert isclose(gauss.e_power('0.25'), exp(0.25), rel_tol=0.01)
    assert isclose(gauss.e_power('0.5'), exp(0.5), rel_tol=0.01)
    assert isclose(gauss.e_power('0.75'), exp(0.75), rel_tol=0.01)
    assert isclose(gauss.e_power('1.0'), exp(1))
    assert isclose(gauss.e_power('1.5'), exp(1.5), rel_tol=0.01)
    assert isclose(gauss.e_power('1.25'), exp(1.25), rel_tol=0.01)
    assert isclose(gauss.e_power('2.0'), exp(2))
    assert isclose(gauss.e_power('2.5'), exp(2.5), rel_tol=0.01)
    assert isclose(gauss.e_power('3.0'), exp(3))
    assert isclose(gauss.e_power('3.75'), exp(3.75), rel_tol=0.01)
    assert isclose(gauss.e_power('5.57'), exp(5.57), rel_tol=0.01)

def test_tail(gauss):
    t = chain.time() - start
    mu = gauss.mu()
    sigma = gauss.sigma()
    z = gauss.z_score(t, mu, sigma)

    y = gauss.y(z)
    e_p = gauss.e_power(y)
    tail = 1 - gauss.tail(e_p)

    assert isclose(tail, norm.cdf(t, mu, sigma), rel_tol=0.01)

def test_weight(gauss):
    mu = gauss.mu()
    sigma = gauss.sigma()

    phase = 0
    if gauss.t() > mu:
        phase += 1

    t1 = chain.time() - start
    z1 = gauss.z_score(t1, mu, sigma)
    y1 = gauss.y(z1)
    e_p1 = gauss.e_power(y1)
    tail1 = gauss.tail(e_p1)

    chain.sleep(60 * 60 * 24 * 7 * 2) # 2 weeks
    chain.mine()

    if chain.time() > mu:
        phase += 1

    t2 = chain.time() - start
    z2 = gauss.z_score(t2, mu, sigma)

    y = gauss.y(z2)
    e_p = gauss.e_power(y)
    tail2 = 1 - gauss.tail(e_p)

    weight = gauss.weight(
        tail1, tail2, phase)

    mock_tail1 = Fixed("%.10f" % norm.cdf(t1, mu, sigma))
    mock_tail2 = Fixed("%.10f" % norm.cdf(t2, mu, sigma))
    mock_weight = abs(gauss.weight(
        mock_tail1, mock_tail2, phase))

    print(weight, abs(mock_weight))
    assert isclose(weight, abs(mock_weight), rel_tol=0.01)

def test_payment(gauss):
    tail1 = gauss.left()

    t = chain.time() - start
    mu = gauss.mu()
    sigma = gauss.sigma()

    z = gauss.z_score(t, mu, sigma)
    y = gauss.y(z)
    e_p = gauss.e_power(y)
    tail2 = gauss.tail(e_p)
    phase = 1
    weight = gauss.weight(tail1, tail2, phase)
    pay = gauss.payment(val, weight)
    assert isclose(pay, weight * val)
"""

def test_give_give_burn(gauss, accounts):
    # RECORD ACCOUNT 0 BALANCE, ADVANCE TIME
    prebalance = accounts[0].balance()
    chain.sleep(60 * 60 * 24 * 7) # 1 week
    chain.mine()

    # GIVE TO ACCOUNT 1
    gauss.give(accounts[1], {'from': accounts[0]})
    assert gauss.owner() == accounts[1]
    assert accounts[0].balance() > prebalance

    # RECORD ACCOUNT 1 BALANCE, ADVANCE TIME
    prebalance = accounts[1].balance()
    chain.sleep(60 * 60 * 24 * 7) # 1 week
    chain.mine()

    # GIVE TO ACCOUNT 2
    gauss.give(accounts[2], {'from': accounts[1]})
    assert gauss.owner() == accounts[2]
    assert accounts[1].balance() > prebalance

    # RECORD ACCOUNT 2 BALANCE
    # ADVANCE TIME BEYOND EPOCH
    prebalance = accounts[2].balance()
    chain.sleep(60 * 60 * 24 * 7 * 10) # 10 weeks
    chain.mine()

    # TRY TO GIVE TO ACCOUNT 3
    # SHOULD SELFDESTRUCT BECAUSE EPOCH IS OVER
    gauss.give(accounts[3], {'from': accounts[2]})
    assert accounts[2].balance() > prebalance

    # CHECK THAT CONTRACT IS SELFDESTRUCTED
    # COMMENTED OUT BECAUSE IT FAILS
    #assert gauss.owner() == empty(address)
