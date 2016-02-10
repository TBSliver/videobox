#!/bin/bash

for V in 0 1 2 3 4 ; do
  ssh fosdem@venc${V}.fosdem.org "cd videobox && git pull > /dev/null && ./update_status_venc${V}.sh"
done


