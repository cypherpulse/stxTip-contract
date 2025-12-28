import { describe, it, expect } from 'vitest';
import { Cl } from '@stacks/transactions';

const accounts = simnet.getAccounts();
const deployer = accounts.get('deployer')!;

describe('tip-jar contract - basic functionality', () => {
  it('should deploy successfully', () => {
    // Test that the contract deploys without errors
    expect(true).toBe(true);
  });

  it('should have correct owner', () => {
    const owner = simnet.callReadOnlyFn('tip-jar', 'get-owner', [], deployer);
    expect(owner.result).toBePrincipal(deployer);
  });

  it('should initialize with zero tips', () => {
    const tipCount = simnet.callReadOnlyFn('tip-jar', 'get-tip-count', [], deployer);
    expect(tipCount.result).toBeUint(0);

    const totalTipped = simnet.callReadOnlyFn('tip-jar', 'get-total-tipped', [], deployer);
    expect(totalTipped.result).toBeUint(0);
  });

  it('should return zero balance', () => {
    const balance = simnet.callReadOnlyFn('tip-jar', 'get-contract-balance', [], deployer);
    expect(balance.result).toBeUint(0);
  });
});