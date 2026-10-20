
## Repository structure

| Path | Contents |
| --- | --- |
| `0Data/` | Network datasets used in the experiments. |
| `1Main function/` | Training and testing data generation, dynamical equations, numerical integration, and perturbation routines. |
| `1Main function/Different dynamics/` | Additional dynamical-model implementations. |
| `2Compute function/` | Response-matrix estimation, state prediction, and MATLAB comparison plots. |
| `3Flight network/` | Files for the flight-network case study. |
| `4Trade network/` | Files for the trade-network case study. |
| `5foodweb/` | Files for the food-web case study. |
| `Figure2A/` | Files associated with Figure 2A. |
| `Figure2B/` | Files associated with Figure 2B. |
| `ploting.ipynb` | Consolidated Python notebook for plotting and response-matrix rank/effective-rank analysis. |


## Requirements

- MATLAB R2024b.
- Parallel Computing Toolbox for parallel execution of the `parfor` loops used in data generation. If running without parallel execution, adapt these loops to serial `for` loops.

### Python

- Python 3 and a Jupyter-compatible environment, such as JupyterLab or VS Code with notebook support.
- NumPy, SciPy, h5py, and Matplotlib.

## Workflow

The general workflow is:

1. Select a network and dynamical model.
2. Configure the initial-state distribution and perturbation protocol.
3. Generate training data using numerical integration.
4. Estimate the response matrices from the training ensembles.
5. Generate independent testing data and predict the perturbed states.
6. Compare predictions with integrated dynamics and generate figures in `ploting.ipynb`.

The scripts contain experiment-specific settings and local paths. Configure these before running; the repository is not currently a single-command reproduction pipeline.

## Getting started

### 1. Download the repository

```bash
git clone https://github.com/Renjie-98/Anticipating-shock-induced-transitions.git
cd Anticipating-shock-induced-transitions
```

Alternatively, download and extract the repository ZIP archive from GitHub.

### 2. Configure MATLAB paths and input data

Set the MATLAB current folder to the repository root, then add the main and computation folders:

```matlab
repoRoot = pwd;
addpath(fullfile(repoRoot, '1Main function'));
addpath(fullfile(repoRoot, '2Compute function'));
```

Add other model-specific folders only when needed. Avoid indiscriminately adding all model folders if they contain functions with identical names.

Update the `dataPath` settings in the training and testing functions to point to the selected network file. For example:

```matlab
dataPath = fullfile(repoRoot, '0Data', '1.Mutualistic_Coral Reefs.mat');
```

When using this expression inside a function, define `repoRoot` there or pass it explicitly. A variable defined in the MATLAB base workspace is not automatically available inside a function.

Also update the input/output folder settings in the response-matrix and prediction functions. All stages must refer to the same experiment configuration and compatible data dimensions.

### 3. Generate training and testing data

The mutualistic example uses:

- `M_real_sub_train.m`: generates one training ensemble file per initial condition.
- `M_real_sub_test.m`: combines testing realizations into `X_test.mat`.
- `Perturpation_real_M.m`: dispatches the perturbation routine.
- `M_system.m` and `iteration_real_M.m`: define and integrate the dynamics.
- `node_removal_M.m`, `link_removal_M.m`, and `weight_changes_M.m`: implement different perturbation protocols.

Configure the selected network, number of initial conditions, number of realizations, and perturbation settings in the relevant functions before running them. The current training and testing functions load the network using their internal `dataPath`; their declared `the_net` argument should not be assumed to select the dataset.

For a reproducible run, initialize the random-number generator before generating data and record the seed:

```matlab
rng(1, 'twister');
```

Use separate training and testing samples, and record the settings used for each stage.

### 4. Estimate response matrices and predict states

Use `compute_Rp.m` to estimate response matrices from training data, then `compute_Xp.m` to generate predictions for the testing data.

Before running these functions:

- Update their experiment-folder paths; the supplied examples may point to a different network or perturbation type.
- In `compute_Rp.m`, restrict the training-file search to `x0*.mat` rather than all `*.mat` files if the folder also contains `X_test.mat`, `R_p.mat`, or other outputs.
- Load the testing tensor into the MATLAB workspace. `compute_Xp.m` prompts for the workspace variable name.
- Check the preprocessing in `compute_Xp.m`: the supplied version removes the second entry along the sample axis and uses the first entry as the initial state. This assumes a particular data layout and must be checked before applying it to another experiment.
- Check where each function saves its outputs. In the supplied version, `compute_Xp.m` saves `X_p.mat` in the current MATLAB folder.

Do not delete or shift samples solely to make array lengths agree. Initial states, response matrices, predictions, and observations must refer to the same sample indices.

### 5. Generate figures with Python

Place `ploting.ipynb` in the repository root and open it with:

```bash
jupyter lab ploting.ipynb
```

The notebook consolidates plotting code, including comparisons of response-matrix predictions with integrated dynamics and analysis of normalized rank and effective rank.

For the figure being reproduced:

1. Update the data directories in the relevant cell.
2. Confirm that the required MATLAB output files are available.
3. Check the time grid, perturbation levels, and array preprocessing.
4. Configure any required LaTeX paths.
5. Run the selected figure cell and inspect the saved output.

Some cells are alternative versions of the same figure and may save to the same filename. Select the intended version rather than running all figure cells blindly. Output paths are controlled by settings such as `OUTPUT_SVG`; when `Path.cwd()` is used, the output is saved in the notebook kernel's current working directory.

## Parameters and data format

### Initial conditions

For routines using

```matlab
x0 = x_0 * ones(n, 1) + sigma * rand(n, 1);
```

the initial state of each node is sampled uniformly from `[x_0, x_0 + sigma)`. Here, `sigma` controls the sampling interval width; it is not the standard deviation of Gaussian noise.

### Perturbations

Node removal, link removal, and interaction-weight changes correspond to different experiments. Report the selected protocol and define its control parameter explicitly. A number of removed nodes and a fraction of removed nodes are not interchangeable: removing `k` nodes from a network with `N` nodes corresponds to a removal fraction of `k/N`.

For node removal, also specify whether deleted nodes are retained as zero entries or physically removed from the state vector and adjacency matrix. This choice affects matrix dimensions and node averages.

### Main variables

| Variable | Meaning | Typical MATLAB dimensions |
| --- | --- | --- |
| `A` | Network adjacency or interaction-weight matrix | `N x N` |
| `x0` | Initial node-state vector | `N x 1` |
| `outputs` | Training responses for one initial condition | `realizations x samples x nodes` |
| `X_test` | Combined testing responses | `experiments x samples x nodes` |
| `R_p` | Estimated response matrices | `nodes x nodes x samples` |
| `X_p` | Predicted node states | `experiments x samples x nodes` |

Depending on the experiment, the sample axis may represent time points or perturbation settings. Inspect the generating routine to determine its meaning; array dimensions alone do not identify it.

MATLAB v7.3 files are read using h5py in Python, while other MAT formats can be read with SciPy. Check dimension ordering when transferring arrays between MATLAB and Python.


## Citation

Please also cite the original sources of any network datasets used in your analysis. Publication details and a DOI can be added to the citation when available.


