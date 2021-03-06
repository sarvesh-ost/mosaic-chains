#!/bin/bash

#
# This file runs some basic mosaic commands to start, list, and stop chains.
# It asserts that the command generally works.
#

# Prints an info string to stdout.
function info {
    echo "INFO: $1"
}

# Prints an error string to stdout after it attempted to stop all running nodes.
function error {
    echo "ERROR! Aborting."
    stop_nodes
    echo "ERROR: $1"
    exit 1
}

# Starts a single origin node.
function start_origin_node {
    info "Starting node $1 with client $2."
    try_silent "./mosaic start $1 --client $2" "Could not start node $1 with client $2."
}

# Starts a single auxiliary node.
function start_auxiliary_node {
    info "Starting node $1."
    try_silent "./mosaic start $1 --origin ropsten" "Could not start node $1."
}

# Stops a single node.
function stop_node {
    info "Stopping node $1."
    try_silent "./mosaic stop $1" "Could not stop node $1."
}

# Stops all nodes for the test.
function stop_nodes {
    info "Stopping all nodes."
    stop_node ropsten
    stop_node 1407
    stop_node 1406
    stop_node dev-origin
    stop_node dev-auxiliary
}

# Deploy subgraph
# $1 origin chain identifier
# $2 aux chain identifier
# $3 chain {origin, auxiliary}
# $4 graph admin rpc port
# $5 graph IPFS port
function  deploy_subgraph {
    info "Deploying origin subraph."
    try_silent "./mosaic subgraph $1 $2 $3 http://localhost:$4 http://localhost:$5"
}

# Deploy subgraph
# $1 origin chain identifier
# $2 aux chain identifier
# $3 chain {origin, auxiliary}
# $4 graph admin rpc port
# $5 graph IPFS port
# gateway config
function  deploy_subgraph_gateway_config {
    info "Deploying origin subraph."
    try_silent "./mosaic subgraph $1 $2 $3 http://localhost:$4 http://localhost:$5 --gateway-config ~/.mosaic/$1/$2/$( echo "$6" | tr -s  '[:upper:]'  '[:lower:]' ).json"
}


# Tries a command without output. Errors if the command does not execute successfully.
function try_silent {
    eval $1 2>&1 || error "$2"
}

# Tries a command without output. Errors if the command *executes successfully.*
function fail_silent {
    eval $1 1>/dev/null 2>&1 && error "$2"
}

# Sets the global variable `grep_command` with the command to check if given chain is running.
function set_node_grep_command {
    grep_command="./mosaic list | grep mosaic_$1"
    if [ $2 == 'geth' ]
    then
        grep_command="${grep_command} | grep ethereum/client-go"
    fi

    if [ $2 == 'parity' ]
    then
        grep_command="${grep_command} | grep parity/parity"
    fi
    info "node_grep_command : $grep_command."
}

# Sets the global variable `grep_command` with the command to check if given chain's corresponding graph is running.
function set_graph_grep_command {
    grep_command="./mosaic list | grep 'mosaic_graph_$1_graph'"
}

# Errors if the given chain and its graph is not in the output of `mosaic list`.
function grep_try {
    info "Checking that node $1 is listed."
    set_node_grep_command $1 $2
    try_silent "$grep_command" "Node was expected to be running, but is not: $1."
    set_graph_grep_command $1
    try_silent "$grep_command" "Graph was expected to be running, but is not: $1."
}

# Errors if the given chain or its graph *is* in the output of `mosaic list`.
function grep_fail {
    info "Checking that node $1 is *not* listed."
    set_node_grep_command $1 $2
    fail_silent "$grep_command" "Node was not expected to be running, but is: $1."
    set_graph_grep_command $1
    fail_silent "$grep_command" "Graph was not expected to be running, but is: $1."
}

# Errors if an RPC connection to the node is not possible. Works only with chain IDs, not names.
function rpc_node_try {
    info "Checking RPC connection to node $1."
    try_silent "curl -X POST -H \"Content-Type: application/json\" --data '{\"jsonrpc\":\"2.0\",\"method\":\"eth_syncing\",\"params\":[],\"id\":1}' 127.0.0.1:4$1" "Could not connect to RPC of node $1."
}

function rpc_origin_sub_graph_try {
    info "Checking RPC connection to origin sub graph at port $1 on node for $2."
    try_silent "./node_modules/.bin/ts-node tests/Graph/SubGraphDeployment/origin-verifier.ts $1 $2" "Origin sub graph at port $1 was expected to be deployed on $2, but wasn't."
}

function rpc_auxiliary_sub_graph_try {
    info "Checking RPC connection to auxiliary sub graph for $1 chain on node."
    try_silent "./node_modules/.bin/ts-node tests/Graph/SubGraphDeployment/auxiliary-verifier.ts 6$1 $2" "Auxiliary sub graph was expected to be deployed, but wasn't."
}

function toLowerCase {
    return
}

