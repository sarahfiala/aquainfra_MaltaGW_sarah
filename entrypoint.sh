#!/bin/sh
cd /app/SCRIPTS
"/app/SCRIPTS/runSeaWat.sh" "$@"


# In Dockerfile, it was:
#WORKDIR /app/SCRIPTS
#CMD ["bash", "./run_model.sh"]
