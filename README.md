# Bonded Donations
_An experiment in applying dynamic token bonding curves to charitable giving_

For more information on dynamic token bonding curves, see the [medium article](https://tokeneconomy.co/dynamic-token-bonding-curves-41d36e43befa)

## What are bonded donations?
We utilise the design of dynamic token bonding curves to incentivise and increase viral growth of donations to charities.

### How?
When Alice makes a donation to Charity A, 90% of her donation goes to Charity A while 10% goes into a contract to back the bonding curve. Tokens are then minted (10 tokens for every 1 ETH) for Alice.

Alice now has a few choices:
 1. Sell the tokens she just received back to the bonding curve (essentially taking back some of her donation). This is not an optimal choice for Alice.
 2. Ask her friends to also donate to the charity. As her friends start to donate, the funds backing the curve will increase, which also increases the value of each token in the dynamic bonding curve. 
    - However, at the same time, Alice's portion of the supply will reduce, so the price of her tokens will dynamically adjust accordingly.
    - The optimal choice for Alice is then to either continue to donate more (to increase her portion of the supply), or to continue referring her network to donate to the charity (increasing the total funds backing the curve and hence, increasing the value of her tokens)

In the second option, her selfish goal is to increase the value backing the curve, so her tokens can be liquidated for a larger original price. Her charitable goal is to increase the money being donated to Charity A. Both the selfish and charitable goal support the same outcome.

If Alice decides not to refer any of her friends, then the tokens she received will reduce in value. 

### Potential attacks:
 - Hoarding a large potion of the supply to dump the tokens (and liquidate the curve): In this case it isn't really an attack, since to hoard a large portion of the supply you will need to donate a massive amount to the charity. This is the intention of bonded donations, so the outcome is positive.

 ### Potential improvements:
  - Creating 'referral' or derivative tokens of the people you refer, so as you refer more people, you're portion of the supply is not diluted (too much) from the new contributions you bring in. However in this case, it may resemble a traditional bonding curve and undermine the benefits of using dynamic bonding curves.

### To do:
 - The current solidity function doesn't work as I haven't figured out how to translate the math formula into EVM compatible code. The exponent part of the formula is not currently implementable, so I am researching a few alternatives to implement.

## Experimental Stack
 - Truffle 5 beta
 - Web3.js 1.0 beta
 - Newer and more sound dynamic token bonding formula (blog post explanation coming soon - if you're into math see the formula [here](https://docs.google.com/spreadsheets/d/13cCYamLOC_reqUdpD3AdQnBUWoH9S0aQijUzcmxDEGo/edit?usp=sharing))

## Set up

1. Ensure you have truffle 5 beta installed
2. Go to `client` directory and `npm install`
3. In the `client` directory, do `npm run start`
