import { describe, it, expect } from 'vitest';
import { Cl } from '@stacks/transactions';

const accounts = simnet.getAccounts();
const wallet1 = accounts.get('wallet_1')!;
const wallet2 = accounts.get('wallet_2')!;
const deployer = accounts.get('deployer')!;

describe('tip-jar contract', () => {
  it('allows users to tip with a message', () => {
    const amount = 1000;
    const message = 'Thanks for the great work!';

    const tipResult = simnet.callPublicFn('tip-jar', 'tip', [Cl.uint(amount), Cl.stringAscii(message)], wallet1);

    expect(tipResult.result).toBeOk(Cl.bool(true));

    const totalTipped = simnet.getDataVar('tip-jar', 'total-tipped');
    expect(totalTipped).toBeUint(amount);

    const tipCount = simnet.getDataVar('tip-jar', 'tip-count');
    expect(tipCount).toBeUint(1);

    const tipData = simnet.callReadOnlyFn('tip-jar', 'get-tip', [Cl.uint(0)], deployer);
    expect(tipData.result).toBeSome(
      Cl.tuple({
        tipper: Cl.principal(wallet1),
        amount: Cl.uint(amount),
        message: Cl.stringAscii(message),
        'block-height': Cl.uint(3), // assuming block height starts at 1
      })
    );
  });

  it('rejects tip with zero amount', () => {
    const tipResult = simnet.callPublicFn('tip-jar', 'tip', [Cl.uint(0), Cl.stringAscii('test')], wallet1);

    expect(tipResult.result).toBeErr(Cl.uint(101)); // ERR-INVALID-AMOUNT
  });

  it('only owner can withdraw', () => {
    const withdrawResult = simnet.callPublicFn('tip-jar', 'withdraw', [], wallet1);

    expect(withdrawResult.result).toBeErr(Cl.uint(100)); // ERR-UNAUTHORIZED
  });

  it('owner can withdraw', () => {
    const withdrawResult = simnet.callPublicFn('tip-jar', 'withdraw', [], deployer);

    expect(withdrawResult.result).toBeOk(Cl.bool(true));
  });

  it('get-owner returns correct owner', () => {
    const owner = simnet.callReadOnlyFn('tip-jar', 'get-owner', [], deployer);

    expect(owner.result).toBePrincipal(deployer);
  });

  it('get-contract-balance returns 0', () => {
    const balance = simnet.callReadOnlyFn('tip-jar', 'get-contract-balance', [], deployer);

    expect(balance.result).toBeUint(0);
  });
});