# Making sure the mosaic command exists (we are in the right directory).
try_silent "ls mosaic" "Script must be run from the mosaic chains root directory so that the required node modules are available."

info "Starting node one by one and verifying if all services for them are running."
# 1406 config
GRAPH_ADMIN_RPC_1406=9426
GRAPH_IPFS_1406=6407
OST_COGATEWAY_ADDRESS_1406=0x02cffaa1e06c28021fff6b36d9e418a97b3de2fc

# 1407 config
GRAPH_ADMIN_RPC_1407=9427
GRAPH_IPFS_1407=6408
OST_COGATEWAY_ADDRESS_1407=0xf690624171fe06d02d2f4250bff17fe3b682ebd1

# ropsten config
GRAPH_ADMIN_RPC_ROPSTEN=8023
GRAPH_IPFS_ROPSTEN=5004
GRAPH_WS_PORT_ROPSTEN=60003
OST_GATEWAY_ADDRESS_ROPSTEN_1406=0x04df90efbedf393361cdf498234af818da14f562
OST_GATEWAY_ADDRESS_ROPSTEN_1407=0x31c8870c76390c5eb0d425799b5bd214a2600438

# Dev chain config
GRAPH_ADMIN_RPC_DEV_ORIGIN=9535
GRAPH_IPFS_DEV_ORIGIN=6516
GRAPH_WS_PORT_DEV_ORIGIN=61515
OST_GATEWAY_ADDRESS_DEV_ORIGIN_WETH=0xaE02C7b1C324A8D94A564bC8d713Df89eae441fe
OST_CO_GATEWAY_ADDRESS_DEV_ORIGIN_WETH=0xc6fF898ceBf631eFb58eEc7187E4c1f70AE8d943

DEV_AUXILIARY_CHAIN_ID=1000
GRAPH_ADMIN_RPC_DEV_AUXILIARY=9020
GRAPH_IPFS_DEV_AUXILIARY=6001

#start_auxiliary_node 1406
#grep_try 1406 geth
#rpc_node_try 1406
#deploy_subgraph ropsten 1406 auxiliary $GRAPH_ADMIN_RPC_1406 $GRAPH_IPFS_1406
#rpc_auxiliary_sub_graph_try 1406 $OST_COGATEWAY_ADDRESS_1406
#
#start_auxiliary_node 1407
#grep_try 1407 geth
#rpc_node_try 1407
#deploy_subgraph ropsten 1407 auxiliary $GRAPH_ADMIN_RPC_1407 $GRAPH_IPFS_1407
#rpc_auxiliary_sub_graph_try 1407 $OST_COGATEWAY_ADDRESS_1407
#
#start_origin_node ropsten geth
#grep_try ropsten geth
#rpc_node_try "0003" # Given like this as it is used for the port in `rpc_node_try`.
#deploy_subgraph ropsten 1406 origin $GRAPH_ADMIN_RPC_ROPSTEN $GRAPH_IPFS_ROPSTEN
#deploy_subgraph ropsten 1407 origin $GRAPH_ADMIN_RPC_ROPSTEN $GRAPH_IPFS_ROPSTEN
#rpc_origin_sub_graph_try $GRAPH_WS_PORT_ROPSTEN $OST_GATEWAY_ADDRESS_ROPSTEN_1406
#rpc_origin_sub_graph_try $GRAPH_WS_PORT_ROPSTEN $OST_GATEWAY_ADDRESS_ROPSTEN_1407
#
## Stop and start some nodes and make sure they are or are not running.
#stop_node ropsten
#grep_fail ropsten geth
#
#stop_node 1407
#grep_fail 1407 geth
#grep_try 1406 geth
#
#start_auxiliary_node 1407
#grep_try 1407 geth
#grep_try 1406 geth
#grep_fail ropsten geth
#
#start_origin_node ropsten parity
#grep_try ropsten parity


# Deploy subgraph with gateway config
start_origin_node dev-origin geth
start_auxiliary_node dev-auxiliary geth
deploy_subgraph_gateway_config dev-origin $DEV_AUXILIARY_CHAIN_ID origin $GRAPH_ADMIN_RPC_DEV_ORIGIN $GRAPH_IPFS_DEV_ORIGIN $OST_GATEWAY_ADDRESS_DEV_ORIGIN_WETH
deploy_subgraph_gateway_config dev-origin $DEV_AUXILIARY_CHAIN_ID auxiliary $GRAPH_ADMIN_RPC_DEV_AUXILIARY $GRAPH_IPFS_DEV_AUXILIARY $OST_GATEWAY_ADDRESS_DEV_ORIGIN_WETH
rpc_origin_sub_graph_try  $GRAPH_WS_PORT_DEV_ORIGIN $OST_GATEWAY_ADDRESS_DEV_ORIGIN_WETH
rpc_auxiliary_sub_graph_try $DEV_AUXILIARY_CHAIN_ID $OST_CO_GATEWAY_ADDRESS_DEV_ORIGIN_WETH
## When done, stop all nodes.
stop_nodes
