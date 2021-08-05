#!/bin/bash

DIR=${1}
SV2V=${2}
FPGA=${3}

if [ -d "${DIR}/synth/verilog" ]; then
	rm -rf ${DIR}/synth/verilog
fi

mkdir ${DIR}/synth/verilog

cd ${DIR}/synth/verilog

${SV2V} ${DIR}/verilog/${FPGA}/configure.sv \
				${DIR}/verilog/constants.sv \
				${DIR}/verilog/functions.sv \
				${DIR}/verilog/wires.sv \
				${DIR}/verilog/bit_alu.sv \
				${DIR}/verilog/bit_clmul.sv \
				${DIR}/verilog/alu.sv \
				${DIR}/verilog/agu.sv \
				${DIR}/verilog/bcu.sv \
				${DIR}/verilog/lsu.sv \
				${DIR}/verilog/csr_alu.sv \
				${DIR}/verilog/mul.sv \
				${DIR}/verilog/div.sv \
				${DIR}/verilog/decoder.sv \
				${DIR}/verilog/register.sv \
				${DIR}/verilog/csr.sv \
				${DIR}/verilog/compress.sv \
				${DIR}/verilog/prefetch.sv \
				${DIR}/verilog/forwarding.sv \
				${DIR}/verilog/fetch_stage.sv \
				${DIR}/verilog/decode_stage.sv \
				${DIR}/verilog/execute_stage.sv \
				${DIR}/verilog/timer.sv \
				${DIR}/verilog/cpu.sv \
				${DIR}/verilog/${FPGA}/dram.sv \
				${DIR}/verilog/${FPGA}/iram.sv \
				${DIR}/verilog/${FPGA}/soc.sv \
				> soc.v
