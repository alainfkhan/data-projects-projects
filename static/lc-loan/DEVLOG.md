# DEVLOG

## 2026/04/12

### 14:30 - jupyter notebook crash

- I have a dataset with 29m rows from 2 CSV files.
- Just installed PyArrow to use VSCode extension: Data Wrangler - Microsoft.
- Opened `df_accepted` (2m rows) using Data Wrangler, it worked. Opened `df_accepted_dirty` (2m rows), jupyter notebook crashed.
- This is the second time the kernel died, maybe from some incorrect package installations or Conda.
    - https://github.com/microsoft/vscode-jupyter/wiki/Kernel-crashes
- Prior, recently installed:
    - `conda install conda-forge::pyarrow`
    - `conda install conda-forge::python-duckdb`

```txt
14:27:49.724 [error] Error in execution (get message for cell) Error: Unable to start Kernel 'dpp (Python 3.13.11)' due to a timeout waiting for the ports to get used. 
```

- I'm considering switching to UV for this project.

### 16:17 - conda initialize takes too long

1. Opened GitBash from shutdown.
1. Took too long to open.
1. Opened command prompt: `notepad %USERPROFILE%\.bash_profile`, opens `.bash_profile` in notepad.
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

- GitBash now opens, but cannot type `conda` commands.

### 22:22 - turn it off and on again works

1. Opted for using `uv`.
1. Goto some directory `~/dev/personal/test`.
1. 2nd run of `uv init`:

```bash
$ time uv init
Initialized project `test`

real    20m1.468s
user    0m0.046s
sys     0m0.046s
```

Then later in parent directory `~/dev/personal/`

```bash
$ rm -rf test
rm: cannot remove 'test': Device or resource busy
```

- Rebooted machine, `uv init` works.

### 22:58 - rebooting solved conda issue

- Uncommented `>>> conda initialize >>>` block.
- So the main issue was probably around running jupyter notebook + handling 2m rows.
