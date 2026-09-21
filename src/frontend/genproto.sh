#!/bin/bash -eu


PATH=$PATH:$GOPATH/bin
protodir=../../protos

protoc --go_out=plugins=grpc:genproto -I $protodir $protodir/demo.proto
