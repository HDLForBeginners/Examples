
# relative
# The dir the implementation is running from
set run_dir [pwd]
# This script dir
set script_path [ file dirname [ file normalize [ info script ] ] ]

# My version file
set filename "$script_path/../src/version.vh"

# Where the final binary should land
set build_final_dir "$script_path/../builds/"

#  Slurp up the version data file
set fp [open $filename r]
set file_data [read $fp]
close $fp

#  Extract the version data
set data [split $file_data "\n"]
foreach line $data {
    if {[string first "VERSION_MAJOR" $line] != -1} {
        set line_major [split $line " "]
    }

    if {[string first "VERSION_MINOR" $line] != -1} {
        set line_minor [split $line " "]
    }

}

# Get version numbers
set version_major [lindex $line_major 2]
set version_minor [lindex $line_minor 2]

# Vivado produced bitstream filename
set bitstream_filename "$run_dir/NexysBaseProject_top.bit"

# New bitstream filename
set new_bitstream_filename  "$build_final_dir/NexysBaseProject_top_v${version_major}_${version_minor}.bit"

# Copy file to new location
puts "Build file v${version_major}.${version_minor} located in $new_bitstream_filename."
file mkdir "$build_final_dir/"
file copy -force $bitstream_filename $new_bitstream_filename
