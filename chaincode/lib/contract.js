'use strict';

const { Contract } = require('fabric-contract-api');

class Insurance extends Contract {

    async UploadIdentity(ctx, pubkey) {
        const mspid = ctx.clientIdentity.getMSPID();
        await ctx.stub.putState(mspid, pubkey);
    }

    async GetKey(ctx, mspid) {
        const pubkey = await ctx.stub.getState(mspid);
        return pubkey.toString();
    }

    async UploadTxn(ctx, txn, keys) {
        const { createHash } = require('crypto');
        const hashfunc = createHash('sha256');

        var prev = ctx.stub.getState("statehash").toString();
        if (!prev || prev.length === 0) {
            prev = hashfunc.update("0").digest('hex');
        }

        const statehash = hashfunc.update(prev + txn).digest('hex');
        await ctx.stub.putState("statehash", statehash);

        return statehash;
    }
}

module.exports = Insurance;
