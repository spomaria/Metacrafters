# Avalanche Subnets using HyperSDK
This is a simple exercise on how to create a subnet on Avalanche using HyperSDK. Here, we are building from scratch but using the framework provided and filling in the missing sections needed to make the HyperChain functional. Finally, we interact with the HyperChain by creating an asset on the HyperChain and carrying out basic operations to verify the functionality of the HyperChain.

This is a required project to complete the  AVAX PROOF: Advance Avalanche Course at [@metacraftersio](https://twitter.com/metacraftersio)

## Setting up the HyperSDK on Avalanche
The HyperSDK can be set up by following these steps:
1. clone [this repository](https://github.com/Metacrafters/tokenvm).
2. change your directory to the cloned directory and run this command `
go mod tidy` to normalize all dependencies
3. Configure the project constants. This was done by navigating to `consts/consts.go` and adding the missing parts as follows:
```
const (
	// TODO: choose a human-readable part for your hyperchain
	HRP = "token"
	// TODO: choose a name for your hyperchain
	Name = "TokenVM"
	// TODO: choose a token symbol
	Symbol = "TKNVM"
)
```
4. Navigate to `registry/registry.go` and register the Create_Asset and Mint_Assest actions so that the file now reads thus:
```
errs.Add(
		// When registering new actions, ALWAYS make sure to append at the end.
		consts.ActionRegistry.Register(&actions.Transfer{}, actions.UnmarshalTransfer, false),

		// TODO: register action: actions.CreateAsset
		consts.ActionRegistry.Register(&actions.CreateAsset{}, actions.UnmarshalCreateAsset, false),
		// TODO: register action: actions.MintAsset
		consts.ActionRegistry.Register(&actions.MintAsset{}, actions.UnmarshalMintAsset, false),

```
5. Run your Virtual Machine (VM) locally using these steps:
    1. Make sure Go is on your path, defined on your terminal, if not you can do so by running export `PATH=$PATH:$(go env GOPATH)/bin`
    
       If this path doesn’t work, you can also try export `PATH=$PATH:/usr/local/go/bin`
    2. Run `MODE="run-single" ./scripts/run.sh`
    3. Run `./scripts/build.sh`
        
        If you get a permissions denied error, try running these scripts with the bash command (i.e.`bash ./scripts/run.sh`)
    4. Load the demo private key included on the project `./build/token-cli key import demo.pk` and `./build/token-cli chain import-anr`

6. Interact with the HyperChain by following the instructions in the 'Demos' section.

## Demos
Someone: "Seems cool but I need to see it to really get it."
Me: "Look no further."

The first step to running these demos is to launch your own `tokenvm` Subnet. You
can do so by running the following command from this location (may take a few
minutes):
```bash
./scripts/run.sh;
```

_By default, this allocates all funds on the network to
`token1rvzhmceq997zntgvravfagsks6w0ryud3rylh4cdvayry0dl97nsjzf3yp`. The private
key for this address is
`0x323b1d8f4eed5f0da9da93071b034f2dce9d2d22692c172f3cb252a64ddfafd01b057de320297c29ad0c1f589ea216869cf1938d88c9fbd70d6748323dbf2fa7`.
For convenience, this key has is also stored at `demo.pk`._

_If you don't need 2 Subnets for your testing, you can run `MODE="run-single"
./scripts/run.sh`._

To make it easy to interact with the `tokenvm`, we implemented the `token-cli`.
Next, you'll need to build this. You can use the following command from this location
to do so:
```bash
./scripts/build.sh
```

_This command will put the compiled CLI in `./build/token-cli`._

Lastly, you'll need to add the chains you created and the default key to the
`token-cli`. You can use the following commands from this location to do so:
```bash
./build/token-cli key import demo.pk
./build/token-cli chain import-anr
```

_`chain import-anr` connects to the Avalanche Network Runner server running in
the background and pulls the URIs of all nodes tracking each chain you
created._

### Mint and Trade
#### Step 1: Create Your Asset
First up, let's create our own asset. You can do so by running the following
command from this location:
```bash
./build/token-cli action create-asset
```

Follow the prompts accordingly by typing in the name of the coin and type 'y' to continue. When you are done, the output should look something like this:
```
database: .token-cli
address: token1rvzhmceq997zntgvravfagsks6w0ryud3rylh4cdvayry0dl97nsjzf3yp
chainID: Em2pZtHr7rDCzii43an2bBi1M2mTFyLN33QP1Xfjy7BcWtaH9
metadata (can be changed later): GolCoin
continue (y/n): y
✅ txID: 2DEph7uUuAUFyLqeV3MsTddMzQ46cN5qVg1DaD2s74z4anP8pn
```

_`txID` is the `assetID` of your new asset._

The "loaded address" here is the address of the default private key (`demo.pk`). We
use this key to authenticate all interactions with the `tokenvm`.

#### Step 2: Mint Your Asset
After we've created our own asset, we can now mint some of it. You can do so by
running the following command from this location:
```bash
./build/token-cli action mint-asset
```

Here, you will need to enter the address to which you intend to mint the asset, the amount of asset you intend to mint and the 'assetID' which is the 'txID' of the asset you just created.When you are done, the output should look something like this (usually easiest
just to mint to yourself).
```
database: .token-cli
address: token1rvzhmceq997zntgvravfagsks6w0ryud3rylh4cdvayry0dl97nsjzf3yp
chainID: Em2pZtHr7rDCzii43an2bBi1M2mTFyLN33QP1Xfjy7BcWtaH9
assetID: 2DEph7uUuAUFyLqeV3MsTddMzQ46cN5qVg1DaD2s74z4anP8pn
metadata: GolCoin supply: 0
recipient: token1rvzhmceq997zntgvravfagsks6w0ryud3rylh4cdvayry0dl97nsjzf3yp
amount: 10000
continue (y/n): y
✅ txID: 2Rk89PyQg9JNVRAnJwgiHrQgNEUqdJQY5k1WZ5LpwNu6rRac99
```

#### Step 3: View Your Balance
Now, let's check that the mint worked right by checking our balance. You can do
so by running the following command from this location:
```bash
./build/token-cli key balance
```

Follow the prompts and input the 'assetID' of the asset whose balance you intend to check. When you are done, the output should look something like this:
```
database: .token-cli
address: token1rvzhmceq997zntgvravfagsks6w0ryud3rylh4cdvayry0dl97nsjzf3yp
chainID: Em2pZtHr7rDCzii43an2bBi1M2mTFyLN33QP1Xfjy7BcWtaH9
assetID (use TKN for native token): 2DEph7uUuAUFyLqeV3MsTddMzQ46cN5qVg1DaD2s74z4anP8pn
metadata: GolCoin supply: 10000 warp: false
balance: 10000 2DEph7uUuAUFyLqeV3MsTddMzQ46cN5qVg1DaD2s74z4anP8pn
```

#### Step 4: Create an Order
So, we have some of our token (`GolCoin`)...now what? Let's put an order
on-chain that will allow someone to trade the native token (`TKN`) for some.
You can do so by running the following command from this location:
```bash
./build/token-cli action create-order
```

When you are done, the output should look something like this:
```
database: .token-cli
address: token1rvzhmceq997zntgvravfagsks6w0ryud3rylh4cdvayry0dl97nsjzf3yp
chainID: Em2pZtHr7rDCzii43an2bBi1M2mTFyLN33QP1Xfjy7BcWtaH9
in assetID (use TKN for native token): 2DEph7uUuAUFyLqeV3MsTddMzQ46cN5qVg1DaD2s74z4anP8pn
✔ in tick: 10█
out assetID (use TKN for native token): TKN
metadata: GolCoin supply: 10000 warp: false
balance: 10000 2DEph7uUuAUFyLqeV3MsTddMzQ46cN5qVg1DaD2s74z4anP8pn
out tick: 5
supply (must be multiple of out tick): 20
continue (y/n): y
✅ txID: ZzT6ZyF1bxF3qHJYTrzBsHMdeJHokpDTfUYXQHQVPMTUQdRU1
```

_`txID` is the `orderID` of your new order._

The "in tick" is how much of the "in assetID" that someone must trade to get
"out tick" of the "out assetID". Any fill of this order must send a multiple of
"in tick" to be considered valid (this avoid ANY sort of precision issues with
computing decimal rates on-chain).

#### Step 5: Fill Part of the Order
Now that we have an order on-chain, let's fill it! You can do so by running the
following command from this location:
```bash
./build/token-cli action fill-order
```

When you are done, the output should look something like this:
```
database: .token-cli
address: token1rvzhmceq997zntgvravfagsks6w0ryud3rylh4cdvayry0dl97nsjzf3yp
chainID: 2ng5Edf5w5hJForxyjPcTA5bAgbwvjV4esMDeGfhETUFgQb8BA
in assetID (use TKN for native token): 2DEph7uUuAUFyLqeV3MsTddMzQ46cN5qVg1DaD2s74z4anP8pn
metadata: GolCoin supply: 10000 warp: false
balance: 10000 2DEph7uUuAUFyLqeV3MsTddMzQ46cN5qVg1DaD2s74z4anP8pn
out assetID (use TKN for native token): TKN
available orders: 1
0) Rate(in/out): 0.0000 InTick: 10 2DEph7uUuAUFyLqeV3MsTddMzQ46cN5qVg1DaD2s74z4anP8pn OutTick: 5.000000000 TKN Remaining: 20.000000000 TKN
value (must be multiple of in tick): 10
in: 10 2DEph7uUuAUFyLqeV3MsTddMzQ46cN5qVg1DaD2s74z4anP8pn out: 5.000000000 TKN
continue (y/n): y
✅ txID: 2Y4yn73ZekDNEPGsT5iq85563QUENKJwA7FJ2Vd5gr99XonjA8
```

Note how all available orders for this pair are listed by the CLI (these come
from the in-memory order book maintained by the `tokenvm`).

#### Step 6: Close Order
Let's say we now changed our mind and no longer want to allow others to fill
our order. You can cancel it by running the following command from this
location:
```bash
./build/token-cli action close-order
```

When you are done, the output should look something like this:
```
database: .token-cli
address: token1rvzhmceq997zntgvravfagsks6w0ryud3rylh4cdvayry0dl97nsjzf3yp
chainID: Em2pZtHr7rDCzii43an2bBi1M2mTFyLN33QP1Xfjy7BcWtaH9
orderID: 2TdeT2ZsQtJhbWJuhLZ3eexuCY4UP6W7q5ZiAHMYtVfSSp1ids
out assetID (use TKN for native token): 27grFs9vE2YP9kwLM5hQJGLDvqEY9ii71zzdoRHNGC4Appavug
continue (y/n): y
✅ txID: poGnxYiLZAruurNjugTPfN1JjwSZzGZdZnBEezp5HB98PhKcn
```

Any funds that were locked up in the order will be returned to the creator's
account.

## Authors
Nengak Emmanuel Goltong 

[@NengakGoltong](https://twitter.com/nengakgoltong) 
[@nengakgoltong](https://www.linkedin.com/in/nengak-goltong-81009b200)

## License
This project is licensed under the MIT License - see the LICENSE.md file for details