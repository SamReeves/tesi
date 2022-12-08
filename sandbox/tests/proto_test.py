import pytest
from math import isclose
from brownie import *
import numpy as np

"""
To test locally, use the following command:
brownie test

ALL FUNCTIONS SHOULD BE MARKED EXTERNAL FOR LOCAL TESTING.
ONLY EXTERNAL FUNCTIONS CAN BE CALLED BY OTHER CONTRACTS.
"""

@pytest.fixture
def gauss(proto, accounts):
    yield proto.deploy(epoch, {'from': accounts[0], 'value': val})

start = chain.time()
val = 10 ** 18 # 1 ETH
epoch = 60 * 60 * 24 * 31 # 31 days

"""
def test_init_owner(gauss, accounts):
    assert gauss.owner() == accounts[0]

def test_init_value(gauss):
    assert gauss.value_0() == val

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

def test_z_two_hours(gauss):
    chain.sleep(60 * 60 * 2) # 2 hours
    chain.mine()
    t = chain.time() - start
    gauss.z_score(t)
    z = gauss.z()
    
    mock_z = abs((t - gauss.mu()) / gauss.sigma())
    formatted = float("%.10f" % mock_z)

    print(z, formatted)
    assert isclose(z, formatted)

def test_tail_calculation(gauss):
    chain.mine()
    y = Fixed(str(13.1946891451)) * gauss.z() / (Fixed(str(9.0)) - gauss.z())
    tail = 1 - 1 / (1 + 2.7182818284 ** float(y))
    formatted = float("%.10f" % tail)

    print(gauss.tail(), formatted)
    assert isclose(gauss.tail(), formatted, rel_tol=0.008)

def test_z_two_days(gauss):
    chain.sleep(60 * 60 * 24 * 2) # 2 days
    chain.mine()
    t = chain.time() - start
    gauss.z_score(t)
    z = gauss.z()
    
    mock_z = (t - gauss.mu()) / gauss.sigma()
    formatted = float("%.10f" % mock_z)

    print(z)
    assert isclose(z, formatted)

def test_tail_calculation(gauss):
    chain.mine()
    y = Fixed(str(13.1946891451)) * gauss.z() / (Fixed(str(9.0)) - gauss.z())
    tail = 1 - 1 / (1 + 2.7182818284 ** float(y))
    formatted = float("%.10f" % tail)

    print(gauss.tail(), formatted)
    assert isclose(gauss.tail(), formatted, rel_tol=0.008)

def test_z_two_weeks(gauss):
    chain.sleep(60 * 60 * 24 * 7 * 2) # 2 weeks
    chain.mine()
    t = chain.time() - start
    gauss.z_score(t)
    z = gauss.z()
    
    mock_z = (t - gauss.mu()) / gauss.sigma()
    formatted = float("%.10f" % mock_z)

    print(z)
    assert isclose(z, formatted)

def test_tail_calculation(gauss):
    chain.mine()
    y = Fixed(str(13.1946891451)) * gauss.z() / (Fixed(str(9.0)) - gauss.z())
    tail = 1 - 1 / (1 + 2.7182818284 ** float(y))
    formatted = float("%.10f" % tail)

    print(gauss.tail(), formatted)
    assert isclose(gauss.tail(), formatted, rel_tol=0.008)
"""

def test_give(gauss, accounts):
    chain.sleep(60 * 60 * 24 * 7) # 1 week
    gauss.give({'data': accounts[1], 'from': accounts[0], 'gas': 10000000})
    assert gauss.owner() == accounts[1]