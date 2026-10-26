#!/bin/bash

image_id="ami-0055977a6e828a4f4"
instance_type="t3.micro"
domain_name="kamesh.store"
hosted_zone_id=""


for instance in $@

do
    #instance_id

    echo "instance is: $instance"

done