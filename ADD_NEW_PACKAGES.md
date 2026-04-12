1. Look up official conda package name `{package_name}`.
1.  `$ conda install conda-forge::{package_name}` 
1. Add `{package_name}` (written exactly) in `environment-man.yml` under `dependencies`.
1. `$ make save`