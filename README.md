Steem Bash Tools
=============

This is a set of bash/zsh tools. They're designed to be loaded directly into your shell. It includes tools to help work with cli_wallet, such as `cli_start`, `cli_stop`, `cli_exec`, and JSON parsing tools, e.g. `extract_json_str/int/object`

The primary purpose of this is to allow fast deployment. An example of a deployment script can be found in `scripts/deploy_witness.sh`, which installs docker, steem-in-a-box, generates signing keys, and configures the `config.ini` file automatically.

Created by [@Someguy123](https://steemit.com/@someguy123) on Steemit

Install
========
Usage is as simple as sourcing the `load.sh` file

    source load.sh

For deployment purposes, compiled versions are available on the releases page: 

Example:

    (curl -L https://github.com/Someguy123/steem-bash/releases/download/0.0.1/compiled.sh > steem.sh) &&\
    source steem.sh &&\
    deploy_witness YOURNAME &&\
    ./run.sh start

Checking the status of a seed/witness/rpc

    $ # Automatically boots up a cli_wallet and connects
    $ # to the local node. Now print the actual status
    $ steem_status
    Last block was: 20 days old
    Block number: 4507233
    Client Version: v0.14.2

Build your own compiled shell script:

    (echo "# Compiled at: $(date)\n" && cat plugins/*.sh scripts/*.sh) > compiled.sh

License
=====

GNU GPL 3.0 - check LICENSE

Documentation
======

There are a variety of methods available, lower and higher level.

---

**deploy_witness** (scripts/deploy_witness.sh)

Powerful command. Installs docker, steem-in-a-box, configures the config.ini as required, downloads the latest steem docker image via steem-in-a-box

Arguments: (both optional), witness username, witness signing key

If no username is given, the script will prompt you for one.

If no signing key is given, one is automatically generated and put into the config file.

```
root@steemtest:~/steem-tools# deploy_witness someguy123
Installing steem-in-a-box with docker
............ (various installing output)
Configuring witness
Removing item p2p-endpoint from /root/steem-docker/data/witness_node_data_dir/config.ini
Removing item miner from /root/steem-docker/data/witness_node_data_dir/config.ini
Removing item mining-threads from /root/steem-docker/data/witness_node_data_dir/config.ini
Setting rpc-endpoint to 0.0.0.0:8090 in file /root/steem-docker/data/witness_node_data_dir/config.ini
No signing key specified, so generating keys
Private: 5KNqeq45UHVADpJUGhGYdjFYEyFJz9VUayzt8idDnQaQhThHzdX
Public: STM6m5zf63msRDmGQhn5JN7AQLMq8KYBgZ2dcYvAB5kkgUJsxYMza
Setting private-key to 5KNqeq45UHVADpJUGhGYdjFYEyFJz9VUayzt8idDnQaQhThHzdX in file /root/steem-docker/data/witness_node_data_dir/config.ini
Setting witness to "someguy123" in file /root/steem-docker/data/witness_node_data_dir/config.ini
For easier configuration in the future, add the following to your .bashrc or .zshrc :
export CONFIG_FILE=/root/steem-docker/data/witness_node_data_dir/config.ini
Witness is ready. To start: ./run.sh start
root@steemtest:~/steem-docker#
```
---

**connect_steem** (plugins/020_steemnode.sh)

Launches a `cli_wallet` and connects it to the **local** steem node, e.g. witness, NOT external. **NO PERSISTENCE**

Required/used by steem_status to get information of local node.



---

**steem_status** (plugins/020_steemnode.sh)

Calls `connect_steem`, takes no arguments.

Uses the cli_wallet instance to extract synchronization/version info.

```
root@steemtest:~# steem_status
Last block was: 20 days old
Block number: 4511278
Client Version: v0.14.2
```

---

**cli_exec** (plugins/010_cliwallet.sh)

Calls `cli_start`, which by default will connect to a `wss://node.steem.ws` unless a local node is connected via `connect_steem`.

Executes a `cli_wallet` command and returns the response. Make sure you appropriately quote your items, as they will be passed to the body of the `params:[]`

Example:

```
root@steemtest:~# cli_exec get_block 1
{"id":5,"result":{"previous":"0000000000000000000000000000000000000000","timestamp":"2016-03-24T16:05:00","witness":"initminer","transaction_merkle_root":"0000000000000000000000000000000000000000","extensions":[],"witness_signature":"204f8ad56a8f5cf722a02b035a61b500aa59b9519b2c33c77a80c0a714680a5a5a7a340d909d19996613c5e4ae92146b9add8a7a663eef37d837ef881477313043","transactions":[],"block_id":"0000000109833ce528d5bbfb3f6225b39ee10086","signing_key":"STM8GC13uCZbP44HzMLV6zPZGwVQ8Nt4Kji8PapsPiNq1BK153XTX","transaction_ids":[]}}
```

Can be used with the bundled basic json parsers to extract information.

```
root@steemtest:~# cli_exec get_witness '"someguy123"' | extract_json_str url
https://steemit.com/witness-category/@someguy123/someguy123-witness-thread
```

---

**cli_start** and **cli_stop** (plugins/010_cliwallet.sh)

They do exactly as they sound.

`cli_start` starts a cli_wallet connected to the $CLIWS variable (default wss://node.steem.ws), and plugs it into $DKR_NETWORK (default `witness_nw`)

`cli_stop` stops the cli_wallet previously started. Also stops wallets running via `connect_steem`.

---

**JSON Parsing tools**

There are several tools included in `000_helpers.sh` to help with parsing JSON.

`extract_json_str` - extracts the value of the first parameter (string)

```
$ echo {"x":"y"} | extract_json_str x
y
```

`extract_json_int` - extracts the value of the first parameter (integer)

```
$ echo {"x":123} | extract_json_int x
123
```

`extract_json_object` - extracts the value of the first parameter (object) **DOES NOT WORK WITH NESTED OBJECTS**

```
$ echo {"x":{"y": "z"}} | extract_json_int x
{"y": "z"}
```

---
