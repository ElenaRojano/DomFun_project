#! /usr/bin/env bash

module unload java
#module load matlab/R2017b
module load matlab/R2015b_jvm


rm -rf eval2
cd CAFA2/matlab
matlab < ./manage_benchmark.m
