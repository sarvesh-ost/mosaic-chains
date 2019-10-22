import * as commander from 'commander';
import Logger from '../Logger';
import setupRedeemPool from '../lib/RedeemPool';
import Validator from './Validator';

import Web3 = require('web3');

const mosaic = commander
  .arguments('<originChain> <auxiliaryChain> <auxChainWeb3EndPoint> <deployer> <organizationOwner> <organizationAdmin>');
mosaic.action(
  async (
    originChain: string,
    auxiliaryChain: string,
    auxChainWeb3EndPoint: string,
    deployer: string,
    organizationOwner: string,
    organizationAdmin: string,
  ) => {
    const originWeb3 = new Web3(auxChainWeb3EndPoint);
    const isListening = await originWeb3.eth.net.isListening();
    if (!isListening) {
      Logger.error('Could not connect to aux node with web3');
    }

    if (!Validator.isValidOriginChain(originChain)) {
      Logger.error(`Invalid origin chain identifier: ${originChain}`);
      process.exit(1);
    }

    if (!Validator.isValidAuxChain(auxiliaryChain, originChain)) {
      Logger.error(`Invalid aux chain identifier: ${auxiliaryChain}`);
      process.exit(1);
    }

    if (!Validator.isValidAddress(deployer)) {
      Logger.error(`Invalid deployer address: ${deployer}`);
      process.exit(1);
    }
    if (!Validator.isValidAddress(organizationOwner)) {
      Logger.error(`Invalid organization owner address: ${organizationOwner}`);
      process.exit(1);
    }

    if (!Validator.isValidAddress(organizationAdmin)) {
      Logger.error(`Invalid organization admin address: ${organizationAdmin}`);
      process.exit(1);
    }

    try {
      await setupRedeemPool(
        originChain,
        auxiliaryChain,
        auxChainWeb3EndPoint,
        deployer,
        organizationOwner,
        organizationAdmin,
      );
    } catch (error) {
      Logger.error('error while executing mosaic setup redeem pool', { error: error.toString() });
      process.exit(1);
    }

    process.exit(0);
  },
)
  .parse(process.argv);
