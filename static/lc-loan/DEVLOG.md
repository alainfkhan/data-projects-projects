# DEVLOG

## 2026/04/12

- I have a dataset with 29m rows from 2 CSV files.
- Just installed PyArrow to use VSCode extension: Data Wrangler - Microsoft
- Opened a `df_accepted` (2m rows) using Data Wrangler, it worked. Opened `df_accepted_dirty`, jupyter notebooks crashed.
- Second time the kernel died, maybe from some incorrect package installations or Conda.
    - https://github.com/microsoft/vscode-jupyter/wiki/Kernel-crashes

```txt
14:27:49.724 [error] Error in execution (get message for cell) Error: Unable to start Kernel 'dpp (Python 3.13.11)' due to a timeout waiting for the ports to get used. 
```

- I'm considering switching to UV for this project.