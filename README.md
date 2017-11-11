This git repo is about doing a DDC POC - a proof-of-concept of a diverse double compilation using tinycc aka tcc because 
* it is easier to get started with it
* it is already building reproducibly
* faster to compile (gcc takes over one hour)
* it has fewer build dependencies (which need to be version-tracked when rebuilding)

## Using more compilers

`ddc.sh` will automatically pick up the following compilers on your PATH and
test them:

icc             https://software.intel.com/en-us/parallel-studio-xe/choose-download/open-source-contributor
pgcc            https://www.pgroup.com/products/community.htm
