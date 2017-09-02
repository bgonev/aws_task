#!/bin/bash
## Addresses of LB
address=`cat ~/tmp/to_aws/files/lb.address | awk '{print $4}'`
address=`dig +short $address | head -1`
echo $address

echo "*****End.******"

echo "Add to your hosts file following record: $address www.domain.com"
echo "Then point your browser (preferably Firefox)  to http://www.domain.com to test the application hosted on this platform"
echo ""

