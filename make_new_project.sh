#!/bin/bash

new_projname=$1
cp -R NexysBaseProject $new_projname
cd $new_projname
find . -type f -name "*NexysBaseProject*" -exec rename -- s/\NexysBaseProject/$new_projname/ {} +
find . -type f -exec sed -i s/NexysBaseProject/$new_projname/g {} +
