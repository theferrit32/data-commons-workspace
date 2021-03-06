#!/bin/bash

cd ~/
. ~/.profile

bash /home/dockeruser/entrypoint.sh

cd ~/venv
source bin/activate

weslog=/var/log/datacommons/weslog
jupyterlog=/var/log/datacommons/jupyterlog
sudo mkdir -p /var/log/datacommons
sudo chown -R dockeruser:datacommons /var/log/datacommons
touch ${weslog}
touch ${jupyterlog}

# allow specification of a few specific run commands. Ignore others
# when a process is backgrounded, write to its log file
if [ "$1" == "jupyter" ] || [ -z "$1" ]; then
    wes-server --backend=wes_service.cwl_runner --opt runner=cwltool --opt extra=--data-commons >> ${weslog} 2>&1  &
    jupyter notebook --ip=0.0.0.0 --no-browser --NotebookApp.token=''
elif [ "$1" == "wes-server" ]; then
    # suppress jupyter output
    jupyter notebook --ip=0.0.0.0 --no-browser --NotebookApp.token='' >> ${jupyterlog} 2>&1 &
    wes-server --backend=wes_service.cwl_runner --opt runner=cwltool --opt extra=--data-commons
elif [ "$1" == "venv" ]; then
    jupyter notebook --ip=0.0.0.0 --no-browser --NotebookApp.token='' >> ${jupyterlog} 2>&1 &
    wes-server --backend=wes_service.cwl_runner --opt runner=cwltool --opt extra=--data-commons >> ${weslog} 2>&1 &
    #deactivate && venv
    bash -i
fi

# drop back to venv shell when other commands are terminated or backgrounded
#/bin/bash -i
