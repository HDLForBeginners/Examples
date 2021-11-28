#!/bin/bash

# Get new project name
new_projname=$1

# Copy base project
cp -R NexysBaseProject $new_projname

# In new project, replace all filenames and file contents to new project name
cd $new_projname
find . -type f -name "*NexysBaseProject*" -exec rename -- s/\NexysBaseProject/$new_projname/ {} +
find . -type f -exec sed -i s/NexysBaseProject/$new_projname/g {} +
