# This ensures that no unwanted and potentially hazardous
# environment variables from the host system leak into the build environment.
exec env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash
