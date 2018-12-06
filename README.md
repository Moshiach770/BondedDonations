# Bonded Donations
_An experiment in applying dynamic token bonding curves to charitable giving_

For more information on Bonded Donations, see the [medium article](https://tokeneconomy.co/on-bonding-curves-and-charitable-giving-9bf74b9343d2)

For more information on dynamic token bonding curves, see the [medium article](https://tokeneconomy.co/dynamic-token-bonding-curves-41d36e43befa)

## What are Bonded Donations?
We utilise the design of dynamic token bonding curves to incentivise and increase viral growth of donations to charities.

TL;DR: A donation system where you receive tokens that grow in value, as more donations are made. Depending on what you value, you may 'exit' and sell the tokens at certain times, or hold onto them and continue to help grow the number of donors to the charitable cause.

### How?
When Alice makes a donation to Charity A, 90% of her donation goes to Charity A while 10% goes into a contract to back the bonding curve. Tokens are then minted (10 tokens for every 1 ETH) for Alice.

Alice now has a few choices:
 1. Sell the tokens she just received back to the bonding curve (essentially taking back some of her donation). This is not an optimal choice for Alice.
 2. Ask her friends to also donate to the charity. As her friends start to donate, the funds backing the curve will increase, which also increases the value of each token in the dynamic bonding curve.
 
     - As a bonus, for every charity token that is awarded to a new donor, the same amount of tokens is also created and split among the current token holders (i.e. all of the previous donors).
     - In Alice's case, she has been rewarded for both being an early donor and for convincing her friend, Bob, to also donate.

In the second option, her selfish goal is to increase the value backing the curve, so her tokens can be liquidated for a larger original price. Her charitable goal is to increase the money being donated to Charity A. Both the selfish and charitable goal support the same outcome.

### Potential attacks:
 - Hoarding a large potion of the supply to dump the tokens (and liquidate the curve): In this case it isn't really an attack, since to hoard a large portion of the supply you will need to donate a massive amount to the charity. This is the intention of bonded donations, so the outcome is positive. At the same time, early donors will receive tokens from the bonus pool, increasing the amount of tokens they hold.

 ### Potential improvements:
  - Creating a stronger referral mechanism where you can earn a larger portion of the bonus pool for direct referrals.

### To do:
 - Create bonus pool function
 - Deploy to a test net

## Experimental Stack
 - Truffle 5 beta
 - Web3.js 1.0 beta

## Set up

1. Ensure you have truffle 5 beta installed
```
npm uninstall -g truffle
npm install -g truffle@beta
```
2. Go to `client` directory and `npm install`
3. In the `client` directory, do `npm run start`
4. Run something like Ganache and migrate contracts to your local network


If you need to go back to truffle 4, simply:
```
npm uninstall -g truffle
npm install -g truffle
```