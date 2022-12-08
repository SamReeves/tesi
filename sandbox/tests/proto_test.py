import pytest
from math import isclose
from brownie import *

val = 1 * 10 ** 18 # 1 ETH
epoch = 60 * 60 * 24 * 31 # 31 days
mu = epoch / 2
sigma = mu / 3.4641016151
start = 0

# Deploy the contract with test wallets (locally) 
@pytest.fixture
def gauss(proto, accounts):
    start = chain.time()
    yield proto.deploy(epoch, {'from': accounts[0], 'value': val})

def test_init_owner(gauss, accounts):
    assert gauss.owner() == accounts[0]

def test_init_value(gauss):
    assert gauss.value_0() == val

def test_init_timeframe(gauss):
    assert gauss.epoch() == epoch

def test_init_stats(gauss):
    mu_f = Fixed("%.10f" % mu)
    sigma_f = Fixed("%.10f" % sigma)

    print(gauss.mu(), mu_f)
    print(gauss.sigma(), sigma_f)

    assert isclose(gauss.mu(), mu_f)
    assert isclose(gauss.sigma(), sigma_f)

def test_z_two_hours(gauss):
    chain.sleep(60 * 60 * 2) # 2 hours
    chain.mine()
    t = chain.time() - start
    gauss.z_score(t)
    z = gauss.z()
    
    mock_z = (t - gauss.mu()) / gauss.sigma()
    formatted = float("%.10f" % mock_z)

    print(z, formatted)
    assert isclose(z, formatted)

def test_tail_calculation(gauss):
    chain.mine()
    y = Fixed(str(13.1946891451)) * gauss.z() / (Fixed(str(9.0)) - gauss.z())
    tail = 1 - 1 / (1 + 2.7182818284 ** float(y))
    formatted = float("%.10f" % tail)

    print(gauss.tail(), formatted)
    assert isclose(gauss.tail(), formatted, rel_tol=0.005)

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
    assert isclose(gauss.tail(), formatted, rel_tol=0.005)

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
    assert isclose(gauss.tail(), formatted, rel_tol=0.005)

"""
def test_weight_calculation(gauss):
    pass


def test_one_tx(gauss, accounts):
    pass
"""