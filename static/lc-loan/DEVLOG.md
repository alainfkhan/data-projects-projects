# DEVLOG

## 2026/04/12

### 14:30

- I have a dataset with 29m rows from 2 CSV files.
- Just installed PyArrow to use VSCode extension: Data Wrangler - Microsoft.
- Opened `df_accepted` (2m rows) using Data Wrangler, it worked. Opened `df_accepted_dirty`, jupyter notebook crashed.
- Second time the kernel died, maybe from some incorrect package installations or Conda.
    - https://github.com/microsoft/vscode-jupyter/wiki/Kernel-crashes
- Prior, recently installed:
    - `conda install conda-forge::pyarrow`
    - `conda install conda-forge::python-duckdb`

```txt
14:27:49.724 [error] Error in execution (get message for cell) Error: Unable to start Kernel 'dpp (Python 3.13.11)' due to a timeout waiting for the ports to get used. 
```

- I'm considering switching to UV for this project.

### 16:17

1. Opened GitBash from shutdown.
1. Took too long to open.
1. Opened command prompt: `notepad %USERPROFILE%\.bash_profile`, notepad opens in `.bash_profile`.
1. Commented out `>>> conda initialize >>>` code block.

```bash
# .bash_profile:

# # >>> conda initialize >>>
# # !! Contents within this block are managed by 'conda init' !!
# if [ -f '/c/Users/alain/miniconda3/Scripts/conda.exe' ]; then
#     eval "$('/c/Users/alain/miniconda3/Scripts/conda.exe' 'shell.bash' 'hook')"
# fi
# # <<< conda initialize <<<
```

1. GitBash now opens, but cannot type `conda` commands.