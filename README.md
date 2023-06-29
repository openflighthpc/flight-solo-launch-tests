## Overview

Launch tests for Flight Solo images

## Current Functionality

Launch all available large x86 instances in AWS and verify if image works on them

## Performance Notes

The script can take a little while to verify things, the 2 biggest delays are with the Instance Status and SSH Status checks. Ultimately, this script will provide results within 30 mins of being run. 

```bash
$ time bash test_aws.sh
Launching 'Flight Solo 2023.4 Marketplace-738fdb47-0aeb-4f72-b746-c2d28a8e541c' on 'c4.large'
Launching 'Flight Solo 2023.4 Marketplace-738fdb47-0aeb-4f72-b746-c2d28a8e541c' on 'c5.large'
Launching 'Flight Solo 2023.4 Marketplace-738fdb47-0aeb-4f72-b746-c2d28a8e541c' on 'c5a.large'
Launching 'Flight Solo 2023.4 Marketplace-738fdb47-0aeb-4f72-b746-c2d28a8e541c' on 'c5d.large'
Launching 'Flight Solo 2023.4 Marketplace-738fdb47-0aeb-4f72-b746-c2d28a8e541c' on 'c5n.large'
<snip>

Waiting for all tests to complete...

##### SUCCESSES #####
logs/c5.large.log:SUCCESS: Instance type 'c5.large'
logs/c5a.large.log:SUCCESS: Instance type 'c5a.large'
logs/c5d.large.log:SUCCESS: Instance type 'c5d.large'
logs/c5n.large.log:SUCCESS: Instance type 'c5n.large'
<snip>

##### FAILURES #####
logs/c4.large.log:FAIL: Instance type 'c4.large'
logs/c6in.large.log:FAIL: Instance type 'c6in.large'
logs/i3.large.log:FAIL: Instance type 'i3.large'
logs/m4.large.log:FAIL: Instance type 'm4.large'
logs/r4.large.log:FAIL: Instance type 'r4.large'
logs/t2.large.log:FAIL: Instance type 't2.large'

bash test_aws.sh  38.84s user 13.46s system 6% cpu 14:23.54 total
```

Note: The above test didn't have any SSH test failures but did have a few Instance Status failures.
