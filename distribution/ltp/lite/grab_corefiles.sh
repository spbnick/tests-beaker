#!/bin/bash

. /usr/bin/rhts-environment.sh

bin_core_list=""

for core_abs in $(ls -1 /mnt/testarea/ltp/cores/core.*); do
    echo "Found corefile: $core_abs"
    bin=`file $core_abs | awk -F \' '{print $2}'`
    echo "from binary: $bin"
    bin=$(echo $bin | awk '{print $1}')
    if [ -e "/mnt/testarea/ltp/testcases/bin/$bin" ]; then
        grep "$bin" grab_corefiles_excluded_bins > /dev/null
        if [ $? -ne 0 ]; then
            bin_core_list="$bin_core_list $core_abs /mnt/testarea/ltp/testcases/bin/$bin"
        else
            echo "$bin is excluded"
        fi
    else
        bin_core_list="$bin_core_list $core_abs"
    fi
done

echo "List of files to pack: $bin_core_list"
if [ -n "$bin_core_list" ]; then
    tar cfvz binaries_and_corefiles.tar.gz $bin_core_list
    rhts_submit_log -l binaries_and_corefiles.tar.gz
    report_result unexpected_corefile_found WARN 1
else
    echo "No cores to submit"
fi
